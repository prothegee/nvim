--[[
# NETRW ICONS

netrw.nvim draws icons when the "modified" option of a netrw buffer changes.
On this Neovim version that event is not reliable. When netrw lists a buffer
again (for example after the active window moves away and back), the event may
not fire and the icons stay gone.

netrw always fires FileType netrw while it builds the listing, so this file
renders the icons from that event. The render waits a short delay because
FileType fires before the listing is written into the buffer.
--]]

local RENDER_DELAY_MS = 50

-- Supported netrw list styles: 0 - thin, 1 - long, 3 - tree
local SUPPORTED_LIST_STYLES = { [0] = true, [1] = true, [3] = true }

--- Draw the icon signs of one netrw buffer.
---
--- Param:
--- bufnr - number (buffer to render, skipped when it is not the active one)
local function render_netrw_buffer(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    if vim.api.nvim_get_current_buf() ~= bufnr then return end
    if vim.bo[bufnr].filetype ~= "netrw" then return end
    if not SUPPORTED_LIST_STYLES[vim.b[bufnr].netrw_liststyle] then return end

    -- Force the sign column so the icon signs have a column to render in.
    vim.opt_local.signcolumn = "yes"

    require("netrw.ui").embelish(bufnr)
    require("netrw.actions").bind(bufnr)
end

local netrw_augroup = vim.api.nvim_create_augroup("PrtNetrwIcons", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = netrw_augroup,
    pattern = "netrw",
    callback = function(args)
        vim.defer_fn(function()
            render_netrw_buffer(args.buf)
        end, RENDER_DELAY_MS)
    end,
})
