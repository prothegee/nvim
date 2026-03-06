local path_cfg = vim.fn.stdpath("config")
local path_opt = vim.fn.stdpath("data") .. "/site/pack/core/opt"

for _, path in ipairs(vim.fn.glob(path_cfg .. "/lua", true, true)) do
    if vim.fn.isdirectory(path) then
        vim.opt.rtp:append(path)
    end
end
for _, path in ipairs(vim.fn.glob(path_opt .. "/*", true, true)) do
    if vim.fn.isdirectory(path) then
        vim.opt.rtp:append(path)

        local luadir = path .. "/lua"

        if vim.fn.isdirectory(luadir) then
            vim.opt.rtp:append(luadir)
        end
    end
end

require("globals")
require("plugins")
require("settings")
