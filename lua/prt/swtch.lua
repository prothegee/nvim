local M = {}

---

-- swith global indent
function M.global_indent(indent)
    local config_dir = vim.fn.stdpath("config")
    local file = config_dir .. "/options.json"

    if type(_G.write_json_file) ~= "function" then
        vim.notify("Error: _G.write_json_file not loaded", vim.log.levels.ERROR)
        return
    end

    local optionr = _G.read_json_file(file)
    local optionc = require"configs.option".config

    if optionr == nil then
        vim.notify("Error, can't use without options.json file", vim.log.levels.ERROR)
        return
    end
    if optionr.indent == indent then
        vim.notify("Nothing todo, indent and target is same", vim.log.levels.INFO)
        return
    end

    if indent == 2 then
        indent = 2
    elseif indent == 4 then
        indent = 4
    else
        indent = 4
    end

    optionc.indent = indent
    optionr.indent = indent

    local clean_data = {}
    for k, v in pairs(optionr) do
        local t = type(v)
        if t == "number" or t == "string" or t == "boolean" or t == "table" then
            clean_data[k] = v
        end
    end

    -- force_compact = false for pretty print with indentation
    local success = _G.write_json_file(file, clean_data, 4, false)
    if not success then
        vim.notify("Failed to write options.json", vim.log.levels.ERROR)
        return
    end

    -- Reload config without restart
    local optionf = vim.fn.stdpath("config") .. "/lua/settings/options.lua"
    if vim.fn.filereadable(optionf) == 1 then
        vim.cmd("source " .. optionf)
    end

    -- Apply indent settings immediately
    vim.opt.tabstop = indent
    vim.opt.shiftwidth = indent
    vim.opt.softtabstop = indent
    vim.opt.expandtab = true

    vim.notify("Indent updated to " .. indent .. ". Config reloaded.", vim.log.levels.INFO)
end

---

return M
