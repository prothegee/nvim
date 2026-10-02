vim.pack.add({"git@github.com:selimacerbas/live-server.nvim.git"})
-- replacement for markdown-previw
vim.pack.add({"git@github.com:selimacerbas/mdkite.nvim.git"})
-- vim.pack.add({"git@github.com:selimacerbas/markdown-preview.nvim.git"})

local M = {}

local this = require"mdkite"

M.port = 3333
M.debounce = 300
M.open_browser = true

this.setup({
    port = M.port,
    debounce_ms = M.debounce,
    open_browser = M.open_browser
})

return M

