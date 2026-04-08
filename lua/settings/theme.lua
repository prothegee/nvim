--[[
NOTE:
optiojs for:
- gui:
    - underdotted
    - bold
    - italic
    - underline
    - undercurl
    - underdouble
    - underdashed
    - strikethrough
    - reverse
    - inverse
    - standout
--]]

vim.cmd([[
    augroup InternalTheme
        autocmd!
        autocmd ColorScheme * highlight Normal guibg=none guifg=none gui=NONE
        autocmd ColorScheme * highlight NormalNC guibg=none guifg=none gui=italic

        autocmd ColorScheme * highlight LineNr guibg=none guifg=none

        autocmd ColorScheme * highlight NormalFloat guibg=none

        autocmd ColorScheme * highlight FloatBorder guibg=none guifg=#1a8712

        autocmd ColorScheme * highlight WinSeparator guibg=none guifg=#1a8712

        autocmd ColorScheme * highlight LineNr guibg=none guifg=#646464
        autocmd ColorScheme * highlight LineNrAbove guibg=none guifg=#464646
        autocmd ColorScheme * highlight LineNrBelow guibg=none guifg=#464646
        autocmd ColorScheme * highlight SignColumn guibg=none

        autocmd ColorScheme * highlight CursorLineNr guibg=none
        autocmd ColorScheme * highlight CursorLineSign guibg=none

    "" cmp: legacy (deprecated completion bg color)
    "    autocmd colorscheme * highlight CmpItemAbbrDeprecatedDefault guibg=#6d6600
    augroup END

    set cursorline
    set list
    set lcs+=space:·

    colorscheme retrobox
]])

vim.opt.statusline = "  %{v:lua.get_active_current_mode()}   %{v:lua.get_trim_path_current_buffer(1)} %=  %{v:lua.get_active_lsp()} 󰊢 %{v:lua.get_git_branch()} %{v:lua.get_git_short()}   %{v:lua.get_diagnostic_hint()}  %{v:lua.get_diagnostic_info()}  %{v:lua.get_diagnostic_warn()}  %{v:lua.get_diagnostic_error()}  L%l:C%c  󱗖 %p%% "

vim.opt.pumheight = 24
-- vim.opt.pummaxheight = 12
vim.opt.pumblend = 0
-- vim.opt.pumwidth = 48
vim.opt.pummaxwidth = 75
-- "single", "double", "rounded", "bold"
vim.opt.pumborder = "rounded"

vim.api.nvim_set_hl(0, "Pmenu", { bg = "none", fg = "#606060" })
vim.api.nvim_set_hl(0, "PmenuExtra", { bg = "none", fg = "#606060" })

vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#4b4b4b", fg = "#eaeaea" })
vim.api.nvim_set_hl(0, "PmenuExtraSel", { bg = "#4b4b4b", fg = "#eaeaea" })

vim.api.nvim_set_hl(0, "PmenuKind", { bg = "#242424", fg = "#b3b3b3" })
vim.api.nvim_set_hl(0, "PmenuKindSel", { bg = "#242424", fg = "#d3d3d3" })

vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#242424", fg="red" })

vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#4b4b4b" })

vim.api.nvim_set_hl(0, "PmenuBorder", { bg = "none", fg="#1a8712" })
