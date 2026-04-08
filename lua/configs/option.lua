local M = {}

-- file:
-- ~/.config/nvim/options.json
M.config = {
    indent = 4,
    add_new_line = true,
    -- valid: nvim;vim
    scroll_type = "nvim",
    --[[
    valid:
    0:none
    1:just number
    2:relative number
    3:relative number 0 current
    --]]
    line_number = 3,
    --[[
    valid:
    0:omnifunc
    1:_prt_fuzzy_completion
    --]]
    omnifunc = 0,
}

return M

