local M = {}

---

--[[
@params
* omnifunc - 0:lsp.omnifunc 1:_prt_fuzzy_completion
--]]
function M.omnifunc(omnifunc)
    if omnifunc ~= 0 or omnifunc ~= 1 then
        vim.notify("Error: only accept 0,1")
        return
    end

    -- TODO:
    -- - Switch to omnifunc or _prt_fuzzy_completion
end

--[[
-- @note
-- - See options.json inside your nvim config
--
-- @params
-- line_number - 0:None 1:JustNumber 2:RelativeNumber 3:RelativeNumberZerrorCurrent
--]]
function M.line_number(line_number)
    if line_number ~= 0 or line_number ~= 1 or line_number ~= 2 or line_number ~= 3 then
        vim.notify("Error: only accept 0,1,2,3")
        return
    end

    local config_dir = vim.fn.stdpath("config")
    local file = config_dir .. "/options.json"

    if type(_G.write_json_file) ~= "function" then
        vim.notify("Error: _G.write_json_file not loaded", vim.log.levels.ERROR)
        return
    end

    local optionr = _G.read_json_file(file)
    local optionc = require"configs.option".config

    if optionr == nil then
        vim.notify("Error: can't use without options.json file", vim.log.levels.ERROR)
        return
    end
    if optionr.indent == line_number then
        vim.notify("Nothing todo, indent and target is same", vim.log.levels.INFO)
        return
    end

    optionc.line_number = line_number
    optionr.line_number = line_number

    local clean_data = {}
    for k, v in pairs(optionr) do
        local t = type(v)
        if t == "number" or t == "string" or t == "boolean" or t == "table" then
            clean_data[k] = v
        end
    end

    local compact = false
    local success = _G.write_json_file(file, clean_data, 4, compact)
    if not success then
        vim.notify("Failed to write options.json", vim.log.levels.ERROR)
        return
    end

    -- reload config without restart
    local optionf = vim.fn.stdpath("config") .. "/lua/settings/options.lua"
    if vim.fn.filereadable(optionf) == 1 then
        vim.cmd("source " .. optionf)
    end

    local line_number_str = ""

    -- immediate adjustment
    if line_number == 0 then
        vim.opt.number = false
        vim.opt.relativenumber = false

        line_number_str = "0:none"
    elseif line_number == 1 then
        vim.opt.number = true

        line_number_str = "1:just number"
    elseif line_number == 2 then
        vim.opt.number = true
        vim.opt.relativenumber = true

        line_number_str = "2:relative number"
    elseif line_number == 3 then
        vim.opt.number = false
        vim.opt.relativenumber = true

        line_number_str = "3:relative number 0 current"
    else
        vim.opt.number = true
        line_number_str = "2:as default"
    end

    vim.notify("LineNr updated to \"" .. line_number_str .. "\". Config reloaded.", vim.log.levels.INFO)
end

-- switch scroll type
-- @params scroll_type - string (valid: nvim;vim)
function M.scroll_type(scroll_type)
    local config_dir = vim.fn.stdpath("config")
    local file = config_dir .. "/options.json"

    if type(_G.write_json_file) ~= "function" then
        vim.notify("Error: _G.write_json_file not loaded", vim.log.levels.ERROR)
        return
    end

    local optionr = _G.read_json_file(file)
    local optionc = require"configs.option".config

    if optionr == nil then
        vim.notify("Error: can't use without options.json file", vim.log.levels.ERROR)
        return
    end
    if optionr.scroll_type == scroll_type then
        vim.notify("Nothing todo, indent and target is same", vim.log.levels.INFO)
        return
    end

    if scroll_type ~= "nvim" or scroll_type ~= "vim" then
        vim.notify("type of " .. scroll_type .. " is not supported; valid: nvim;vim", vim.logs.levels.INFO)
        return
    end

    optionc.scroll_type = scroll_type
    optionr.scroll_type = scroll_type

    local clean_data = {}
    for k, v in pairs(optionr) do
        local t = type(v)
        if t == "number" or t == "string" or t == "boolean" or t == "table" then
            clean_data[k] = v
        end
    end

    local compact = false
    local success = _G.write_json_file(file, clean_data, 4, compact)
    if not success then
        vim.notify("Failed to write options.json", vim.log.levels.ERROR)
        return
    end

    -- reload
    local keymapsf = vim.fn.stdpath("config") .. "/lua/settings/keymaps.lua"
    if vim.fn.filereadable(keymapsf) == 1 then
        vim.cmd("source " .. keymapsf)
    end

    -- immediate change
    if scroll_type == "vim" then
        local N = 1 -- by 1 line
        local _k = N .. "k"
        local _j = N .. "j"

        vim.keymap.set({"n"}, "<ScrollWheelUp>", _k)
        -- vim.keymap.set({"i"}, "<ScrollWheelUp>", _k)
        vim.keymap.set({"v"}, "<ScrollWheelUp>", _k)
        vim.keymap.set({"n"}, "<ScrollWheelDown>", _j)
        -- vim.keymap.set({"i"}, "<ScrollWheelDown>", _j)
        vim.keymap.set({"v"}, "<ScrollWheelDown>", _j)
    else
        vim.keymap.del({"n"}, "<ScrollWheelUp>")
        -- vim.keymap.del({"i"}, "<ScrollWheelUp>")
        vim.keymap.del({"v"}, "<ScrollWheelUp>")
        vim.keymap.del({"n"}, "<ScrollWheelDown>")
        -- vim.keymap.del({"i"}, "<ScrollWheelDown>")
        vim.keymap.del({"v"}, "<ScrollWheelDown>")
    end

    vim.notify("Scroll type updated to " .. scroll_type .. ". Config reloaded.", vim.log.levels.INFO)
end

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
        vim.notify("Error: can't use without options.json file", vim.log.levels.ERROR)
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

    local compact = false
    local success = _G.write_json_file(file, clean_data, 4, compact)
    if not success then
        vim.notify("Failed to write options.json", vim.log.levels.ERROR)
        return
    end

    -- reload config without restart
    local optionf = vim.fn.stdpath("config") .. "/lua/settings/options.lua"
    if vim.fn.filereadable(optionf) == 1 then
        vim.cmd("source " .. optionf)
    end

    -- immediate adjustment
    vim.opt.tabstop = indent
    vim.opt.shiftwidth = indent
    vim.opt.softtabstop = indent

    vim.notify("Indentation updated to " .. indent .. ". Config reloaded.", vim.log.levels.INFO)
end

---

return M

