_G.add_empty_line_at_end = function()
    local line_count = vim.api.nvim_buf_line_count(0)

    if line_count == 0 then
        return
    end

    local last_line_content = vim.api.nvim_buf_get_lines(0, line_count - 1, line_count, false)[1]

    local has_text = false
    local all_lines = vim.api.nvim_buf_get_lines(0, 0, line_count, false)
    for _, line in ipairs(all_lines) do
        if line:match("%S") then -- %S matches any non-whitespace character
            has_text = true
            break
        end
    end

    if not has_text then
        return
    end

    -- iff the last line is already empty (or just whitespace), do nothing
    if not last_line_content:match("%S") then
        return
    end

    -- append after the last line index
    vim.api.nvim_buf_set_lines(0, line_count, line_count, false, { "" })
end

