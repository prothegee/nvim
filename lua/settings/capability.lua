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

function CAPABILITY.default_completion(client, buffer)
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

return CAPABILITY
