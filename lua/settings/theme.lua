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
    augroup END

    colorscheme onedark

    "set cursorline
]])
-- vim.api.nvim_set_hl(0, 'CursorLine', { underline = true })

vim.opt.statusline = "  %{v:lua.get_active_current_mode()}   %{v:lua.get_trim_path_current_buffer(1)} %=  %{v:lua.get_active_lsp()}  %{v:lua.get_diagnostic_hint()}  %{v:lua.get_diagnostic_info()}  %{v:lua.get_diagnostic_warn()}  %{v:lua.get_diagnostic_error()}  󱪶 %l:󱪷 %c  󱗖 %p%% "

