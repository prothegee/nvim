vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.netrw_list_hide = ""
vim.g.netrw_liststyle = 0

local this_dir = vim.fn.stdpath("config") .. "/lua/globals"

for _, file in ipairs(vim.fn.readdir(this_dir)) do
    if file ~= "init.lua" and file:match("%.lua$") then
	require("globals." .. file:gsub("%.lua$", ""))
    end
end
