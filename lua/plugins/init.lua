local this_dir = vim.fn.stdpath("config") .. "/lua/plugins"

for _, file in ipairs(vim.fn.readdir(this_dir)) do
    if file ~= "init.lua" and file:match("%.lua$") then
	require("plugins." .. file:gsub("%.lua$", ""))
    end
end

-- internal
require"prt"
