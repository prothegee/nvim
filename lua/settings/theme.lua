vim.cmd([[
    augroup InternalTheme
        autocmd ColorScheme * highlight Normal guibg=none guifg=none
        autocmd ColorScheme * highlight NormalNC guibg=none guifg=none

        autocmd ColorScheme * highlight LineNr guibg=none guifg=none

        autocmd ColorScheme * highlight NormalFloat guibg=none

        autocmd ColorScheme * highlight FloatBorder guibg=none guifg=#1a8712

        autocmd ColorScheme * highlight WinSeparator guibg=none guifg=#1a8712

    "" cmp
        autocmd colorscheme * highlight CmpItemAbbrDeprecatedDefault guibg=#6d6600
    augroup END

    colorscheme retrobox
]])

vim.opt.statusline = "  %{v:lua.get_active_current_mode()}   %{v:lua.get_trim_path_current_buffer(1)} %=  %{v:lua.get_active_lsp()}  %{v:lua.get_diagnostic_hint()}  %{v:lua.get_diagnostic_info()}  %{v:lua.get_diagnostic_warn()}  %{v:lua.get_diagnostic_error()}  󱪶 %l:󱪷 %c  󱗖 %p%% "
