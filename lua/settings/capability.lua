local CAPABILITY = {}

CAPABILITY.capabilities = require("cmp_nvim_lsp").default_capabilities()
CAPABILITY.capabilities.textDocument = {
    completion = {
        contextsupport = true,
        dynamicregistration = true,
        completionitem = {
            tagsupport = { valueset = { 1 } },
            snippetsupport = true,
            resolvesupport = {
                properties = { "detail", "documentation", "additionalTextEdits", "snippets" }
            },
            preselectsupport = true,
            deprecatedsupport = true,
            labeldetailssupport = true,
            documentationformat = { "markdown", "plaintext" },
            insertreplacesupport = true,
            inserttextmodesupport = {
                valueset = { 1, 2 }
            },
            commitcharacterssupport = true,
            enable_completions = true
        }
    },
    diagnostic = {
        dynamicRegistration = true
    },
    inlineCompletion = { dynamicRegistration = true },
    semanticTokens = {
        multilineTokenSupport = true,
    }
}
CAPABILITY.capabilities.workspace = {
    diagnostics = { refreshSupport = true }
}

local _default_completion = function(buffer)
    vim.wildmode = "longest:full, full"
    vim.opt.shortmess:append("c")
    vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }
    vim.opt.wildignorecase = true
end

function CAPABILITY.default_completion(_, buffer)
    _default_completion(buffer)
end

function CAPABILITY.on_init(client, buffer)
    if client:supports_method("textDocument/semanticTokens") then
        client.server_capabilities.semanticTokensProvider = nil
    end
end

function CAPABILITY.on_attach(client, buffer)
    _default_completion(buffer)
end

---

-- BufEnter
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function(args)
        local buffer = args.buf

        -- if not vim.api.nvim_buf_is_valid(buffer) then return end

        _default_completion(buffer)

        -- cmake: syntax case
        if vim.bo.filetype == "cmake" then
           vim.cmd("syntax off")
        end
    end
})
-- BufEnter
vim.api.nvim_create_autocmd("BufLeave", {
    pattern = "*",
    callback = function(args)
        local buffer = args.buf

        -- if not vim.api.nvim_buf_is_valid(buffer) then return end

        -- cmake: syntax case
        if vim.bo.filetype == "cmake" then
           vim.cmd("syntax on")
        end
    end
})
-- LspAttach
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local buffer = args.buf
        local buffer_name = vim.api.nvim_buf_get_name(buffer)

        -- if not vim.api.nvim_buf_is_valid(buffer) then return end
        -- if not client then return end
        -- if buffer_name == "" then return end

        _default_completion(buffer)
        CAPABILITY.on_attach(client, buffer)
    end
})
-- -- InsertCharPre 
-- vim.api.nvim_create_autocmd("InsertCharPre", {
--     callback = function(args)
--         local buffer = args.buf
--
--         if not vim.api.nvim_buf_is_valid(buffer) then return end
--         if vim.api.nvim_buf_get_name(buffer) == "" then return end
--
--         if vim.bo[buffer].omnifunc ~= "" and vim.fn.mode() == "i" and vim.fn.pumvisible() == 0 then
--             vim.defer_fn(function()
--                 -- validate state first, prevent close buffer
--                 if vim.api.nvim_buf_is_valid(buffer) and
--                    vim.api.nvim_get_current_buf() == buffer and
--                    vim.fn.mode() == "i" then
--                     vim.fn.feedkeys(vim.api.nvim_replace_termcodes(
--                         OMNIFUNC_CALLBACK.PRT_FUZZY_COMPLETION,
--                         true, true, true
--                     ), "n")
--                 end
--             end, COMPLETION_DELAY)
--         end
--     end
-- })
-- -- TextChangedI
-- vim.api.nvim_create_autocmd("TextChangedI", {
--     callback = function(args)
--         local buffer = args.buf
--
--         if not vim.api.nvim_buf_is_valid(buffer) then return end
--         if vim.api.nvim_buf_get_name(buffer) == "" then return end
--
--         if vim.fn.mode() == "i" and vim.fn.pumvisible() == 0 then
--             vim.defer_fn(function()
--                 -- validate state first, prevent close buffer
--                 if vim.api.nvim_buf_is_valid(buffer) and
--                    vim.api.nvim_get_current_buf() == buffer and
--                    vim.fn.mode() == "i" then
--                     vim.fn.feedkeys(vim.api.nvim_replace_termcodes(
--                         OMNIFUNC_CALLBACK.PRT_FUZZY_COMPLETION,
--                         true, true, true
--                     ), "n")
--                 end
--             end, COMPLETION_DELAY)
--         end
--     end
-- })
-- FileType
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
        local buffer = args.buf
        -- if not vim.api.nvim_buf_is_valid(buffer) then return end

        _default_completion(buffer)
    end
})
-- BufNewFile & BufRead
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    -- force file .h to c ad not c++
    pattern = "*.h",
    callback = function()
        if vim.bo.filetype == "" or vim.bo.filetype == "cpp" then
            vim.bo.filetype = "c"
        end
    end
})
-- -- CompleteDone
-- vim.api.nvim_create_autocmd("CompleteDone", {
--     pattern = "*",
--     callback = _handle_complete_done
-- })

---

return CAPABILITY
