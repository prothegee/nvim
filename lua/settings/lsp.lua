-- local _cap = require"settings.capability"

local LSPS = {
    "lua_ls",
    "clangd", "neocmake",
    "rust_analyzer", "taplo",
    "gopls",
    "ts_ls",
    "zls",
    "protols",
    "svelte", "vue_ls",
    "gdscript", "gdshader_lsp",
    "basedpyright",
    "html", "cssls", -- "htmx-lsp",
    "jsonls",
    "markdown_oxide",
    "yamlls",
    "bashls",
    "sqls",
}

for _, lsp in ipairs(LSPS) do
    if lsp == "lua_ls" then
        vim.lsp.start({
            name = lsp,
            cmd = {"lua-language-server"},
            settings = {
                    Lua = {
                    runtime = {
                        version = "LuaJIT",
                        path = {
                            "lua/?.lua",
                            "lua/?/init.lua",
                            vim.fn.stdpath"config" .. "/lua"
                        }
                    },
                    workspace = {
                        library = {
                            "lua",
                            vim.env.VIMRUNTIME,
                            "${3rd}/luv/library",
                            vim.fn.expand "$VIMRUNTIME/lua",
                            vim.fn.stdpath"config" .. "/lua"
                        },
                        checkThirdParty = true
                    },
                    diagnostics = {
                        globals = { "vim" }
                    }
                }
            },
        })
    end
end

vim.lsp.enable(LSPS)
