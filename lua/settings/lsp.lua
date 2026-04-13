local M = {}

---

local cap = require"settings.capability"

---

for _, lsp in pairs(_G._prt_LSPS) do
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
    local opts = {}

    -- use this instead since will be extended
    local ocap = {
        on_init = cap.on_init,
        on_attach = cap.on_attach,
        capabilities = cap.capabilities
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

    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#roslyn_ls
    if lsp == "roslyn_ls" then
        opts = {
            cmd = {
                "dotnet",
                -- please adjust bellow
                os.getenv("DOTNET_ROOT") .. "/.nuget/content/LanguageServer/linux-x64/Microsoft.CodeAnalysis.LanguageServer.dll",
                "--logLevel",
                "Information",
                "--extensionLogDirectory",
                vim.fs.joinpath(vim.uv.os_tmpdir(), "roslyn_ls/logs"),
                "--stdio",
            },
            filetypes = {
                "cs", "vb"
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
                typescript = {
                    suggest = {
                        autoImports = true,
                    },
                },
                javascript = {
                    suggest = {
                        autoImports = true,
                    },
                },
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

    if lsp == "elixirls" then
        opts = {
            cmd = { os.getenv("DEVELOPMENT") .. "/bin/elixir/language_server.sh" },
            filetypes = { "elixir", "eelixir", "heex", "surface" }
        }
    end

    -- check opts before extend ocap
    if next(opts) ~= nil then
        ocap = vim.tbl_deep_extend("force", ocap, opts)
    end

    vim.lsp.config(lsp, ocap)

    vim.lsp.enable(lsp)
end

---

cap.default_completion()

---

return M
