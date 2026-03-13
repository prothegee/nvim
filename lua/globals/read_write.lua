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

_G.write_json_file = function(filepath, data, indent_size)
    if not filepath or filepath == "" then
        return nil
    end

    local indent_count = indent_size or 4

    -- helper to recursively build pretty JSON
    local function encode_pretty(val, level)
        -- calculate indentation strings dynamically based on level and indent_count
        local current_indent = string.rep(" ", indent_count * level)
        local next_indent = string.rep(" ", indent_count * (level + 1))

        if type(val) == "table" then
            -- check if table is array-like or object-like
            local is_array = true
            local max_key = 0
            local count = 0

            for k, _ in pairs(val) do
                count = count + 1
                if type(k) ~= "number" or k < 1 or k ~= math.floor(k) then
                    is_array = false
                    break
                end
                if k > max_key then max_key = k end
            end

            -- if it's an array, ensure keys are sequential 1..n
            if is_array and count ~= max_key then
                is_array = false
            end

            if count == 0 then
                return is_array and "[]" or "{}"
            end

            local parts = {}
            if is_array then
                for _, v in ipairs(val) do
                    table.insert(parts, next_indent .. encode_pretty(v, level + 1))
                end
                return "[\n" .. table.concat(parts, ",\n") .. "\n" .. current_indent .. "]"
            else
                -- Object: iterate pairs (order is non-deterministic in Lua <5.3 without sorting, 
                -- but usually acceptable for configs. Add sorting if strict order needed)
                for k, v in pairs(val) do
                    local key_str = type(k) == "string" and ('"' .. k .. '"') or tostring(k)
                    table.insert(parts, next_indent .. key_str .. ": " .. encode_pretty(v, level + 1))
                end
                return "{\n" .. table.concat(parts, ",\n") .. "\n" .. current_indent .. "}"
            end
        elseif type(val) == "string" then
            -- basic escaping for strings
            local s = val:gsub('\\', '\\\\')
                       :gsub('"', '\\"')
                       :gsub('\n', '\\n')
                       :gsub('\r', '\\r')
                       :gsub('\t', '\\t')
            return '"' .. s .. '"'
        elseif type(val) == "boolean" then
            return val and "true" or "false"
        elseif type(val) == "number" then
            return tostring(val)
        elseif val == nil then
            return "null"
        else
            return "null" -- fallback for unsupported types (functions, etc)
        end
    end

    local ok, json_string = pcall(encode_pretty, data, 0)
    if not ok then
        return nil
    end

    local write_ok, result = pcall(vim.fn.writefile, { json_string }, filepath)
    if not write_ok or result == -1 then
        return nil
    end

    return true
end
