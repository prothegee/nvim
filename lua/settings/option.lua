vim.opt.updatetime = 30
vim.opt.timeoutlen = 150

-- vim.opt.mouse = "nvi"

vim.opt.number = true

local optf = vim.fn.stdpath("config") .. "/options.json"
local opt = _G.read_json_file(optf)
local default_indent = 4

if opt ~= nil then
    vim.opt.tabstop = opt.indent
    vim.opt.shiftwidth = opt.indent
    vim.opt.softtabstop = opt.indent
else
    vim.opt.tabstop = default_indent
    vim.opt.shiftwidth = default_indent
    vim.opt.softtabstop = default_indent
end

vim.smartindent = true
vim.opt.expandtab = true

vim.opt.fillchars = { eob = " " }

vim.opt.winborder = "rounded"

vim.opt.clipboard = "unnamedplus" -- check keymaps: "_d"0P

vim.opt.laststatus = 3

vim.opt.whichwrap:append "<>[]hl"
vim.opt.whichwrap:append "b,s"

vim.cmd([[
    syntax enable
    syntax on
]])

---

vim.opt.guicursor = "i:block-blinkwait300-blinkoff600-blinkon900-Cursor"
