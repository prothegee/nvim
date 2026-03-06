vim.pack.add({"git@github.com:ibhagwan/fzf-lua.git"})

local this = require"fzf-lua"

this.setup({
    buffers = {
        sort_lastused = false
    },
    files = {
        hidden = true,
        rg_opts = [[--no-ignore --hidden --files -g "!*.git"]],
        fd_opts = [[--no-ignore --hidden --type f --type l --exclude .git]],
    }
})
