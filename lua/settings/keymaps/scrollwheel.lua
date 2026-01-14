--[[
move each scroll by n
--]]
local N = 1
local _k = N .. "k"
local _j = N .. "j"

vim.keymap.set({"n"}, "<ScrollWheelUp>", _k)
-- vim.keymap.set({"i"}, "<ScrollWheelUp>", _k)
vim.keymap.set({"v"}, "<ScrollWheelUp>", _k)
vim.keymap.set({"n"}, "<ScrollWheelDown>", _j)
-- vim.keymap.set({"i"}, "<ScrollWheelDown>", _j)
vim.keymap.set({"v"}, "<ScrollWheelDown>", _j)
