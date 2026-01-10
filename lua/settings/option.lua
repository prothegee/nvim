vim.opt.updatetime = 60
vim.opt.timeoutlen = 120

vim.opt.showmode = false
vim.opt.number = false
vim.opt.relativenumber = true

-- start tab
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.softtabstop = 4
-- end tab

vim.opt.fillchars = { eob = " " }
-- greeter
-- vim.opt.shortmess:append "sI"
-- vim.opt.whichwrap:append "<>[]hl"

-- rounded single double shadow
vim.opt.winborder = "rounded"

-- ensure split vertical when press v in netrw
vim.opt.splitright = true

--[[
custom opt clipboard
--]]
vim.opt.clipboard = "unnamedplus"

-- check imap.lua; pressing esc will move forward 1 step
vim.opt.virtualedit = "onemore"
