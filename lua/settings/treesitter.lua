local M = {}

local ts = require"nvim-treesitter.config"

local path_parser = vim.fn.stdpath("data") .. "/site/parser"

---

-- for some reason, this not loaded from fresh install
M.TS = {
    "lua",
    "c", "cpp", "cmake",
    "rust",
    "zig", "ziggy", "ziggy_schema",
    "c_sharp",
    "go",
    "java", "kotlin",
    "ruby",
    "javascript", "typescript",
    "svelte", "vue",
    "gdscript", "gdshader",
    "dart",
    "python",
    "html", "css", "scss", -- "drogon-csp",
    "json", -- "jsonc", "json5",
    "markdown", "typst",
    "yaml", "toml",
    "bash",
    "sql",
    "dockerfile",
}

ts.setup({
    ensure_installed = M.TS,
    auto_install = true,
    sync_install = true, -- ensured install all first
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
    },
})

---

vim.filetype.add(M.TS)
for _, lang in ipairs(M.TS) do
    vim.treesitter.language.add(lang)

    local parser = path_parser .. "/" .. lang .. ".so"
    -- since ts.setup not installing the lang parser,
    -- force add the parser if not exists
    if vim.fn.filereadable(parser) == 0 then
        vim.cmd("TSInstall " .. lang)
    end
end

---

return M
