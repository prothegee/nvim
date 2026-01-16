require"onedarkpro".setup({
    options = { transparency = true }
})

vim.cmd([[
    augroup InternalTheme
        autocmd!
        autocmd ColorScheme * highlight Normal guibg=none guifg=none
        autocmd ColorScheme * highlight NormalNC guibg=none guifg=none

        autocmd ColorScheme * highlight LineNr guibg=none guifg=none

        autocmd ColorScheme * highlight StatusLine guibg=#484848 guifg=#272727
        autocmd ColorScheme * highlight StatusLineNC guibg=#272727 guifg=#484848

        autocmd ColorScheme * highlight NormalFloat guibg=none
        autocmd ColorScheme * highlight FloatBorder guibg=none

        autocmd ColorScheme * highlight WinSeparator guibg=none guifg=#73370C

    "" pmenu
        autocmd ColorScheme * highlight Pmenu       guibg=none guifg=#73370C
        autocmd ColorScheme * highlight PmenuSel    guibg=#73370C guifg=#121212
        autocmd ColorScheme * highlight PmenuBorder guibg=#121212 guifg=#73370C
        autocmd ColorScheme * highlight PmenuSbar   guibg=#121212 guifg=#73370C
        autocmd ColorScheme * highlight PmenuThumb  guibg=#73370C guifg=#121212
    augroup END

    colorscheme onedark
]])

vim.g.go_highlight_functions = 1
-- vim.g.go_highlight_types = 1
-- vim.g.go_highlight_fields = 1
-- vim.g.go_highlight_operators = 1

vim.opt.statusline = "  %{v:lua.get_active_current_mode()}   %{v:lua.get_trim_path_current_buffer(1)} %=  %{v:lua.get_active_lsp()}  %{v:lua.get_diagnostic_hint()}  %{v:lua.get_diagnostic_info()}  %{v:lua.get_diagnostic_warn()}  %{v:lua.get_diagnostic_error()}  󱪶 %l:󱪷 %c  󱗖 %p%% "
