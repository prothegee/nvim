local this_dir = vim.fn.stdpath("config") .. "/lua/settings"

for _, file in ipairs(vim.fn.readdir(this_dir)) do
    if file ~= "init.lua" and file:match("%.lua$") then
        require("settings." .. file:gsub("%.lua$", ""))
    end
end
