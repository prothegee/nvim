vim.cmd([[
    augroup InternalTheme
        autocmd ColorScheme * highlight Normal guibg=none guifg=none
        autocmd ColorScheme * highlight NormalNC guibg=none guifg=none
        "autocmd ColorScheme * highlight Normal guibg=none guifg=#646464 gui=NONE
        "autocmd ColorScheme * highlight NormalNC guibg=none guifg=#121212 gui=underdotted

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

