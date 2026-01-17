local function _create_empty_new_tab()
    vim.cmd("tabnew")
end

local function _toggle_next_tab()
    vim.cmd("tabnext")
end

-- open new tab
-- mode:
-- - normal
-- - insert
-- - visual
-- - terminal
vim.keymap.set(
    { "n", "i", "v", "t" },
    "<C-A-S-t>",
    _create_empty_new_tab,
    {
        desc = "create empty new tab (mode: n, i, v, t)"
    }
)

-- togle new tab
vim.keymap.set(
    { "n", "i", "v", "t" },
    "<C-tab>",
    _toggle_next_tab,
    {
        desc = "toggle next tab (mode: n, i, v, t)"
    }
)

-- esc when insert mode will be place as current position
vim.api.nvim_set_keymap("i", "<Esc>",
    "<Esc>l",
{
    noremap = true,
    silent = true,
    desc = "Exit insert mode without moving cursor left"
})

-- navigate buffer left
vim.api.nvim_set_keymap("n", "<C-A-Left>",
    "<C-w>h",
{
    desc = "navigate buf left",
    silent = true,
    noremap = true
})
-- navigate buffer right
vim.api.nvim_set_keymap("n", "<C-A-Right>",
    "<C-w>l",
{
    desc = "navigate buf left",
    silent = true,
    noremap = true
})
-- navigate buffer up
vim.api.nvim_set_keymap("n", "<C-A-Up>",
    "<C-w>k",
{
    desc = "navigate buf up",
    silent = true,
    noremap = true
})
-- navigate buffer down
vim.api.nvim_set_keymap("n", "<C-A-Down>",
    "<C-w>j",
{
    desc = "navigate buf down",
    silent = true,
    noremap = true
})

vim.api.nvim_set_keymap("n", "<C-S-k>",
    "<cmd>DiagnosticShowFloatWindow<CR>",
{
    desc = "show floating window diagnostic",
    silent = true,
    noremap = true
})

vim.keymap.set("n", "<S-j>",
    vim.lsp.buf.definition,
{
    desc = "go to definition",
    silent = true,
    noremap = true
})

vim.keymap.set("n", "]d",
    function()
        vim.diagnostic.jump({ count = 1, float = true })
    end,
{
    desc = "go to next diagnostic",
    silent = true,
    noremap = true
})

vim.keymap.set("n", "[d",
    function()
        vim.diagnostic.jump({ count = -1, float = true })
    end,
{
    desc = "go to previous diagnostic",
    silent = true,
    noremap = true
})

vim.keymap.set("n", "<C-p>",
    function()
        vim.cmd("Xplrr")
    end,
{
    desc = "XPLRR init",
    silent = true,
    noremap = true
})

vim.keymap.set("n", "<C-S-p>",
    function()
        vim.cmd("Cmdc")
    end,
{
    desc = "CMDC init",
    silent = true,
    noremap = true
})

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

--[[
move each scroll by n
--]]
local N = 1
local _k = N .. "k"
local _j = N .. "j"

vim.keymap.set({"n"}, "<ScrollWheelUp>", _k)
-- vim.keymap.set({"i"}, "<ScrollWheelUp>", _k)
vim.keymap.set({"v"}, "<ScrollWheelUp>", _k)
vim.keymap.set({"n"}, "<ScrollWheelDown>", _j)
-- vim.keymap.set({"i"}, "<ScrollWheelDown>", _j)
vim.keymap.set({"v"}, "<ScrollWheelDown>", _j)
