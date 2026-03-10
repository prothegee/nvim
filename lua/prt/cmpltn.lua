--[[
# CMPLTN
CoMPLeTion
--]]
local M = {}

local state = { active = false }
local start_col = 0

local function get_snippet_text(item)
    if item.insertTextFormat == 2 then
        return item.insertText
    end
    return nil
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

function M.trigger_completion()
    if vim.fn.mode() ~= "i" then return end

    local bufnr = vim.api.nvim_get_current_buf()
    local winid = vim.api.nvim_get_current_win()
    local col = vim.api.nvim_win_get_cursor(winid)[2]
    local line = vim.api.nvim_buf_get_lines(bufnr, vim.api.nvim_win_get_cursor(winid)[1] - 1, vim.api.nvim_win_get_cursor(winid)[1], false)[1] or ""
    local match = line:sub(1, col):match("[%w_]*$") or ""
    start_col = col - #match

    local params = vim.lsp.util.make_position_params(winid, "utf-8")
    local completion_params = {
        textDocument = params.textDocument,
        position = params.position,
        context = { triggerKind = 1 },
    }

    vim.lsp.buf_request(bufnr, "textDocument/completion", completion_params, function(err, result)
        if err or not result then return end

        local items = result.items or result
        local completions = {}

        for _, item in ipairs(items) do
            local word = item.insertText or item.label
            local completion_item = {
                abbr = item.label,
                word = word,
                menu = item.detail or "",
                icase = 1,
                dup = 0,
            }

            if item.insertTextFormat == 2 then
                local snippet_text = get_snippet_text(item)
                if snippet_text then
                    completion_item.user_data = vim.json.encode({
                        _lsp_snippet = true,
                        snippet_text = snippet_text,
                        start_col = start_col,
                    })
                end
            end

            table.insert(completions, completion_item)
        end

        if #completions > 0 then
            vim.fn.complete(start_col + 1, completions)
        end
    end)
end

function M.on_complete_done()
    local completed_item = vim.v.completed_item
    if not completed_item then
        return
    end

    local snippet_text = nil
    local sc = start_col

    if completed_item.user_data then
        local ok, data = pcall(vim.json.decode, completed_item.user_data)
        if ok and data and data._lsp_snippet then
            snippet_text = data.snippet_text
            sc = data.start_col or start_col
        elseif type(completed_item.user_data) == "table" and
            completed_item.user_data.nvim and
            completed_item.user_data.nvim.lsp and
            completed_item.user_data.nvim.lsp.completion_item then
            local lsp_item = completed_item.user_data.nvim.lsp.completion_item
            if lsp_item.insertTextFormat == 2 and lsp_item.insertText then
                snippet_text = lsp_item.insertText
            end
        end
    end

    if snippet_text then
        local bufnr = vim.api.nvim_get_current_buf()
        local winid = vim.api.nvim_get_current_win()
        local cursor = vim.api.nvim_win_get_cursor(winid)
        local row = cursor[1] - 1
        local col = cursor[2]
        local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
        local before = line:sub(1, sc)
        local after = line:sub(col + 1)
        local cleaned_line = before .. after

        vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, { cleaned_line })
        vim.api.nvim_win_set_cursor(winid, { row + 1, sc })

        local success = insert_snippet(snippet_text)
        if success then
            state.active = true
        end
    end
end

function M.next()
    if state.active then
        local ok = pcall(function() vim.snippet.jump(1) end)
        if not ok then state.active = false end
        return true
    end
    return false
end

function M.prev()
    if state.active then
        local ok = pcall(function() vim.snippet.jump(-1) end)
        if not ok then state.active = false end
        return true
    end
    return false
end

function M.is_active() return state.active end
function M.reset()
    state.active = false
    start_col = 0
end

function M.setup(opts)
    opts = opts or {}
    if vim.fn.has("nvim-0.12") == 0 then
        vim.notify("prt.cmpltn requires Neovim 0.12+", vim.log.levels.ERROR)
        return false
    end
    if not vim.snippet then
        vim.notify("vim.snippet not available", vim.log.levels.ERROR)
        return false
    end

    local orig = vim.lsp.protocol.make_client_capabilities
    vim.lsp.protocol.make_client_capabilities = function()
        local caps = orig()
        if caps.textDocument and caps.textDocument.completion then
            caps.textDocument.completion.completionItem =
                caps.textDocument.completion.completionItem or {}
            caps.textDocument.completion.completionItem.snippetSupport = true
        end
        if caps.textDocument then
            caps.textDocument.semanticTokens = {
                dynamicRegistration = false,
                tokenTypes = { "namespace", "type", "class", "function", "variable" },
                tokenModifiers = { "declaration", "definition", "readonly", "static" },
                formats = { "relative" },
                requests = { range = true, full = { delta = true } },
            }
        end
        return caps
    end

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function(ev)
            vim.keymap.set("i", "<C-x><C-o>", function()
                M.trigger_completion()
            end, { buffer = ev.buf, desc = "LSP snippet completion" })
        end,
    })

    vim.keymap.set("i", "<Tab>", function()
        if M.is_active() then return M.next() else return "<Tab>" end
    end, { expr = true })

    vim.keymap.set("i", "<S-Tab>", function()
        if M.is_active() then return M.prev() else return "<S-Tab>" end
    end, { expr = true })

    vim.api.nvim_create_autocmd("CompleteDone", {
        callback = function()
            M.on_complete_done()
        end,
    })

    vim.api.nvim_create_autocmd("InsertLeave", { callback = function() M.reset() end })

    vim.notify("prt.cmpltn loaded", vim.log.levels.INFO)
    return true
end

return M
