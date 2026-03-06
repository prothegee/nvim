--[[
# CMDP
CoMmanD Palette

---
TODO:
- need to be able add command task inside cwd of .nvim dir, where:
    - it able to create some bash command at least
    - maybe do in ${CWD}/.nvim/cmdp.json
- some manual format M.config.for ${CWD}/.nvim/cmdp.json
--]]
local M = {}

M.cmd = "Cmdp"

M.version = {
    major = 0,
    minor = 1,
    patch = 0
}

M.config = {
    border = "rounded",
    max_commands = 1024,
    highlight_ns = vim.api.nvim_create_namespace("CMDP_HL"),
}

M.state = {
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
    if #M.state.search_term == 0 then
        M.state.results = {}
        for i = 1, math.min(#M.state.all_commands, M.config.max_commands) do
            table.insert(M.state.results, M.state.all_commands[i])
        end
    else
        M.state.results = {}
        local matches = {}
        local lower_term = M.state.search_term:lower()

        for _, cmd in ipairs(M.state.all_commands) do
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

        for i = 1, math.min(#matches, M.config.max_commands) do
            table.insert(M.state.results, matches[i].cmd)
        end
    end

    if #M.state.results > 0 then
        if M.state.selected_index == 0 then
            -- keep in search input
        elseif M.state.selected_index > #M.state.results then
            M.state.selected_index = #M.state.results
        end
    else
        M.state.selected_index = 0
    end
end

local function close_window()
    -- remove window autocommand
    if M.state.win_closed_autocmd then
        pcall(vim.api.nvim_del_autocmd, M.state.win_closed_autocmd)
        M.state.win_closed_autocmd = nil
    end

    -- clear highlight
    if M.state.extmark_id and is_valid_buf(M.state.buf) then
        vim.api.nvim_buf_del_extmark(M.state.buf, M.config.highlight_ns, M.state.extmark_id)
    end

    -- remove keymaps
    if M.state.buf_keymaps and is_valid_buf(M.state.buf) then
        for _, keymap in ipairs(M.state.buf_keymaps) do
            local mode, lhs = keymap[1], keymap[2]
            pcall(vim.api.nvim_buf_del_keymap, M.state.buf, mode, lhs)
        end
        M.state.buf_keymaps = {}
    end

    -- close window
    if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
        vim.api.nvim_win_close(M.state.win, true)
    end
    M.state.buf = nil
    M.state.win = nil
    M.state.extmark_id = nil

    -- return to normal mode
    vim.api.nvim_command("stopinsert")
    if M.state.original_win and vim.api.nvim_win_is_valid(M.state.original_win) then
        vim.api.nvim_set_current_win(M.state.original_win)
        vim.api.nvim_command("stopinsert")
    end
end

local function run_command(command_name)
    local cmd_fn = M.state.commands[command_name]
    if cmd_fn and type(cmd_fn) == "function" then
        close_window()
        vim.schedule(cmd_fn)
    end
end

local function update_display()
    if not is_valid_buf(M.state.buf) then return end

    local display_lines = {
        "CMDP",
        "> " .. M.state.search_term
    }

    M.state.header_lines = #display_lines

    for i, result in ipairs(M.state.results) do
        local prefix = (M.state.selected_index == i) and "➤ " or "  "
        table.insert(display_lines, prefix .. result)
    end

    vim.api.nvim_buf_set_lines(M.state.buf, 0, -1, false, display_lines)

    -- clear previous highlight
    if M.state.extmark_id then
        vim.api.nvim_buf_del_extmark(M.state.buf, M.config.highlight_ns, M.state.extmark_id)
        M.state.extmark_id = nil
    end

    -- highlight selected line
    if M.state.selected_index > 0 then
        local line_index = M.state.header_lines + M.state.selected_index - 1
        M.state.extmark_id = vim.api.nvim_buf_set_extmark(
            M.state.buf,
            M.config.highlight_ns,
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
    if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
        return
    end

    M.state.original_win = vim.api.nvim_get_current_win()

    -- prepare command list
    M.state.all_commands = {}
    for name, _ in pairs(M.state.commands) do
        table.insert(M.state.all_commands, name)
    end
    table.sort(M.state.all_commands)

    M.state.search_term = ""
    M.state.selected_index = 0
    update_results()

    -- create buffer
    M.state.buf = vim.api.nvim_create_buf(false, true)
    if not is_valid_buf(M.state.buf) then
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
        border = M.config.border,
        title = "Command Palette",
        title_pos = "center",
    }

    -- create window
    M.state.win = vim.api.nvim_open_win(M.state.buf, true, win_opts)
    if not M.state.win or not vim.api.nvim_win_is_valid(M.state.win) then
        vim.notify("failed to create cmdc window", vim.log.levels.ERROR)
        return
    end

    -- buffer options
    vim.bo[M.state.buf].buftype = "nofile"
    vim.bo[M.state.buf].filetype = "cmdc"
    vim.bo[M.state.buf].swapfile = false
    vim.bo[M.state.buf].bufhidden = "wipe"

    -- navigation functions
    --- move up
    local function move_up()
        if M.state.selected_index == 0 then
            -- do nothing
        elseif M.state.selected_index == 1 then
            M.state.selected_index = 0
            update_display()
            vim.api.nvim_win_set_cursor(M.state.win, {M.state.header_lines, #M.state.search_term + 2})
            vim.api.nvim_command("startinsert")
            vim.fn.winrestview({topline = 1})
        else
            M.state.selected_index = M.state.selected_index - 1
            update_display()
            vim.api.nvim_win_set_cursor(M.state.win, {M.state.selected_index + M.state.header_lines, 0})
            if M.state.selected_index == 1 then
                vim.fn.winrestview({topline = 1})
            end
        end
    end
    --- move down
    local function move_down()
        if M.state.selected_index == 0 then
            if #M.state.results > 0 then
                M.state.selected_index = 1
                update_display()
                -- NOTE: this first navigate down has wrong consistent behaviour for the hightlight
                vim.api.nvim_win_set_cursor(M.state.win, {M.state.header_lines + M.state.selected_index - 1, 0})

                -- ensure header is visible
                vim.fn.winrestview({topline = 1})
            end
        elseif M.state.selected_index < #M.state.results then
            M.state.selected_index = M.state.selected_index + 1
            update_display()
            vim.api.nvim_win_set_cursor(M.state.win, {M.state.selected_index + M.state.header_lines, 0})

            -- ensure header is visible
            vim.fn.winrestview({topline = 1})
        end
    end

    local mappings = {
        {"n", "<CR>", function()
            if M.state.selected_index == 0 and #M.state.results > 0 then
                run_command(M.state.results[1])
            elseif M.state.selected_index > 0 then
                run_command(M.state.results[M.state.selected_index])
            end
        end, {buffer = M.state.buf}},

        {"i", "<CR>", function()
            if M.state.selected_index == 0 and #M.state.results > 0 then
                run_command(M.state.results[1])
            elseif M.state.selected_index > 0 then
                run_command(M.state.results[M.state.selected_index])
            end
        end, {buffer = M.state.buf}},

        {"n", "<Esc>", close_window, {buffer = M.state.buf}},
        {"i", "<Esc>", close_window, {buffer = M.state.buf}},
        {"n", "<C-q>", close_window, {buffer = M.state.buf}},
        {"i", "<C-q>", close_window, {buffer = M.state.buf}},

        {"n", "<Up>", move_up, {buffer = M.state.buf}},
        {"i", "<Up>", function()
            vim.api.nvim_command("stopinsert")
            move_up()
        end, {buffer = M.state.buf}},

        {"n", "<Down>", move_down, {buffer = M.state.buf}},
        {"i", "<Down>", function()
            vim.api.nvim_command("stopinsert")
            move_down()
        end, {buffer = M.state.buf}},

        {"n", "<C-n>", move_down, {buffer = M.state.buf}},
        {"i", "<C-n>", function()
            vim.api.nvim_command("stopinsert")
            move_down()
        end, {buffer = M.state.buf}},

        {"n", "<C-p>", move_up, {buffer = M.state.buf}},
        {"i", "<C-p>", function()
            vim.api.nvim_command("stopinsert")
            move_up()
        end, {buffer = M.state.buf}},

        {"n", "<Left>", "<Nop>", {buffer = M.state.buf}},
        {"n", "<Right>", "<Nop>", {buffer = M.state.buf}},
        {"i", "<Left>", "<Nop>", {buffer = M.state.buf}},
        {"i", "<Right>", "<Nop>", {buffer = M.state.buf}},
    }

    -- store and set keymaps
    M.state.buf_keymaps = {}
    for _, map in ipairs(mappings) do
        local mode, lhs = map[1], map[2]
        table.insert(M.state.buf_keymaps, {mode, lhs})
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
            if M.state.selected_index > 0 then
                M.state.selected_index = 0
                M.state.search_term = M.state.search_term .. char
                update_results()
                update_display()
                vim.api.nvim_win_set_cursor(M.state.win, {M.state.header_lines, #M.state.search_term + 2})
                vim.api.nvim_command("startinsert")
            else
                vim.api.nvim_win_set_cursor(M.state.win, {M.state.header_lines, #M.state.search_term + 2})
                vim.api.nvim_command("startinsert")
                vim.api.nvim_feedkeys(char, 'i', false)
            end
        end

        table.insert(M.state.buf_keymaps, {mode, lhs})
        vim.keymap.set(mode, lhs, rhs, { buffer = M.state.buf, nowait = true })
    end

    local function restrict_cursor()
        local cursor = vim.api.nvim_win_get_cursor(M.state.win)
        local line = cursor[1]

        if line == 1 then
            vim.api.nvim_win_set_cursor(M.state.win, {2, 2})
        end

        if line > 1 and M.state.selected_index == 0 then
            vim.api.nvim_win_set_cursor(M.state.win, {2, #M.state.search_term + 2})
        end
    end

    -- handle input
    vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
        buffer = M.state.buf,
        callback = function()
            local lines = vim.api.nvim_buf_get_lines(M.state.buf, 0, M.state.header_lines, false)
            if #lines >= M.state.header_lines then
                local input = lines[M.state.header_lines]:sub(3)
                if input ~= M.state.search_term then
                    M.state.search_term = input
                    update_results()
                    update_display()
                    if M.state.selected_index == 0 then
                        vim.api.nvim_win_set_cursor(M.state.win, {M.state.header_lines, #M.state.search_term + 2})
                    end
                end
            end
        end
    })

    -- restrict cursor movement
    vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
        buffer = M.state.buf,
        callback = restrict_cursor
    })

    -- protect prefix
    vim.api.nvim_create_autocmd("TextChangedI", {
        buffer = M.state.buf,
        callback = function()
            local line = vim.api.nvim_get_current_line()
            if #line < 2 or line:sub(1,2) ~= "> " then
                vim.api.nvim_set_current_line("> " .. M.state.search_term)
                vim.api.nvim_win_set_cursor(M.state.win, {M.state.header_lines, #M.state.search_term + 2})
            end
        end
    })

    -- track window close
    M.state.win_closed_autocmd = vim.api.nvim_create_autocmd("WinClosed", {
        callback = function(args)
            if tonumber(args.match) == M.state.win then
                close_window()
            end
        end
    })

    -- initial display
    update_display()
    vim.api.nvim_command("startinsert")
    vim.api.nvim_win_set_cursor(M.state.win, {M.state.header_lines, #M.state.search_term + 2})

    vim.schedule(function()
        vim.notify("CMDP: press ctrl+q or esc to exit")
    end)
end

---

M.example_cmds = {
    ["CMDP: Hello"] = function()
        vim.schedule(function()
            vim.notify("CMDP: hello!", vim.log.levels.INFO)
        end)
    end,
}

function M.setup(opts)
    opts = opts or {}

    -- options commands
    if opts.commands == nil then
        M.state.commands = M.example_cmds
        vim.schedule(function()
            vim.notify("CMDP M.state.commands is not M.configured", vim.log.levels.INFO)
        end)
    else
        M.state.commands = opts.commands
    end
end

function M.show()
    if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
        close_window()
    else
        create_window()
    end
end

---

vim.api.nvim_create_user_command(
    M.cmd,
    M.show,
    {
        desc = "Command Center default launch",
    }
)


---

return M
