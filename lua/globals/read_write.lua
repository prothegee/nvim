--[[
# return
either correct data or nil
--]]
_G.read_json_file = function(filepath)
    if not filepath or filepath == "" then
        return nil
    end

    if vim.fn.filereadable(filepath) == 0 then
        return nil
    end

    local ok, content = pcall(vim.fn.readfile, filepath)
    if not ok or not content then
        return nil
    end

    local json_string = table.concat(content, '\n')

    if json_string == "" then
        return nil
    end

    local valid, data = pcall(vim.fn.json_decode, json_string)
    if not valid then
        return nil
    end

    return data
end

_G.write_json_file = function(filepath, data, indent_size, force_compact)
    if not filepath or filepath == "" then
        return nil
    end

    if data == nil then
        return nil
    end

    -- Ensure parent directory exists
    local dir = vim.fn.fnamemodify(filepath, ":h")
    if vim.fn.isdirectory(dir) == 0 then
        local mk_ok = pcall(vim.fn.mkdir, dir, "p")
        if not mk_ok then
            return nil
        end
    end

    local indent_count = indent_size or 4
    local json_string

    -- If force_compact, use simple encode
    if force_compact == true then
        local ok, result = pcall(vim.fn.json_encode, data)
        if not ok or not result or type(result) ~= "string" then
            return nil
        end
        json_string = result
    else
        -- Pretty print with proper indentation
        local ok, result = pcall(_G._json_encode_pretty, data, 0, indent_count)
        if not ok or not result then
            -- Fallback to compact if pretty fails
            local ok2, result2 = pcall(vim.fn.json_encode, data)
            if not ok2 then
                return nil
            end
            json_string = result2
        else
            json_string = result
        end
    end

    -- Split into lines
    local lines = {}
    for line in json_string:gmatch("[^\r\n]+") do
        if type(line) == "string" and line ~= "" then
            table.insert(lines, line)
        end
    end

    if #lines == 0 then
        lines = { "{}" }
    end

    -- Write the file
    local result = vim.fn.writefile(lines, filepath)

    if result == -1 then
        return nil
    end

    return true
end

-- Internal helper for pretty JSON encoding
_G._json_encode_pretty = function(val, level, indent_count)
    local current_indent = string.rep(" ", indent_count * level)
    local next_indent = string.rep(" ", indent_count * (level + 1))

    if type(val) == "table" then
        -- Check if array or object
        local is_array = true
        local max_key = 0
        local count = 0

        for k, _ in pairs(val) do
            count = count + 1
            if type(k) ~= "number" or k < 1 or k ~= math.floor(k) then
                is_array = false
                break
            end
            if k > max_key then
                max_key = k
            end
        end

        if is_array and count ~= max_key then
            is_array = false
        end

        if count == 0 then
            return is_array and "[]" or "{}"
        end

        local parts = {}
        if is_array then
            for _, v in ipairs(val) do
                local ok, encoded = pcall(_G._json_encode_pretty, v, level + 1, indent_count)
                if ok then
                    table.insert(parts, next_indent .. encoded)
                end
            end
            return "[\n" .. table.concat(parts, ",\n") .. "\n" .. current_indent .. "]"
        else
            for k, v in pairs(val) do
                local key_str = type(k) == "string" and ('"' .. k .. '"') or tostring(k)
                local ok, encoded = pcall(_G._json_encode_pretty, v, level + 1, indent_count)
                if ok then
                    table.insert(parts, next_indent .. key_str .. ": " .. encoded)
                end
            end
            return "{\n" .. table.concat(parts, ",\n") .. "\n" .. current_indent .. "}"
        end
    elseif type(val) == "string" then
        local s = val:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r'):gsub('\t', '\\t')
        return '"' .. s .. '"'
    elseif type(val) == "boolean" then
        return val and "true" or "false"
    elseif type(val) == "number" then
        return tostring(val)
    elseif val == nil then
        return "null"
    else
        return "null"
    end
end
