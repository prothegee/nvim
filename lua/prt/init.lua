local this_dir = vim.fn.stdpath("config") .. "/lua/prt"

for _, file in ipairs(vim.fn.readdir(this_dir)) do
    if file ~= "init.lua" and file:match("%.lua$") then
	require("prt." .. file:gsub("%.lua$", ""))
    end
end
