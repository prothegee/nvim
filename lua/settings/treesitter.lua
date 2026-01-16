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
require"nvim-treesitter.config".setup({
    ensure_installed = TREESITTERS,
    auto_install = true,
    sync_install = false,
    highlight = {
        enable = true,
        -- additional_vim_regex_highlighting = TREESITTERS,
        disable = {"go"}
    }
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
        local buffer = args.buf
        local filetype = vim.bo[buffer].filetype

        for _, treesitter in pairs(TREESITTERS) do
            if treesitter == filetype then
                if vim.treesitter.language.add(treesitter) then
                    vim.treesitter.start(buffer, treesitter)
                    -- vim.bo[buffer].syntax = "enable"
                    vim.bo[buffer].syntax = "ON"

                    -- local cmd = "TSBufEnable " .. treesitter
                    -- vim.cmd(cmd)
                end
                break
            end
        end
    end,
})
