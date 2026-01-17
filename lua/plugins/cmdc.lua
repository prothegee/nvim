local CMDC = {}

--[[

# CMDC
CoMmanD Center

---

IMPORTANT:
- this tool is not complete

TODO:
- need to be able add command task inside cwd of .nvim dir, where:
    - it able to create some bash command at least
    - maybe do in ${CWD}/.nvim/cmdc.json
- some manual format config for ${CWD}/.nvim/cmdc.json
--]]

---

local config = {
    border = "rounded",
    max_commands = 1024,
    highlight_ns = vim.api.nvim_create_namespace("CMDC_HL"),
}

local state = {
    buf = nil,
    win = nil,
    original_win = nil,
    --[[
    example object below:
    commands = {
        ["command_1"] = function() print("command_1") end,
        ["command_1"] = function() print("command_2") end,
    }
    --]]
    commands = {},
    results = {},
    search_term = "",
    selected_index = 0,
    all_commands = {},           -- all available commands
    extmark_id = nil,            -- for highlighting
    buf_keymaps = {},            -- keymaps to clear
    win_closed_autocmd = nil,    -- window close tracker
    header_lines = 2,            -- fixed header lines
}

---

local function is_valid_buf(buf)
    return buf and vim.api.nvim_buf_is_valid(buf)
end

local function fuzzy_match(term, str)
    if #term == 0 then return true end
    term = term:lower()
    str = str:lower()

    local j = 1
    for i = 1, #term do
        local c = term:sub(i, i)
        local found = false

        while j <= #str do
            if str:sub(j, j) == c then
                found = true
                j = j + 1
                break
            end
            j = j + 1
        end
        if not found then return false end
    end
    return true
end

local function update_results()
    if #state.search_term == 0 then
        state.results = {}
        for i = 1, math.min(#state.all_commands, config.max_commands) do
            table.insert(state.results, state.all_commands[i])
        end
    else
        state.results = {}
        local matches = {}
        local lower_term = state.search_term:lower()

        for _, cmd in ipairs(state.all_commands) do
            local lower_cmd = cmd:lower()
            if fuzzy_match(lower_term, lower_cmd) then
                local score = 0
                local start_index = string.find(lower_cmd, lower_term, 1, true)

                if start_index then
                    score = start_index - 1000000
                else
                    local first_char = lower_term:sub(1, 1)
                    start_index = string.find(lower_cmd, first_char, 1, true) or 1
                    score = start_index
                end
                score = score + #cmd * 0.000001
                table.insert(matches, { cmd = cmd, score = score })
            end
        end

        table.sort(matches, function(a, b)
            if a.score == b.score then
                return a.cmd < b.cmd
            end
            return a.score < b.score
        end)

        for i = 1, math.min(#matches, config.max_commands) do
            table.insert(state.results, matches[i].cmd)
        end
    end

    if #state.results > 0 then
        if state.selected_index == 0 then
            -- keep in search input
        elseif state.selected_index > #state.results then
            state.selected_index = #state.results
        end
    else
        state.selected_index = 0
    end
end

local function close_window()
    -- remove window autocommand
    if state.win_closed_autocmd then
        pcall(vim.api.nvim_del_autocmd, state.win_closed_autocmd)
        state.win_closed_autocmd = nil
    end

    -- clear highlight
    if state.extmark_id and is_valid_buf(state.buf) then
        vim.api.nvim_buf_del_extmark(state.buf, config.highlight_ns, state.extmark_id)
    end

    -- remove keymaps
    if state.buf_keymaps and is_valid_buf(state.buf) then
        for _, keymap in ipairs(state.buf_keymaps) do
            local mode, lhs = keymap[1], keymap[2]
            pcall(vim.api.nvim_buf_del_keymap, state.buf, mode, lhs)
        end
        state.buf_keymaps = {}
    end

    -- close window
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_close(state.win, true)
    end
    state.buf = nil
    state.win = nil
    state.extmark_id = nil

    -- return to normal mode
    vim.api.nvim_command("stopinsert")
    if state.original_win and vim.api.nvim_win_is_valid(state.original_win) then
        vim.api.nvim_set_current_win(state.original_win)
        vim.api.nvim_command("stopinsert")
    end
end

local function run_command(command_name)
    local cmd_fn = state.commands[command_name]
    if cmd_fn and type(cmd_fn) == "function" then
        close_window()
        vim.schedule(cmd_fn)
    end
end

local function update_display()
    if not is_valid_buf(state.buf) then return end

    local display_lines = {
        "CMDC",
        "> " .. state.search_term
    }

    state.header_lines = #display_lines

    for i, result in ipairs(state.results) do
        local prefix = (state.selected_index == i) and "➤ " or "  "
        table.insert(display_lines, prefix .. result)
    end

    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, display_lines)

    -- clear previous highlight
    if state.extmark_id then
        vim.api.nvim_buf_del_extmark(state.buf, config.highlight_ns, state.extmark_id)
        state.extmark_id = nil
    end

    -- highlight selected line
    if state.selected_index > 0 then
        local line_index = state.header_lines + state.selected_index - 1
        state.extmark_id = vim.api.nvim_buf_set_extmark(
            state.buf,
            config.highlight_ns,
            line_index,
            0,
            {
                hl_group = "visual",
                end_line = line_index + 1,
                end_col = 0,
                priority = 100,
            }
        )
    end
end

local function create_window()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        return
    end

    state.original_win = vim.api.nvim_get_current_win()

    -- prepare command list
    state.all_commands = {}
    for name, _ in pairs(state.commands) do
        table.insert(state.all_commands, name)
    end
    table.sort(state.all_commands)

    state.search_term = ""
    state.selected_index = 0
    update_results()

    -- create buffer
    state.buf = vim.api.nvim_create_buf(false, true)
    if not is_valid_buf(state.buf) then
        vim.notify("failed to create cmdc buffer", vim.log.levels.ERROR)
        return
    end

    -- window dimensions
    local width = math.floor(vim.o.columns * 0.75)
    local height = math.floor(vim.o.lines * 0.50)

    -- window options
    local win_opts = {
        relative = "editor",
        width = width,
        height = height,
        col = (vim.o.columns - width) / 2,
        row = (vim.o.lines - height) / 2,
        style = "minimal",
        border = config.border,
        title = "Command Center",
        title_pos = "center",
    }

    -- create window
    state.win = vim.api.nvim_open_win(state.buf, true, win_opts)
    if not state.win or not vim.api.nvim_win_is_valid(state.win) then
        vim.notify("failed to create cmdc window", vim.log.levels.ERROR)
        return
    end

    -- buffer options
    vim.bo[state.buf].buftype = "nofile"
    vim.bo[state.buf].filetype = "cmdc"
    vim.bo[state.buf].swapfile = false
    vim.bo[state.buf].bufhidden = "wipe"

    -- navigation functions
    --- move up
    local function move_up()
        if state.selected_index == 0 then
            -- do nothing
        elseif state.selected_index == 1 then
            state.selected_index = 0
            update_display()
            vim.api.nvim_win_set_cursor(state.win, {state.header_lines, #state.search_term + 2})
            vim.api.nvim_command("startinsert")
            vim.fn.winrestview({topline = 1})
        else
            state.selected_index = state.selected_index - 1
            update_display()
            vim.api.nvim_win_set_cursor(state.win, {state.selected_index + state.header_lines, 0})
            if state.selected_index == 1 then
                vim.fn.winrestview({topline = 1})
            end
        end
    end
    --- move down
    local function move_down()
        if state.selected_index == 0 then
            if #state.results > 0 then
                state.selected_index = 1
                update_display()
                -- NOTE: this first navigate down has wrong consistent behaviour for the hightlight
                vim.api.nvim_win_set_cursor(state.win, {state.header_lines + state.selected_index - 1, 0})

                -- ensure header is visible
                vim.fn.winrestview({topline = 1})
            end
        elseif state.selected_index < #state.results then
            state.selected_index = state.selected_index + 1
            update_display()
            vim.api.nvim_win_set_cursor(state.win, {state.selected_index + state.header_lines, 0})

            -- ensure header is visible
            vim.fn.winrestview({topline = 1})
        end
    end

    local mappings = {
        {"n", "<CR>", function()
            if state.selected_index == 0 and #state.results > 0 then
                run_command(state.results[1])
            elseif state.selected_index > 0 then
                run_command(state.results[state.selected_index])
            end
        end, {buffer = state.buf}},

        {"i", "<CR>", function()
            if state.selected_index == 0 and #state.results > 0 then
                run_command(state.results[1])
            elseif state.selected_index > 0 then
                run_command(state.results[state.selected_index])
            end
        end, {buffer = state.buf}},

        -- {"n", "<Esc>", close_window, {buffer = state.buf}},
        -- {"i", "<Esc>", close_window, {buffer = state.buf}},
        {"n", "<C-q>", close_window, {buffer = state.buf}},
        {"i", "<C-q>", close_window, {buffer = state.buf}},

        {"n", "<Up>", move_up, {buffer = state.buf}},
        {"i", "<Up>", function()
            vim.api.nvim_command("stopinsert")
            move_up()
        end, {buffer = state.buf}},

        {"n", "<Down>", move_down, {buffer = state.buf}},
        {"i", "<Down>", function()
            vim.api.nvim_command("stopinsert")
            move_down()
        end, {buffer = state.buf}},

        {"n", "<C-n>", move_down, {buffer = state.buf}},
        {"i", "<C-n>", function()
            vim.api.nvim_command("stopinsert")
            move_down()
        end, {buffer = state.buf}},

        {"n", "<C-p>", move_up, {buffer = state.buf}},
        {"i", "<C-p>", function()
            vim.api.nvim_command("stopinsert")
            move_up()
        end, {buffer = state.buf}},

        {"n", "<Left>", "<Nop>", {buffer = state.buf}},
        {"n", "<Right>", "<Nop>", {buffer = state.buf}},
        {"i", "<Left>", "<Nop>", {buffer = state.buf}},
        {"i", "<Right>", "<Nop>", {buffer = state.buf}},
    }

    -- store and set keymaps
    state.buf_keymaps = {}
    for _, map in ipairs(mappings) do
        local mode, lhs = map[1], map[2]
        table.insert(state.buf_keymaps, {mode, lhs})
        vim.keymap.set(mode, lhs, map[3], map[4])
    end

    -- add printable character mappings to return to input field
    local printable_chars = ""
    for i = 32, 126 do
        printable_chars = printable_chars .. string.char(i)
    end

    for i = 1, #printable_chars do
        local char = printable_chars:sub(i, i)
        local mode = "n"
        local lhs = char
        local rhs = function()
            if state.selected_index > 0 then
                state.selected_index = 0
                state.search_term = state.search_term .. char
                update_results()
                update_display()
                vim.api.nvim_win_set_cursor(state.win, {state.header_lines, #state.search_term + 2})
                vim.api.nvim_command("startinsert")
            else
                vim.api.nvim_win_set_cursor(state.win, {state.header_lines, #state.search_term + 2})
                vim.api.nvim_command("startinsert")
                vim.api.nvim_feedkeys(char, 'i', false)
            end
        end

        table.insert(state.buf_keymaps, {mode, lhs})
        vim.keymap.set(mode, lhs, rhs, { buffer = state.buf, nowait = true })
    end

    local function restrict_cursor()
        local cursor = vim.api.nvim_win_get_cursor(state.win)
        local line = cursor[1]

        if line == 1 then
            vim.api.nvim_win_set_cursor(state.win, {2, 2})
        end

        if line > 1 and state.selected_index == 0 then
            vim.api.nvim_win_set_cursor(state.win, {2, #state.search_term + 2})
        end
    end

    -- handle input
    vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
        buffer = state.buf,
        callback = function()
            local lines = vim.api.nvim_buf_get_lines(state.buf, 0, state.header_lines, false)
            if #lines >= state.header_lines then
                local input = lines[state.header_lines]:sub(3)
                if input ~= state.search_term then
                    state.search_term = input
                    update_results()
                    update_display()
                    if state.selected_index == 0 then
                        vim.api.nvim_win_set_cursor(state.win, {state.header_lines, #state.search_term + 2})
                    end
                end
            end
        end
    })

    -- restrict cursor movement
    vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
        buffer = state.buf,
        callback = restrict_cursor
    })

    -- protect prefix
    vim.api.nvim_create_autocmd("TextChangedI", {
        buffer = state.buf,
        callback = function()
            local line = vim.api.nvim_get_current_line()
            if #line < 2 or line:sub(1,2) ~= "> " then
                vim.api.nvim_set_current_line("> " .. state.search_term)
                vim.api.nvim_win_set_cursor(state.win, {state.header_lines, #state.search_term + 2})
            end
        end
    })

    -- track window close
    state.win_closed_autocmd = vim.api.nvim_create_autocmd("WinClosed", {
        callback = function(args)
            if tonumber(args.match) == state.win then
                close_window()
            end
        end
    })

    -- initial display
    update_display()
    vim.api.nvim_command("startinsert")
    vim.api.nvim_win_set_cursor(state.win, {state.header_lines, #state.search_term + 2})

    vim.schedule(function()
        vim.notify("XPLRR: press ctrl+q to exit")
    end)
end

---

CMDC.cmd = {
    cmdc = "Cmdc"
}

CMDC.example_cmds = {
    ["CMDC: Hello"] = function()
        vim.schedule(function()
            vim.notify("CMDC: hello!", vim.log.levels.INFO)
        end)
    end,
}

---

function CMDC.setup(opts)
    opts = opts or {}

    -- options commands
    if opts.commands == nil then
        state.commands = CMDC.example_cmds
        vim.schedule(function()
            vim.notify("CMDC state.commands is not configured", vim.log.levels.INFO)
        end)
    else
        state.commands = opts.commands
    end
end

---

function CMDC.show()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        close_window()
    else
        create_window()
    end
end

---

vim.api.nvim_create_user_command(
    CMDC.cmd.cmdc,
    CMDC.show,
    {
        desc = "Command Center default launch",
    }
)

---

return CMDC
