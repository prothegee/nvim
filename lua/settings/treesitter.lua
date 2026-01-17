local _ts = require"nvim-treesitter"

local TREESITTERS = {
    "lua",
    "c", "cpp", "cmake",
    "rust",
    "go",
    "ziggy", "ziggy_schema",
    "javascript", "typescript",
    "svelte", "vue",
    "gdscript", "gdshader",
    "python",
    "html", "css", "scss", -- "drogon-csp",
    "json", "jsonc", "json5",
    "markdown", "typst",
    "yaml", "toml",
    "bash",
    "sql",
}

for _, ts in pairs(TREESITTERS) do
    vim.treesitter.language.add(ts)
end

_ts.setup{
    ensure_installed = TREESITTERS,
    auto_install = true,
    sync_install = true,
    hightlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
    }
}

