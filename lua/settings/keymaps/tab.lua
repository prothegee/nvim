local function _create_empty_new_tab()
    vim.cmd("tabnew")
end

local function _toggle_next_tab()
    vim.cmd("tabnext")
end

---

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
