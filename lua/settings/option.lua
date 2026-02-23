vim.opt.updatetime = 60
vim.opt.timeoutlen = 600

-- vim.opt.mouse = "nvi"

vim.opt.number = true

local option_fp = vim.fn.stdpath("config") .. "/option.json"
local opt = _G.read_json_file(option_fp)

if opt ~= nil then
    vim.opt.tabstop = opt.indent
    vim.opt.shiftwidth = opt.indent
    vim.opt.softtabstop = opt.indent
    print("NOTE: option.json found; using " .. opt.indent .. " indent")
else
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.softtabstop = 4
    print("NOTE: option.json not found; using 4 indent")
end

vim.smartindent = true
vim.opt.expandtab = true

vim.opt.fillchars = { eob = " " }

vim.opt.winborder = "rounded"

vim.opt.clipboard = "unnamedplus"

vim.opt.laststatus = 3

vim.opt.whichwrap:append "<>[]hl"
vim.opt.whichwrap:append "b,s"
