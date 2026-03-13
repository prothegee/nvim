local M = {}

---

-- swith global indent
function M.global_indent(indent)
    local file = vim.fn.stdpath("config") .. "/option.json"
    local optionr = _G.read_json_file(file)
    local optionc = require"configs.option".config

    if optionr == nil then
        vim.notify("Error, can't use without option file", vim.log.levels.ERROR)
        return
    end
    if optionr.indent == indent then
        vim.notify("Nothing todo, indent and target is same", vim.log.levels.INFO)
        return
    end

    if indent <= 2 then indent = 2 end
    if indent == 3 then indent = 4 end
    if indent >= 4 then indent = 4 end

    optionc.indenx = indent

    _G.write_json_file(file, optionc, 4)

    local optionf = vim.fn.stdpath("config") .. "/lua/settings/option.lua"
    vim.cmd("so " .. optionf)
end

---

return M
