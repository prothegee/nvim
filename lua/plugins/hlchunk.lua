vim.pack.add({"git@github.com:shellRaining/hlchunk.nvim.git"})

local delay = 60

require"hlchunk".setup({
    chunk = {
        enable = true,
        delay = delay
    },
    indent = {
        enable = true,
        delay = delay,
        style = {
            "#484848"
        }
    },
    line_num = {
        enable = true,
        delay = delay
    },
    blank = {
        enable = false
    },
    context = {
        enable = false
    }
})
