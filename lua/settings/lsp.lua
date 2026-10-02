local M = {}

---

local cap = require"settings.capability"

---

local function find_root(bufnr, markers)
    return vim.fs.root(bufnr, markers)
end

local function find_angular_root(bufnr)
    local filename = vim.api.nvim_buf_get_name(bufnr)

    if filename == "" then
        return nil
    end

    local dir = vim.fs.dirname(filename)

    while dir do
        if vim.uv.fs_stat(vim.fs.joinpath(dir, "angular.json")) or vim.uv.fs_stat(vim.fs.joinpath(dir, "nx.json")) then
            return dir
        end

        -- A package.json establishes the project boundary.
        --
        -- Angular workspaces normally have angular.json and package.json
        -- at the same root, so this still detects normal Angular projects.
        if vim.uv.fs_stat(vim.fs.joinpath(dir, "package.json")) then
            return nil
        end

        local parent = vim.fs.dirname(dir)

        if parent == dir then
            break
        end

        dir = parent
    end

    return nil
end

local function find_js_root(bufnr)
    return find_root(bufnr, {
        "package-lock.json",
        "yarn.lock",
        "pnpm-lock.yaml",
        "bun.lockb",
        "bun.lock",
        "tsconfig.json",
        "jsconfig.json",
        "package.json",
        ".git",
    })
end

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
                },
            }
        }
    end

    -- -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#roslyn_ls
    -- if lsp == "roslyn_ls" then
    --     opts = {
    --         cmd = {
    --             "dotnet",
    --             -- please adjust bellow
    --             os.getenv("DOTNET_ROOT") .. "/lsp/content/LanguageServer/linux-x64/Microsoft.CodeAnalysis.LanguageServer.dll",
    --             os.getenv("DOTNET_ROOT") .. "/lsp/content/LanguageServer/linux-x64/Microsoft.CodeAnalysis.LanguageServer.dll",
    --             "--logLevel",
    --             "Information",
    --             "--extensionLogDirectory",
    --             vim.fs.joinpath(vim.uv.os_tmpdir(), "roslyn_ls/logs"),
    --             "--stdio",
    --         },
    --         filetypes = {
    --             "cs", "vb", "razor"
    --         },
    --         root_markers = { "*.sln", "*.csproj", "*.cs", "*.fsproj" },
    --         single_file_support = true,
    --         settings = {
    --             ["csharp|background_analysis"] = {
    --                 dotnet_analyzer_diagnostics_scope = "openFiles",
    --                 dotnet_compiler_diagnostics_scope = "openFiles",
    --             },
    --         },
    --     }
    -- end

    if lsp == "vtsls" then
        opts = {
            filetypes = {
                "javascript", "javascriptreact",
                "typescript", "typescriptreact",
                "vue"
            },

            root_dir = function(bufnr, on_dir)
                local angular_root = find_angular_root(bufnr)

                if angular_root then
                    return
                end

                local root = find_js_root(bufnr)

                if not root then
                    return
                end

                on_dir(root)
            end,

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

    if lsp == "angularls" then
        opts = {
            root_dir = function(bufnr, on_dir)
                local root = find_angular_root(bufnr)

                if not root then
                    return
                end

                on_dir(root)
            end,
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

    if lsp == "roslyn_ls" then
        vim.lsp.config(lsp, {})
    else
        vim.lsp.config(lsp, ocap)
    end

    vim.lsp.enable(lsp)
end

---

cap.default_completion()

---

return M
