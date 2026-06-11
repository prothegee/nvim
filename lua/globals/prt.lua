--[[
-- Completion was triggered by typing an identifier (24x7 code
-- Complete), manual invocation (e.g ctrl+p) or via api.
1:invoked
2:triggercharacter
3:triggerforincompletecompletions

Note: 3 is only meant for re-requesting after an isIncomplete
result. Verified on gopls, zls, and clangd that 1 and 3 return
identical items, so use the spec-correct 1.
--]]
local TRIGGER_KIND = 1

local function get_offset_encoding(bufnr)
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if clients and #clients > 0 then
        return clients[1].offset_encoding or "utf-16"
    end
    return "utf-16"
end

local function insert_snippet(snippet_text)
    local ok, err = pcall(function()
        vim.snippet.expand(snippet_text)
    end)
    if not ok then
        vim.notify("Snippet error: " .. tostring(err), vim.log.levels.WARN)
        return false
    end
    return true
end

-- Handle completion done event
local function on_complete_done()
    local completed_item = vim.v.completed_item
    if not completed_item or not completed_item.user_data then
        return
    end

    local user_data = completed_item.user_data
    if not user_data._lsp_item then
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local winid = vim.api.nvim_get_current_win()

    local apply_edits = function(edits)
        if edits and #edits > 0 then
            local offset_encoding = get_offset_encoding(bufnr)
            vim.lsp.util.apply_text_edits(edits, bufnr, offset_encoding)
        end
    end

    -- Apply additional text edits (for imports, etc.)
    if user_data.additionalTextEdits and #user_data.additionalTextEdits > 0 then
        apply_edits(user_data.additionalTextEdits)
    elseif user_data.client_id then
        local client = vim.lsp.get_client_by_id(user_data.client_id)
        if client and client:supports_method("completionItem/resolve") then
            client:request("completionItem/resolve", user_data._lsp_item, function(err, resolved_item)
                if not err and resolved_item and resolved_item.additionalTextEdits then
                    apply_edits(resolved_item.additionalTextEdits)
                end
            end)
        end
    end

    -- Handle snippet expansion
    if user_data._lsp_snippet and user_data.snippet_text then
        local start_col = user_data.start_char or 0
        local cursor = vim.api.nvim_win_get_cursor(winid)
        local row = cursor[1] - 1
        local col = cursor[2]

        local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
        local before = line:sub(1, start_col)
        local after = line:sub(col + 1)
        local cleaned_line = before .. after

        vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, { cleaned_line })
        vim.api.nvim_win_set_cursor(winid, { row + 1, start_col })

        vim.schedule(function()
            insert_snippet(user_data.snippet_text)
        end)
    end
end

---

_G._prt_fuzzy_completion = function(findstart, _)
    if vim.fn.mode() ~= "i" then
        if findstart == 1 then
            return -1
        else
            return {}
        end
    end

    local buf, line, line_text, row, col, cursor, start_char, end_char

    if findstart == 1 then
        line = vim.fn.getline(".")
        col = vim.fn.getcol(".")
        return (line:sub(1, col):find("[%w_]*$") or col) - 1
    else
        buf = vim.api.nvim_get_current_buf()

        if not vim.api.nvim_buf_is_valid(buf) or vim.fn.mode() ~= "i" then
            return {}
        end

        local current_buf = buf

        cursor = vim.api.nvim_win_get_cursor(0)
        row, col = cursor[1] - 1, cursor[2]
        line_text = vim.fn.getline(".")

        start_char = (line_text:sub(1, col):find("[%w_]*$") or col) - 1
        end_char = col

        vim.lsp.buf_request(buf, "textDocument/completion", {
            textDocument = vim.lsp.util.make_text_document_params(),
            position = { line = row, character = col },
            context = { triggerKind = TRIGGER_KIND },
        }, function(err, result, ctx)
            if not vim.api.nvim_buf_is_valid(current_buf) or vim.api.nvim_get_current_buf() ~= current_buf or vim.fn.mode() ~= "i" then
                return
            end

            if err or not result then
                return
            end

            local client_id = ctx and ctx.client_id
            local items = result.items or result

            if not items then
                return
            end

            local base = line_text:sub(start_char + 1, end_char)
            local all_matches = {}

            for _, item in ipairs(items) do
                -- servers like gopls put the snippet in textEdit.newText, not insertText
                local insert_text = (item.textEdit and item.textEdit.newText) or item.insertText or item.label
                local kind = item.kind or 0
                local kind_text = vim.lsp.protocol.CompletionItemKind[kind] or ""
                local kind_char = kind_text:sub(1, 1):lower()
                local detail = item.detail or ""

                local default_start = start_char
                local default_end = end_char

                local item_start, item_end
                if item.textEdit and item.textEdit.range then
                    item_start = item.textEdit.range.start.character
                    item_end = item.textEdit.range["end"].character
                else
                    item_start = default_start
                    item_end = default_end
                end
                if type(item_start) ~= "number" then item_start = default_start end
                if type(item_end) ~= "number" then item_end = default_end end
                item_start = math.max(0, item_start)
                item_end = math.min(#line_text, item_end)

                local user_data = {
                    _lsp_item = item,
                    start_char = item_start,
                    client_id = client_id,
                }

                -- Handle additional text edits (e.g., imports)
                if item.additionalTextEdits and #item.additionalTextEdits > 0 then
                    user_data.additionalTextEdits = item.additionalTextEdits
                end

                local is_function = (kind == 3 or kind == 4) -- Function or Method

                if item.insertTextFormat == 2 then
                    user_data._lsp_snippet = true
                    user_data.snippet_text = insert_text
                elseif is_function then
                    -- build a snippet when the server sends plain text only.
                    -- [%w_] keeps snake_case names whole, %w alone cuts at "_"
                    local func_name = insert_text:match("[%w_]+") or insert_text
                    local signature = detail ~= "" and detail or item.label
                    -- first paren group without nested parens, a greedy (.*) would
                    -- swallow return types like go "(n int, err error)"
                    local params_str = signature:match("%(([^()]*)%)")

                    local params = {}
                    if params_str then
                        for param in params_str:gmatch("([^,]+)") do
                            param = param:match("^%s*(.-)%s*$")
                            table.insert(params, param)
                        end
                    end

                    local param_placeholders = {}
                    for index, param in ipairs(params) do
                        table.insert(param_placeholders, string.format("${%d:%s}", index, param))
                    end

                    user_data._lsp_snippet = true
                    user_data.snippet_text = func_name .. "(" .. table.concat(param_placeholders, ", ") .. ")"
                end

                local word
                if user_data._lsp_snippet then
                    word = insert_text:match("[%w_]+") or item.label
                else
                    word = insert_text
                end

                table.insert(all_matches, {
                    word = word,
                    abbr = item.label,
                    kind = kind_char,
                    menu = kind_text,
                    info = item.documentation and (
                        type(item.documentation) == "string" and item.documentation or (item.documentation.value or "")
                    ) or "",
                    icase = 1,
                    dup = 1,
                    filter = item.filterText or word,
                    user_data = user_data
                })
            end

            -- fuzzy filter against what is already typed, vim.fn.complete does
            -- not filter pre-typed text by itself. Keep everything when nothing
            -- matches so the menu never turns up empty by surprise
            local matches = all_matches
            if base ~= "" then
                local filtered = vim.fn.matchfuzzy(all_matches, base, { key = "filter" })
                if #filtered > 0 then matches = filtered end
            end

            for _, match in ipairs(matches) do
                match.filter = nil
            end

            if vim.api.nvim_get_current_buf() == current_buf and vim.fn.mode() == "i" then
                vim.fn.complete(start_char + 1, matches)
            end
        end)

        return {}
    end
end

---

-- this config lsp/s
_G._prt_LSPS = {
    "lua_ls",
    "clangd", "neocmake",
    "rust_analyzer", "taplo",
    "gopls",
    "vtsls",
    "ts_ls",
    "zls",
    "roslyn_ls",
    "jdtls", "kotlin_lsp",
    "ruby_lsp",
    "protols",
    "svelte", "vue_ls",
    "gdscript", "gdshader_lsp",
    "dartls",
    "elixirls",
    "ruff", "basedpyright",
    "html", "tailwindcss", "cssls", -- "htmx-lsp",
    "jsonls",
    "markdown_oxide",
    "yamlls",
    "bashls",
    "sqls",
    "docker_language_server",
    "eslint",
}

_G._prt_TS = {
    "lua",
    "c", "cpp", "cmake",
    "rust",
    "zig", "ziggy", "ziggy_schema",
    "c_sharp",
    "go",
    "java", "kotlin",
    "ruby",
    "javascript", "typescript",
    "svelte", "vue",
    "gdscript", "gdshader",
    "dart",
    "elixir", "heex", "surface",
    "python",
    "html", "css", "scss", -- "drogon-csp",
    "json", -- "jsonc", "json5",
    "markdown", "typst",
    "yaml", "toml",
    "bash",
    "sql",
    "dockerfile",
}

---

vim.api.nvim_create_autocmd("CompleteDone", {
    callback = function()
        on_complete_done()
    end,
})
