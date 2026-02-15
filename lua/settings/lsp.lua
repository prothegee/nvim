local _cap = require"settings.capability"

local LSPS = {
    "lua_ls",
    "clangd", "neocmake",
    "rust_analyzer", "taplo",
    "gopls",
    "vtsls",
    "ts_ls",
    "zls",
    "jdtls", "kotlin_lsp",
    "ruby_lsp",
    "protols",
    "svelte", "vue_ls",
    "gdscript", "gdshader_lsp",
    "basedpyright",
    "html", "tailwindcss", "cssls", -- "htmx-lsp",
    "jsonls",
    "markdown_oxide",
    "yamlls",
    "bashls",
    "sqls",
    "docker_language_server",
    "eslint",
}

for _, lsp in pairs(LSPS) do
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
    local opts = {}

    -- use this instead since will be extended
    local ocap = {
        on_init = _cap.on_init,
        on_attach = _cap.on_attach,
        capabilities = _cap.capabilities
    }

    if lsp == "lua_ls" then
        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls
        opts.settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                    path = {
                        "lua/?.lua",
                        "lua/?/init.lua",
                        vim.fn.stdpath("config") .. "/lua"
                    }
                },
                workspace = {
                    library = {
                        "lua",
                        vim.env.VIMRUNTIME,
                        "${3rd}/luv/library",
                        vim.fn.expand "$VIMRUNTIME/lua",
                        vim.fn.stdpath("config") .. "/lua"
                    },
                    checkThirdParty = true
                },
                diagnostics = {
                    globals = { "vim" }
                }
            }
        }
    end

    if lsp == "vtsls" then
        opts = {
            filetypes = {
                "javascript", "javascriptreact",
                "typescript", "typescriptreact",
                "vue"
            },
            settings = {
                vtsls = {
                    tsserver = {
                        globalPlugins = {
                            {
                                cmd = {"vue-language-server", "--stdio"},
                                -- install this globally, using:
                                -- - npm i -g @vue/typescript-plugin
                                -- or
                                -- - bun i -g @vue/typescript-plugin
                                name = "@vue/typescript-plugin",
                                languages = { "vue" },
                                configNamespace = "typescript",
                            },
                        },
                    },
                },
            },
        }
    end

    -- check opts before extend ocap
    if next(opts) ~= nil then
        ocap = vim.tbl_deep_extend("force", ocap, opts)
    end

    vim.lsp.config(lsp, ocap)

    vim.lsp.enable(lsp)
end

_cap.default_completion()
