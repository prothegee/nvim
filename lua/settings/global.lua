vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.netrw_list_hide = ""
vim.g.netew_liststyle = 1

_G.get_active_lsp = function()
    local clients = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        table.insert(clients, client.name)
    end
    if #clients > 0 then
        return "" .. table.concat(clients, ", ") .. " "
    end
    return "n/a "
end

_G.get_active_current_mode = function()
    local mode_map = {
        n = "NORMAL",
        i = "INSERT",
        v = "VISUAL",
        V = "V-LINE",
        [""] = "V-BLOCK",  -- Ctrl-V
        c = "COMMAND",
        s = "SELECT",
        S = "S-LINE",
        [""] = "S-BLOCK",
        t = "TERMINAL",
        R = "REPLACE",
        ["!"] = "SHELL",
        r = "PROMPT",
    }
    local mode_code = vim.api.nvim_get_mode().mode
    return mode_map[mode_code] or string.upper(mode_code)
end

_G.get_trim_path_current_buffer = function(max_segments)
    max_segments = max_segments or 2 -- limit
    local fullpath = vim.api.nvim_buf_get_name(0)

    if fullpath == "" then
        return "[No Name]"
    end

    -- relative path
    local rel = vim.fn.fnamemodify(fullpath, ":.")

    local parts = {} -- as segments
    for part in string.gmatch(rel, "[^/]+") do
        table.insert(parts, part)
    end

    if #parts <= (max_segments + 1) then
        return rel
    end

    -- local trimmed = parts[1] .. "/../" .. parts[#parts]
    -- return trimmed
    return rel
end

_G.get_diagnostic_hint = function ()
    local diags = vim.diagnostic.get(0)

    local total = 0

    for _, diag in ipairs(diags) do
        if diag.severity == vim.diagnostic.severity.HINT then
            total = total + 1
        end
    end

    return total
end

_G.get_diagnostic_info = function ()
    local diags = vim.diagnostic.get(0)

    local total = 0

    for _, diag in ipairs(diags) do
        if diag.severity == vim.diagnostic.severity.INFO then
            total = total + 1
        end
    end

    return total
end

_G.get_diagnostic_warn = function ()
    local diags = vim.diagnostic.get(0)

    local total = 0

    for _, diag in ipairs(diags) do
        if diag.severity == vim.diagnostic.severity.WARN then
            total = total + 1
        end
    end

    return total
end

_G.get_diagnostic_error = function ()
    local diags = vim.diagnostic.get(0)

    local total = 0

    for _, diag in ipairs(diags) do
        if diag.severity == vim.diagnostic.severity.ERROR then
            total = total + 1
        end
    end

    return total
end

_G.get_cwd_and_file_buffer = function()
    local buf_name = vim.api.nvim_buf_get_name(0)

    if buf_name == "" then
        return "n/a"
    end

    -- using cwd of vim.fn.getcwd() make full path
    local relative_path = vim.fn.fnamemodify(buf_name, ":.")

    if relative_path == buf_name then
        relative_path = vim.fn.fnamemodify(buf_name, ":t")
    end

    return relative_path
end
