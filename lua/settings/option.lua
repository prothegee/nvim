vim.opt.updatetime = 30
vim.opt.timeoutlen = 150

local optf = vim.fn.stdpath("config") .. "/options.json"
local opt = _G.read_json_file(optf)

-- vim.opt.mouse = "nvi"

vim.opt.number = true

local default_indent = 4

if opt ~= nil and opt.indent >= 2 then
    vim.opt.tabstop = opt.indent
    vim.opt.shiftwidth = opt.indent
    vim.opt.softtabstop = opt.indent
else
    vim.opt.tabstop = default_indent
    vim.opt.shiftwidth = default_indent
    vim.opt.softtabstop = default_indent
end

if opt ~= nil and opt.line_number == 0 then
    vim.opt.number = false
    vim.opt.relativenumber = false
elseif opt ~= nil and opt.line_number == 1 then
    vim.opt.number = true
elseif opt ~= nil and opt.line_number == 2 then
    vim.opt.number = true
    vim.opt.relativenumber = true
elseif opt ~= nil and opt.line_number == 3 then
    vim.opt.number = false
    vim.opt.relativenumber = true
else
    vim.opt.number = true
end

vim.opt.smartindent = true
vim.opt.expandtab = true

vim.opt.fillchars = { eob = " " }

vim.opt.winborder = "rounded"

vim.opt.clipboard = "unnamedplus" -- check keymaps: "_d"0P

vim.opt.laststatus = 3

vim.opt.whichwrap:append "<>[]hl"
vim.opt.whichwrap:append "b,s"

vim.cmd([[
    syntax enable
    syntax on
]])

---

vim.opt.guicursor = "i:block-Cursor"
-- vim.opt.guicursor:append("a:blinkwait600-blinkon600-blinkoff600")

if vim.fn.executable("rg") == 1 then
    vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
    vim.opt.grepformat = "%f:%l:%c:%m"
end

---

-- vim.keymap.set("n", "p", function()
--     local txt = vim.fn.getreg("+")
--     -- Strip any trailing carriage returns or newlines
--     txt = txt:gsub("[\r\n]+$", "")
--     if txt == "" then return end
--     -- Put the cleaned text into the unnamed register as characterwise
--     vim.fn.setreg('"', txt, "v")
--     -- Paste it
--     vim.cmd('normal! ""p')
-- end, { desc = "Paste cleanly without trailing newlines" })

vim.keymap.set("i", "<C-p>", function()
    local txt = vim.fn.getreg("+")
    -- Strip trailing newlines
    txt = txt:gsub("[\r\n]+$", "")
    -- Insert the clean text at the cursor position
    vim.api.nvim_paste(txt, true, -1)
end, { desc = "Paste cleanly from clipboard in insert mode" })

-- vim.keymap.set("x", "p", function()
--     local txt = vim.fn.getreg("+")
--     txt = txt:gsub("%s+$", "")
--     if txt == "" then return end
--     -- Get the start and end marks of your visual selection
--     local start = vim.fn.getpos("'<")
--     local end_ = vim.fn.getpos("'>")
--     -- Exit visual mode
--     vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
--     -- Replace exactly what you highlighted using Neovim's native buffer API
--     vim.api.nvim_buf_set_text(0,
--         start[2] - 1, start[3] - 1,
--         end_[2] - 1, end_[3],
--         {txt}
--     )
-- end, { desc = "Replace visual block perfectly" }) -- has error
-- vim.keymap.set("x", "p", function()
--     local txt = vim.fn.getreg("+")
--     -- Strip trailing newlines and spaces
--     txt = txt:gsub("%s+$", "")
--     if txt == "" then return end
--
--     -- Put the cleaned text into register 'l' and force it to be characterwise ('v')
--     -- This guarantees it won't break the lines or push text down
--     vim.fn.setreg('l', txt, 'v')
--
--     -- gv = reselect the exact visual block/line
--     -- "l = use register 'l'
--     -- p = replace the selection
--     vim.api.nvim_feedkeys('gv"lp', 'nx', false)
-- end, { desc = "Replace visual selection safely" }) -- first visual or visual block not work
-- vim.keymap.set("x", "p", function()
--     local txt = vim.fn.getreg("+")
--     -- Strip trailing newlines and spaces
--     txt = txt:gsub("%s+$", "")
--     if txt == "" then return end
--
--     -- Put text into register 'l' as strictly characterwise ('v')
--     vim.fn.setreg('l', txt, 'v')
--
--     -- <Esc> exits visual mode (saving the marks)
--     -- gv reselects it
--     -- "lp replaces it
--     local keys = vim.api.nvim_replace_termcodes('<Esc>gv"lp', true, false, true)
--     vim.api.nvim_feedkeys(keys, 'nx', false)
-- end, { desc = "Replace visual selection safely" })
