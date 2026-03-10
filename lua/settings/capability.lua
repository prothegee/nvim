local M = {}

---

--[[
-- params:
-- _ - buffer
--]]
local _default_completion = function(_)
    vim.wildmode = "longest:full,full"

    vim.opt.shortmess:append("c")
    vim.opt.completeopt = {"menu", "menuone", "noinsert", "noselect"}
    vim.opt.wildignorecase = true

    vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
end

---

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument = {
    completion = {
        contextSupport = true,
        dynamicRegistration = true,
        completionItem = {
            tagSupport = { valueSet = { 1 } },
            snippetSupport = true,
            resolveSupport = {
                properties = { "detail", "documentation", "additionalTextEdits", "snippets" }
            },
            preselectSupport = true,
            deprecatedSupport = true,
            labeldetailsSupport = true,
            documentationFormat = { "markdown", "plaintext" },
            insertReplaceSupport = true,
            insertTextModeSupport = {
                valueSet = { 1, 2 }
            },
            commitCharactersSupport = true,
            enable_completions = true
        }
    },
    diagnostic = {
        dynamicRegistration = true
    },
    inlineCompletion = { dynamicRegistration = true },
    -- semanticTokens = {
    --     multilineTokenSupport = true,
    -- }
}
M.capabilities.workspace = {
    diagnostics = { refreshSupport = true }
}

function M.default_completion(client, buffer)
    _default_completion(buffer)
end

function M.on_init(client, buffer)
    if client:supports_method("textDocument/semanticTokens") then
        client.server_capabilities.semanticTokensProvider = nil
    end
end

function M.on_attach(client, buffer)
    _default_completion(buffer)
end

---

return M

