vim.schedule(function()
    require"settings.lsp"
    require"settings.treesitter"

    require"settings.global"
    require"settings.option"
    require"settings.diagnostic"
    require"settings.theme"

    require"settings.keymaps"
    require"settings.commands"
end)
