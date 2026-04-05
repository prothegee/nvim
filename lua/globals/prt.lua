--[[
-- Completion was triggered by typing an identifier (24x7 code
-- Complete), manual invocation (e.g ctrl+p) or via api.
1:invoked
2:triggercharacter
3:triggerforincompletecompletions
--]]
local TRIGGER_KIND = 3

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

    -- Apply additional text edits first (for imports, etc.)
    if user_data.additionalTextEdits and #user_data.additionalTextEdits > 0 then
        local offset_encoding = get_offset_encoding(bufnr)
        vim.lsp.util.apply_text_edits(user_data.additionalTextEdits, bufnr, offset_encoding)
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
        }, function(err, result, _)
            if not vim.api.nvim_buf_is_valid(current_buf) or vim.api.nvim_get_current_buf() ~= current_buf or vim.fn.mode() ~= "i" then
                return
            end

            if err or not result then
                return
            end

            local items = result.items or result

            if not items then
                return
            end

            local all_matches = {}

            for _, item in ipairs(items) do
                local label = item.textEdit and item.textEdit.newText or item.label
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
                }

                -- Handle additional text edits (e.g., imports)
                if item.additionalTextEdits and #item.additionalTextEdits > 0 then
                    user_data.additionalTextEdits = item.additionalTextEdits
                end

                local is_function = (kind == 3 or kind == 4) -- Function or Method
                local has_native_snippet = (item.insertTextFormat == 2 and item.insertText)

                if has_native_snippet then
                    user_data._lsp_snippet = true
                    user_data.snippet_text = item.insertText
                elseif is_function then
                    -- Extract function name from label (first word)
                    local func_name = label:match("^(%w+)") or label
                    -- Get signature from detail (preferred) or label
                    local signature = detail ~= "" and detail or label
                    -- Extract parameters between parentheses
                    local params_str = signature:match("%((.*)%)")
                    local params = {}
                    if params_str then
                        for p in params_str:gmatch("([^,]+)") do
                            p = p:match("^%s*(.-)%s*$")
                            table.insert(params, p)
                        end
                    end
                    if #params > 0 then
                        local param_placeholders = {}
                        for i, p in ipairs(params) do
                            table.insert(param_placeholders, string.format("${%d:%s}", i, p))
                        end
                        local snippet_text = func_name .. "(" .. table.concat(param_placeholders, ", ") .. ")"
                        user_data._lsp_snippet = true
                        user_data.snippet_text = snippet_text
                    else
                        user_data.snippet_text = func_name .. "()"
                    end
                end

                local word
                if user_data._lsp_snippet then
                    local name = label:match("^(%w+)") or label
                    word = name
                else
                    word = item.insertText or label
                end

                table.insert(all_matches, {
                    word = word,
                    abbr = label,
                    kind = kind_char,
                    menu = kind_text,
                    info = item.documentation and (
                        type(item.documentation) == "string" and item.documentation or (item.documentation.value or "")
                    ) or "",
                    icase = 1,
                    dup = 1,
                    user_data = user_data
                })
            end

            if vim.api.nvim_get_current_buf() == current_buf and vim.fn.mode() == "i" then
                vim.fn.complete(start_char + 1, all_matches)
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
    -- "ts_ls",
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
