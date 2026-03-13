vim.opt.updatetime = 30
vim.opt.timeoutlen = 150

-- vim.opt.mouse = "nvi"

vim.opt.number = true

local option_fp = vim.fn.stdpath("config") .. "/option.json"
local option_read = _G.read_json_file(option_fp)
local default_indent = 4

if option_read ~= nil then
    vim.opt.tabstop = option_read.indent
    vim.opt.shiftwidth = option_read.indent
    vim.opt.softtabstop = option_read.indent
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

vim.opt.guicursor = "n-v-c:block,i:block-blinkwait300-blinkoff600-blinkon900-Cursor"
