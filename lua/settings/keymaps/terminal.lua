-- # open horizontal terminal
local function open_terminal_horizontal()
    -- check if we're currently in a terminal buffer
    if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "terminal" then
        local buf = vim.api.nvim_get_current_buf()
        local windows = vim.fn.win_findbuf(buf)

        vim.cmd("close")

        -- delete buffer if it was the only window showing it
        if #windows == 1 then
            vim.api.nvim_buf_delete(buf, { force = true })
        end

        return
    end

    local terminal_window
    local terminal_buffer

    -- check for visible terminal windows
    for _, window in ipairs(vim.api.nvim_list_wins()) do
        local buffer = vim.api.nvim_win_get_buf(window)
        if vim.api.nvim_get_option_value("buftype", { buf = buffer }) == "terminal" then
            terminal_window = window
            terminal_buffer = buffer
            break
        end
    end

    -- if terminal window exists and is valid, close it
    if terminal_window and vim.api.nvim_win_is_valid(terminal_window) then
        local windows = vim.fn.win_findbuf(terminal_buffer)

        vim.api.nvim_win_close(terminal_window, true)

        -- delete buffer if exists
        if #windows == 1 then
            vim.api.nvim_buf_delete(terminal_buffer, { force = true })
        end
    else
        -- look for existing terminal buffer (even if not visible)
        if not terminal_buffer then
            for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_get_option_value("buftype", { buf = buffer }) == "terminal" then
                    terminal_buffer = buffer
                    break
                end
            end
        end

        -- use existing terminal buffer or create new one
        if terminal_buffer then
            vim.cmd("botright 18split")
            local window = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(window, terminal_buffer)
        else
            vim.cmd("botright 18split | terminal")
        end
        vim.cmd("startinsert")
    end
end

---

-- integrated terminal
--- horizontal
vim.keymap.set(
    { "n", "i", "v", "t" },
    "<C-A-t>",
    open_terminal_horizontal,
    {
        desc = "terminal horizontal (mode: n, i, v, t)"
    }
)
