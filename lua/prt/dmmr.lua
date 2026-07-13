--[[
# DMMR
DiMMeR

## Behavior
- Dims the rendered text of inactive windows so the active one stands out
- Works through window-local highlight namespaces, every highlight group
  gets a copy with its fg scaled toward black
- Backgrounds are never touched, terminal transparency stays intact
- Rebuilds the dimmed palette on ColorScheme

## Note
- Floating windows are never dimmed
- When focus moves into a floating window, the layout keeps its last state
  (the window under the float stays bright)
--]]
local M = {}

local config = {
    dim = 0.55,
    fallback_fg = "#c0c0c0",
    exclude_filetypes = {},
    exclude_buftypes = { "prompt" },
}

local state = {
    ns = vim.api.nvim_create_namespace("PRT_DMMR"),
    enabled = true,
}

--- Scale a 24-bit rgb color toward black
---
--- Param:
--- color - integer (24-bit rgb value as returned by nvim_get_hl)
--- factor - number (0 is black, 1 keeps the color unchanged)
---
--- Return:
--- - integer (scaled 24-bit rgb value)
local function dim_color(color, factor)
    local red = math.floor(color / 65536) % 256
    local green = math.floor(color / 256) % 256
    local blue = color % 256

    red = math.floor(red * factor)
    green = math.floor(green * factor)
    blue = math.floor(blue * factor)

    return (red * 65536) + (green * 256) + blue
end

local function parse_hex(hex)
    local cleaned = hex:gsub("#", "")

    return tonumber(cleaned, 16)
end

--- Fill the dim namespace with darkened copies of every global highlight
--- group. Links are resolved first so the copy carries real colors.
local function build_namespace()
    local groups = vim.api.nvim_get_hl(0, {})

    for name, definition in pairs(groups) do
        local resolved = definition
        if definition.link then
            resolved = vim.api.nvim_get_hl(0, { name = name, link = false })
        end

        local dimmed = vim.tbl_extend("force", {}, resolved)
        dimmed.link = nil
        if dimmed.fg then
            dimmed.fg = dim_color(dimmed.fg, config.dim)
        end
        if dimmed.sp then
            dimmed.sp = dim_color(dimmed.sp, config.dim)
        end

        pcall(vim.api.nvim_set_hl, state.ns, name, dimmed)
    end

    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    local base_fg = normal.fg or parse_hex(config.fallback_fg)

    vim.api.nvim_set_hl(state.ns, "Normal", {
        fg = dim_color(base_fg, config.dim),
        bg = normal.bg,
    })
end

local function is_float(win)
    return vim.api.nvim_win_get_config(win).relative ~= ""
end

local function should_dim(win)
    if is_float(win) then
        return false
    end

    local buf = vim.api.nvim_win_get_buf(win)
    if vim.tbl_contains(config.exclude_filetypes, vim.bo[buf].filetype) then
        return false
    end
    if vim.tbl_contains(config.exclude_buftypes, vim.bo[buf].buftype) then
        return false
    end

    return true
end

--- Sweep all windows of the current tabpage, the active window keeps the
--- default namespace and every other regular window gets the dim namespace
local function apply()
    local current_win = vim.api.nvim_get_current_win()
    if is_float(current_win) then
        return
    end

    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if not state.enabled or win == current_win or not should_dim(win) then
            vim.api.nvim_win_set_hl_ns(win, -1)
        else
            vim.api.nvim_win_set_hl_ns(win, state.ns)
        end
    end
end

M.cmd = {
    dmmr_toggle = "DmmrToggle",
}

function M.toggle()
    state.enabled = not state.enabled

    apply()
end

--- Namespace id of the dimmed palette, exposed for tests
function M.ns()
    return state.ns
end

function M.is_enabled()
    return state.enabled
end

function M.setup(opts)
    opts = opts or {}
    if opts.dim ~= nil then
        config.dim = opts.dim
    end
    if opts.fallback_fg ~= nil then
        config.fallback_fg = opts.fallback_fg
    end
    if opts.exclude_filetypes ~= nil then
        config.exclude_filetypes = opts.exclude_filetypes
    end
    if opts.exclude_buftypes ~= nil then
        config.exclude_buftypes = opts.exclude_buftypes
    end

    local augroup = vim.api.nvim_create_augroup("PRT_DMMR", { clear = true })

    vim.api.nvim_create_autocmd("ColorScheme", {
        group = augroup,
        callback = function()
            vim.schedule(function()
                build_namespace()
                apply()
            end)
        end,
    })

    vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "TabEnter" }, {
        group = augroup,
        callback = apply,
    })

    vim.api.nvim_create_user_command(M.cmd.dmmr_toggle, M.toggle, { desc = "DMMR: toggle inactive window dimming" })

    build_namespace()
    apply()
end

---

return M
