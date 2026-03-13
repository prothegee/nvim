--[[
# return
etiher correct data or nil
--]]
_G.read_json_file = function(filepath)
    if not filepath or filepath == "" then
        return nil
    end

    local ok, content = pcall(vim.fn.readfile, filepath)
    if not ok then
        return nil
    end

    local json_string = table.concat(content, '\n')
    local valid, data = pcall(vim.fn.json_decode, json_string)
    if not valid then
        return nil
    end

    return data
end
