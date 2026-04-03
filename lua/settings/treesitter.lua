local M = {}

local ts = require"nvim-treesitter.config"

local path_parser = vim.fn.stdpath("data") .. "/site/parser"

---

ts.setup({
    ensure_installed = _G._prt_TS,
    auto_install = true,
    sync_install = true, -- ensured install all first
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
    },
})

---

vim.filetype.add(_G._prt_TS)
for _, lang in ipairs(_G._prt_TS) do
    vim.treesitter.language.add(lang)

    vim.schedule(function()
        local parser = path_parser .. "/" .. lang .. ".so"
        -- since ts.setup not installing the lang parser,
        -- force add the parser if not exists
        if vim.fn.filereadable(parser) == 0 then
            vim.cmd("TSInstall " .. lang)
        end
    end)
end

---

return M
