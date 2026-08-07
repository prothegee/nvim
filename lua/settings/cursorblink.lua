--[[
# CURSORBLINK
drive the cursor blink from inside neovim.

on niri with alacritty the terminal side blink does not run while the window
sits idle from first open, so the block stays steady until a manual focus
change. toggling the terminal cursor visibility on a timer sends bytes to the
terminal on every step, which forces a redraw and shows a real blink that does
not wait for a focus change.
--]]

local uv = vim.uv or vim.loop

-- cursor stays shown for this many ms, then hidden for the same, and repeats
local BLINK_MS = 600

local blink_timer = nil
local cursor_shown = true

local function write_terminal(sequence)
    -- stderr shares the terminal but is not the tui render stream, so writing
    -- here does not interleave with neovim drawing the screen
    pcall(vim.fn.chansend, vim.v.stderr, sequence)
end

local function toggle_cursor()
    cursor_shown = not cursor_shown

    -- DECTCEM show (?25h) or hide (?25l)
    write_terminal(cursor_shown and "\27[?25h" or "\27[?25l")
end

local function stop_blink()
    if not blink_timer then
        return
    end

    blink_timer:stop()
    blink_timer:close()
    blink_timer = nil

    cursor_shown = true
    write_terminal("\27[?25h")
end

local function start_blink()
    if blink_timer then
        return
    end

    blink_timer = uv.new_timer()
    blink_timer:start(BLINK_MS, BLINK_MS, vim.schedule_wrap(toggle_cursor))
end

local function has_terminal_ui()
    return #vim.api.nvim_list_uis() > 0
end

local function resume_blink()
    if has_terminal_ui() then
        start_blink()
    end
end

local group = vim.api.nvim_create_augroup("PrtCursorBlink", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = resume_blink,
})

-- blink only while this window has focus, sit steady when it does not
vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = resume_blink,
})

vim.api.nvim_create_autocmd("FocusLost", {
    group = group,
    callback = stop_blink,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = stop_blink,
})
