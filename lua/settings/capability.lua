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

return CAPABILITY
