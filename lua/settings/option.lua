vim.opt.updatetime = 30
vim.opt.timeoutlen = 150

local optf = vim.fn.stdpath("config") .. "/options.json"
local opt = _G.read_json_file(optf)

-- vim.opt.mouse = "nvi"

vim.opt.number = true

local default_indent = 4

if opt ~= nil and opt.indent >= 2 then
    vim.opt.tabstop = opt.indent
    vim.opt.shiftwidth = opt.indent
    vim.opt.softtabstop = opt.indent
else
    vim.opt.tabstop = default_indent
    vim.opt.shiftwidth = default_indent
    vim.opt.softtabstop = default_indent
end

if opt ~= nil and opt.line_number == 0 then
    vim.opt.number = false
    vim.opt.relativenumber = false
elseif opt ~= nil and opt.line_number == 1 then
    vim.opt.number = true
elseif opt ~= nil and opt.line_number == 2 then
    vim.opt.number = true
    vim.opt.relativenumber = true
elseif opt ~= nil and opt.line_number == 3 then
    vim.opt.number = false
    vim.opt.relativenumber = true
else
    vim.opt.number = true
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

if vim.fn.executable("rg") == 1 then
    vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
    vim.opt.grepformat = "%f:%l:%c:%m"
end

---

vim.opt.pumheight = 24
-- vim.opt.pummaxheight = 12
vim.opt.pumblend = 6
-- vim.opt.pumwidth = 48
vim.opt.pummaxwidth = 75
-- "single", "double", "rounded", "bold"
vim.opt.pumborder = "rounded"
vim.opt.pumborder = ""

