--[[
# XPLRR
eXPLoReR

## Behavior
- Respect .nvimignore
- Can type and search WHILE scanning
- Async scanning with incremental results
- Results ranked by match quality (closer = higher priority)

## Note
- Some behaviour is restricted due typing protection

## Dependencies
- optional:
    - nvim-web-devicons:
       - https://github.com/nvim-tree/nvim-web-devicons 
--]]
local M = {}

local config = {
    hidden = true,
    follow_symlinks = false,
    max_results = 8192,
    max_display = 50,
    border = "rounded",
    highlight_ns = vim.api.nvim_create_namespace("XPLRR_HL"),
    icon_ns = vim.api.nvim_create_namespace("XPLRR_ICONS"),
    match_ns = vim.api.nvim_create_namespace("XPLRR_MATCH"),
    debounce_ms = 100,
    update_interval = 50,
    enable_icons = true,
}

local state = {
    buf = nil,
    win = nil,
    search_term = "",
    results = {},
    selected_index = 0,
    cwd = vim.fn.getcwd(),
    extmark_id = nil,
    all_files = {},
    filtered_results = {},
    original_win = nil,
    header_lines = 2,
    mode = "files",
    buf_keymaps = {},
    win_closed_autocmd = nil,
    is_loading = false,
    debounce_timer = nil,
    ignore_patterns = nil,
    files_discovered = 0,
    devicons = nil,
    devicons_get_icon = nil,
}

local function is_windows()
    return package.config:sub(1,1) == "\\"
end

local function shorten_path(path)
    local home = vim.env.HOME or vim.env.USERPROFILE
    if home then
        home = home:gsub("\\", "/")
        local normalized_path = path:gsub("\\", "/")
        if normalized_path:sub(1, #home) == home then
            return "~" .. normalized_path:sub(#home + 1)
        end
    end
    return path
end

local function is_valid_buf(buf)
    return buf and vim.api.nvim_buf_is_valid(buf)
end

local function get_file_icon(filepath)
    if not config.enable_icons or not state.devicons_get_icon then
        return ""
    end

    local filename = filepath:match("([^/]+)$") or filepath
    local icon = state.devicons_get_icon(filename, nil, { default = true })

    if icon then
        return icon .. " "
    end

    return ""
end

local function get_file_icon_color(filepath)
    if not config.enable_icons or not state.devicons_get_icon then
        return nil
    end

    local filename = filepath:match("([^/]+)$") or filepath
    local _, color = state.devicons_get_icon(filename, nil, { default = true })

    return color
end

local function set_icon_highlight(color)
    if not color then
        return nil
    end

    local hl_name = "XplrrIcon" .. color:gsub("#", "")
    local ok = pcall(vim.api.nvim_get_hl, 0, { name = hl_name })
    if not ok then
        vim.api.nvim_set_hl(0, hl_name, { fg = color, default = true })
    end
    return hl_name
end

local function set_match_highlight()
    vim.api.nvim_set_hl(0, "XplrrMatch", { bg = "#473826", bold = true, default = true })
    return "XplrrMatch"
end

local function find_match_positions(term, str)
    if #term == 0 then
        return {}
    end

    local positions = {}
    local lower_term = term:lower()
    local lower_str = str:lower()

    local substring_start = lower_str:find(lower_term, 1, true)
    if substring_start then
        for i = substring_start, substring_start + #term - 1 do
            table.insert(positions, i)
        end
        return positions
    end

    local j = 1
    for i = 1, #lower_term do
        local c = lower_term:sub(i, i)
        while j <= #lower_str do
            if lower_str:sub(j, j) == c then
                table.insert(positions, j)
                j = j + 1
                break
            end
            j = j + 1
        end
    end

    return positions
end

local function load_ignore_patterns()
    if state.ignore_patterns then
        return state.ignore_patterns
    end

    local ignore_file = state.cwd .. "/.nvimignore"
    local patterns = {}

    local fd = vim.loop.fs_open(ignore_file, "r", 438)
    if not fd then
        state.ignore_patterns = patterns
        return patterns
    end

    local stat = vim.loop.fs_fstat(fd)
    if not stat then
        vim.loop.fs_close(fd)
        state.ignore_patterns = patterns
        return patterns
    end

    local content = vim.loop.fs_read(fd, stat.size, 0)
    vim.loop.fs_close(fd)

    if not content then
        state.ignore_patterns = patterns
        return patterns
    end

    for line in content:gmatch("[^\r\n]+") do
        local clean_line = line:gsub("#.*$", ""):gsub("^%s*(.-)%s*$", "%1")
        if clean_line ~= "" then
            local pattern_info = {
                original = clean_line,
                clean = clean_line:gsub("/+$", ""),
                is_dir_pattern = clean_line:sub(-1) == "/",
                regex = nil
            }
            if clean_line:find("*") then
                pattern_info.regex = "^" .. clean_line:gsub("%.", "%%."):gsub("%*", ".*") .. "$"
            end
            table.insert(patterns, pattern_info)
        end
    end

    state.ignore_patterns = patterns
    return patterns
end

local function should_ignore(file_path, ignore_patterns)
    if not ignore_patterns or #ignore_patterns == 0 then
        return false
    end

    for _, pattern_info in ipairs(ignore_patterns) do
        local clean_pattern = pattern_info.clean
        if file_path == clean_pattern then
            return true
        end
        if pattern_info.is_dir_pattern then
            local dir_pattern = clean_pattern:sub(1, -2)
            if file_path == dir_pattern or file_path:sub(1, #dir_pattern + 1) == dir_pattern .. "/" then
                return true
            end
        else
            if pattern_info.regex then
                if file_path:match(pattern_info.regex) then
                    return true
                end
            end
            if file_path:sub(1, #clean_pattern + 1) == clean_pattern .. "/" then
                return true
            end
        end
    end
    return false
end

local function scan_directory_async(dir, use_ignore, on_file_found, on_complete)
    local ignore_patterns = use_ignore and load_ignore_patterns() or {}
    state.is_loading = true
    state.ignore_patterns = ignore_patterns
    state.files_discovered = 0

    local queue = {dir}
    local processed_dirs = {}

    local function scan_one_dir(current_dir)
        local handle = vim.loop.fs_scandir(current_dir)
        if not handle then
            return false
        end

        while true do
            local name, fs_type = vim.loop.fs_scandir_next(handle)
            if not name then
                break
            end

            if state.files_discovered >= config.max_results then
                return true
            end

            local full_path = current_dir .. "/" .. name
            local rel_path = full_path:sub(#state.cwd + 2)

            if not config.hidden and name:sub(1, 1) == "." then
                goto next_file
            end

            if fs_type == "file" then
                if not should_ignore(rel_path, ignore_patterns) then
                    state.files_discovered = state.files_discovered + 1
                    on_file_found(rel_path)
                end
            elseif fs_type == "directory" then
                if not should_ignore(rel_path, ignore_patterns) then
                    table.insert(queue, full_path)
                end
            end

            ::next_file::
        end
        return false
    end

    local function process_queue()
        if #queue == 0 or state.files_discovered >= config.max_results then
            state.is_loading = false
            on_complete()
            return
        end

        local current_dir = table.remove(queue, 1)
        if processed_dirs[current_dir] then
            vim.schedule(process_queue)
            return
        end
        processed_dirs[current_dir] = true

        local should_stop = scan_one_dir(current_dir)
        if should_stop then
            state.is_loading = false
            on_complete()
            return
        end

        vim.schedule(process_queue)
    end

    vim.schedule(process_queue)
end

local function get_open_buffers(use_ignore)
    local buffers = {}
    local ignore_patterns = use_ignore and load_ignore_patterns() or {}

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
            local file = vim.api.nvim_buf_get_name(buf)
            if file and file ~= "" then
                file = file:gsub("\\", "/")
                local cwd_normalized = state.cwd:gsub("\\", "/")
                if cwd_normalized:sub(-1) ~= "/" then
                    cwd_normalized = cwd_normalized .. "/"
                end
                if file:sub(1, #cwd_normalized) == cwd_normalized then
                    file = file:sub(#cwd_normalized + 1)
                end
                if not (use_ignore and should_ignore(file, ignore_patterns)) then
                    table.insert(buffers, file)
                end
            end
        end
    end
    return buffers
end

local function fuzzy_match_with_score(term, str)
    if #term == 0 then
        return true, 0
    end

    term = term:lower()
    str = str:lower()

    local substring_start = str:find(term, 1, true)
    if substring_start then
        return true, substring_start
    end

    local score = 0
    local first_char_score = 0
    local j = 1
    local matched = 0

    for i = 1, #term do
        local c = term:sub(i, i)
        local found = false
        local char_pos = 0

        while j <= #str do
            if str:sub(j, j) == c then
                found = true
                char_pos = j
                j = j + 1
                break
            end
            j = j + 1
        end

        if not found then
            return false, 999999
        end

        matched = matched + 1
        if i == 1 then
            first_char_score = char_pos
        end
        score = score + char_pos
    end

    return true, (first_char_score * 100) + (score - first_char_score)
end

local function update_display()
    if not is_valid_buf(state.buf) then
        return
    end

    local display_cwd = shorten_path(state.cwd)
    local title = "XPLRR"
    if state.mode == "files" then
        title = "XPLRR: " .. display_cwd
    elseif state.mode == "buffers" then
        title = "XPLRR Buffers"
    elseif state.mode == "all" then
        title = "XPLRR All: " .. display_cwd
    end

    local loading_indicator = state.is_loading and " (loading...)" or ""
    local display_lines = {
        title .. loading_indicator,
        "> " .. state.search_term
    }

    state.header_lines = #display_lines

    if config.enable_icons and state.devicons_get_icon then
        pcall(vim.api.nvim_buf_clear_namespace, state.buf, config.icon_ns, 0, -1)
    end
    pcall(vim.api.nvim_buf_clear_namespace, state.buf, config.match_ns, 0, -1)

    local render_limit = math.min(#state.filtered_results, config.max_display)
    local icon_data = {}
    local match_data = {}

    for i = 1, render_limit do
        local prefix = (state.selected_index == i) and "➤ " or "  "
        local filepath = state.filtered_results[i]
        local icon_str = ""

        if config.enable_icons and state.devicons_get_icon then
            icon_str = get_file_icon(filepath)
        end

        table.insert(display_lines, prefix .. icon_str .. filepath)

        if config.enable_icons and state.devicons_get_icon and icon_str ~= "" then
            local icon_color = get_file_icon_color(filepath)
            icon_data[i] = {
                prefix_len = #prefix,
                icon_len = #icon_str,
                color = icon_color
            }
        end

        if #state.search_term > 0 then
            local positions = find_match_positions(state.search_term, filepath)
            if #positions > 0 then
                match_data[i] = {
                    prefix_len = #prefix,
                    icon_len = #icon_str,
                    positions = positions
                }
            end
        end
    end

    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, display_lines)

    if #state.search_term > 0 then
        local hl_name = set_match_highlight()
        for i = 1, render_limit do
            local data = match_data[i]
            if data and data.positions then
                local line_index = state.header_lines + i - 1
                local line_count = vim.api.nvim_buf_line_count(state.buf)
                if line_index < line_count then
                    local line = vim.api.nvim_buf_get_lines(state.buf, line_index, line_index + 1, false)[1] or ""
                    local line_len = #line
                    local content_start = data.prefix_len + data.icon_len

                    for _, pos in ipairs(data.positions) do
                        local col = content_start + pos - 1
                        if col >= 0 and col < line_len then
                            vim.api.nvim_buf_set_extmark(
                                state.buf,
                                config.match_ns,
                                line_index,
                                col,
                                {
                                    hl_group = hl_name,
                                    end_col = col + 1,
                                    priority = 150,
                                }
                            )
                        end
                    end
                end
            end
        end
    end

    if config.enable_icons and state.devicons_get_icon then
        for i = 1, render_limit do
            local data = icon_data[i]
            if data and data.color then
                local line_index = state.header_lines + i - 1
                local line_count = vim.api.nvim_buf_line_count(state.buf)
                if line_index < line_count then
                    local line = vim.api.nvim_buf_get_lines(state.buf, line_index, line_index + 1, false)[1] or ""
                    local line_len = #line
                    local start_col = data.prefix_len
                    local end_col = math.min(data.prefix_len + data.icon_len, line_len)

                    if start_col < line_len then
                        local hl_name = set_icon_highlight(data.color)
                        if hl_name then
                            pcall(vim.api.nvim_buf_set_extmark,
                                state.buf,
                                config.icon_ns,
                                line_index,
                                start_col,
                                {
                                    hl_group = hl_name,
                                    end_col = end_col,
                                    priority = 100,
                                }
                            )
                        end
                    end
                end
            end
        end
    end

    if state.extmark_id then
        pcall(vim.api.nvim_buf_del_extmark, state.buf, config.highlight_ns, state.extmark_id)
        state.extmark_id = nil
    end

    if state.selected_index > 0 and state.selected_index <= render_limit then
        local line_index = state.header_lines + state.selected_index - 1
        local line_count = vim.api.nvim_buf_line_count(state.buf)
        if line_index < line_count then
            local line = vim.api.nvim_buf_get_lines(state.buf, line_index, line_index + 1, false)[1] or ""
            local line_len = #line
            local prefix = "➤ "
            local icon_offset = 0
            if icon_data[state.selected_index] then
                icon_offset = icon_data[state.selected_index].icon_len
            end
            local start_col = math.min(#prefix + icon_offset, line_len)

            state.extmark_id = vim.api.nvim_buf_set_extmark(
                state.buf,
                config.highlight_ns,
                line_index,
                start_col,
                {
                    hl_group = "visual",
                    end_line = line_index + 1,
                    end_col = 0,
                    priority = 200,
                }
            )
        end
    end
end

local function filter_and_update()
    local term = state.search_term

    if #term == 0 then
        state.filtered_results = {}
        local limit = math.min(#state.all_files, config.max_results)
        for i = 1, limit do
            table.insert(state.filtered_results, state.all_files[i])
        end
    else
        local matches = {}
        local lower_term = term:lower()

        for _, file in ipairs(state.all_files) do
            local is_match, score = fuzzy_match_with_score(lower_term, file)
            if is_match then
                local final_score = score + (#file * 0.001)
                table.insert(matches, { file = file, score = final_score })

                if #matches >= config.max_results then
                    break
                end
            end
        end

        table.sort(matches, function(a, b)
            if a.score == b.score then
                return a.file < b.file
            end
            return a.score < b.score
        end)

        state.filtered_results = {}
        for i, match in ipairs(matches) do
            state.filtered_results[i] = match.file
        end
    end

    if #state.filtered_results > 0 then
        if state.selected_index > #state.filtered_results then
            state.selected_index = #state.filtered_results
        end
    else
        state.selected_index = 0
    end

    update_display()
end

local function debounced_filter()
    if config.debounce_ms <= 0 then
        filter_and_update()
        return
    end

    if state.debounce_timer then
        state.debounce_timer:stop()
    else
        state.debounce_timer = vim.loop.new_timer()
    end

    state.debounce_timer:start(config.debounce_ms, 0, function()
        vim.schedule(filter_and_update)
    end)
end

local function on_file_discovered(filepath)
    table.insert(state.all_files, filepath)

    if #state.all_files % config.update_interval == 0 then
        vim.schedule(filter_and_update)
    end
end

local function open_file(filepath)
    local full_path
    if filepath:match("^/") or (is_windows() and filepath:match("^%a:\\")) then
        full_path = filepath
    else
        full_path = state.cwd .. "/" .. filepath
    end
    full_path = full_path:gsub("/+", "/")

    if state.original_win and vim.api.nvim_win_is_valid(state.original_win) then
        vim.api.nvim_set_current_win(state.original_win)
        vim.cmd("edit " .. vim.fn.fnameescape(full_path))
        return true
    else
        vim.cmd("edit " .. vim.fn.fnameescape(full_path))
        return true
    end
end

local function close_window()
    if state.win_closed_autocmd then
        pcall(vim.api.nvim_del_autocmd, state.win_closed_autocmd)
        state.win_closed_autocmd = nil
    end

    if state.extmark_id and is_valid_buf(state.buf) then
        pcall(vim.api.nvim_buf_del_extmark, state.buf, config.highlight_ns, state.extmark_id)
    end

    if state.buf_keymaps and is_valid_buf(state.buf) then
        for _, keymap in ipairs(state.buf_keymaps) do
            local mode, lhs = keymap[1], keymap[2]
            pcall(vim.api.nvim_buf_del_keymap, state.buf, mode, lhs)
        end
        state.buf_keymaps = {}
    end

    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_close(state.win, true)
    end
    state.buf = nil
    state.win = nil
    state.extmark_id = nil
    state.is_loading = false
    state.ignore_patterns = nil
    state.all_files = {}
    state.filtered_results = {}

    if state.debounce_timer then
        state.debounce_timer:stop()
        state.debounce_timer:close()
        state.debounce_timer = nil
    end

    vim.api.nvim_command("stopinsert")
    if state.original_win and vim.api.nvim_win_is_valid(state.original_win) then
        vim.api.nvim_set_current_win(state.original_win)
        vim.api.nvim_command("stopinsert")
    end
end

local function setup_keymaps_and_ui()
    local function move_up()
        if state.selected_index == 0 then
        elseif state.selected_index == 1 then
            state.selected_index = 0
            update_display()
            local line_count = vim.api.nvim_buf_line_count(state.buf)
            if state.header_lines <= line_count then
                vim.api.nvim_win_set_cursor(state.win, {state.header_lines, math.min(#state.search_term + 2, vim.api.nvim_buf_get_lines(state.buf, state.header_lines - 1, state.header_lines, false)[1]:len())})
            end
            vim.api.nvim_command("startinsert")
            vim.fn.winrestview({topline = 1})
        else
            state.selected_index = state.selected_index - 1
            update_display()
            local target_line = state.selected_index + state.header_lines
            local line_count = vim.api.nvim_buf_line_count(state.buf)
            if target_line <= line_count then
                vim.api.nvim_win_set_cursor(state.win, {target_line, 0})
            end
            if state.selected_index == 1 then
                vim.fn.winrestview({topline = 1})
            end
        end
    end

    local function move_down()
        if state.selected_index == 0 then
            if #state.filtered_results > 0 then
                state.selected_index = 1
                update_display()
                local target_line = state.header_lines + state.selected_index - 1
                local line_count = vim.api.nvim_buf_line_count(state.buf)
                if target_line <= line_count then
                    vim.api.nvim_win_set_cursor(state.win, {target_line, 0})
                end
                vim.fn.winrestview({topline = 1})
            end
        elseif state.selected_index < #state.filtered_results then
            state.selected_index = state.selected_index + 1
            update_display()
            local target_line = state.selected_index + state.header_lines
            local line_count = vim.api.nvim_buf_line_count(state.buf)
            if target_line <= line_count then
                vim.api.nvim_win_set_cursor(state.win, {target_line, 0})
            end
            vim.fn.winrestview({topline = 1})
        end
    end

    local mappings = {
        {"n", "<CR>", function()
            if state.selected_index == 0 and #state.filtered_results > 0 then
                if open_file(state.filtered_results[1]) then
                    close_window()
                end
            elseif state.selected_index > 0 then
                if open_file(state.filtered_results[state.selected_index]) then
                    close_window()
                end
            end
        end, {buffer = state.buf}},

        {"i", "<CR>", function()
            if state.selected_index == 0 and #state.filtered_results > 0 then
                if open_file(state.filtered_results[1]) then
                    close_window()
                end
            elseif state.selected_index > 0 then
                if open_file(state.filtered_results[state.selected_index]) then
                    close_window()
                end
            end
        end, {buffer = state.buf}},

        {"n", "<Esc>", close_window, {buffer = state.buf}},
        {"i", "<Esc>", close_window, {buffer = state.buf}},
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

    state.buf_keymaps = {}
    for _, map in ipairs(mappings) do
        local mode, lhs = map[1], map[2]
        table.insert(state.buf_keymaps, {mode, lhs})
        vim.keymap.set(mode, lhs, map[3], map[4])
    end

    local function restrict_cursor()
        if not is_valid_buf(state.buf) or not vim.api.nvim_win_is_valid(state.win) then
            return
        end

        local cursor = vim.api.nvim_win_get_cursor(state.win)
        local line, col = cursor[1], cursor[2]
        local line_count = vim.api.nvim_buf_line_count(state.buf)

        if line < 1 then
            line = 1
        end
        if line > line_count then
            line = line_count
        end

        if line == 1 and col < 2 then
            if line_count >= 2 then
                vim.api.nvim_win_set_cursor(state.win, {2, 2})
            end
        end

        if line > state.header_lines and state.selected_index == 0 then
            if state.header_lines <= line_count then
                local search_line_content = vim.api.nvim_buf_get_lines(state.buf, state.header_lines - 1, state.header_lines, false)[1] or ""
                vim.api.nvim_win_set_cursor(state.win, {state.header_lines, math.min(#state.search_term + 2, search_line_content:len())})
            end
        end
    end

    vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
        buffer = state.buf,
        callback = function()
            local lines = vim.api.nvim_buf_get_lines(state.buf, 0, state.header_lines, false)
            if #lines >= state.header_lines then
                local input = lines[state.header_lines]:sub(3)
                if input ~= state.search_term then
                    state.search_term = input
                    debounced_filter()

                    if state.selected_index == 0 then
                        local line_count = vim.api.nvim_buf_line_count(state.buf)
                        if state.header_lines <= line_count then
                            local line_content = vim.api.nvim_buf_get_lines(state.buf, state.header_lines - 1, state.header_lines, false)[1] or ""
                            vim.api.nvim_win_set_cursor(state.win, {state.header_lines, math.min(#state.search_term + 2, line_content:len())})
                        end
                    end
                end
            end
        end
    })

    vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
        buffer = state.buf,
        callback = restrict_cursor
    })

    vim.api.nvim_create_autocmd("TextChangedI", {
        buffer = state.buf,
        callback = function()
            local line = vim.api.nvim_get_current_line()
            if #line < 2 or line:sub(1,2) ~= "> " then
                vim.api.nvim_set_current_line("> " .. state.search_term)
                local line_count = vim.api.nvim_buf_line_count(state.buf)
                if state.header_lines <= line_count then
                    local line_content = vim.api.nvim_buf_get_lines(state.buf, state.header_lines - 1, state.header_lines, false)[1] or ""
                    vim.api.nvim_win_set_cursor(state.win, {state.header_lines, math.min(#state.search_term + 2, line_content:len())})
                end
            end
        end
    })
end

local function create_window(mode)
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        return
    end

    state.original_win = vim.api.nvim_get_current_win()
    state.mode = mode or "files"

    state.buf = vim.api.nvim_create_buf(false, true)
    if not is_valid_buf(state.buf) then
        vim.notify("failed to create XPLRR buffer", vim.log.levels.ERROR)
        return
    end

    local width = math.floor(vim.o.columns * 0.75)
    local height = math.floor(vim.o.lines * 0.50)

    local title = "XPLRR"
    if state.mode == "files" then
        title = "XPLRR"
    elseif state.mode == "buffers" then
        title = "XPLRR Buffers"
    elseif state.mode == "all" then
        title = "XPLRR All"
    end

    local win_opts = {
        relative = "editor",
        width = width,
        height = height,
        col = (vim.o.columns - width) / 2,
        row = (vim.o.lines - height) / 2,
        style = "minimal",
        border = config.border,
        title = title,
        title_pos = "center",
    }

    state.win = vim.api.nvim_open_win(state.buf, true, win_opts)
    if not state.win or not vim.api.nvim_win_is_valid(state.win) then
        vim.notify("failed to create XPLRR window", vim.log.levels.ERROR)
        return
    end

    vim.bo[state.buf].buftype = "nofile"
    vim.bo[state.buf].filetype = "xplrr"
    vim.bo[state.buf].swapfile = false
    vim.bo[state.buf].bufhidden = "wipe"

    setup_keymaps_and_ui()

    state.cwd = vim.fn.getcwd()
    state.ignore_patterns = nil
    state.all_files = {}
    state.filtered_results = {}
    state.search_term = ""
    state.selected_index = 0

    if mode == "buffers" then
        state.all_files = get_open_buffers(false)
        filter_and_update()
        vim.api.nvim_command("startinsert")
        local line_count = vim.api.nvim_buf_line_count(state.buf)
        if state.header_lines <= line_count then
            local line_content = vim.api.nvim_buf_get_lines(state.buf, state.header_lines - 1, state.header_lines, false)[1] or ""
            vim.api.nvim_win_set_cursor(state.win, {state.header_lines, math.min(#state.search_term + 2, line_content:len())})
        end
    else
        vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, {title .. " (loading...)", "> "})
        state.header_lines = 2
        state.is_loading = true
        vim.api.nvim_command("startinsert")
        vim.api.nvim_win_set_cursor(state.win, {2, 2})

        local files_callback = function(files)
            for _, file in ipairs(files) do
                table.insert(state.all_files, file)
            end

            if mode == "files" then
                local buffer_files = get_open_buffers(false)
                local all_files_map = {}
                for _, file in ipairs(state.all_files) do
                    all_files_map[file] = true
                end
                for _, file in ipairs(buffer_files) do
                    all_files_map[file] = true
                end
                state.all_files = {}
                for file, _ in pairs(all_files_map) do
                    table.insert(state.all_files, file)
                end
                table.sort(state.all_files)
            end

            state.is_loading = false
            filter_and_update()

            vim.schedule(function()
                vim.notify("XPLRR " .. mode .. ": " .. #state.all_files .. " files found", vim.log.levels.INFO)
            end)
        end

        if mode == "all" then
            scan_directory_async(state.cwd, false, on_file_discovered, function()
                files_callback({})
            end)
        else
            scan_directory_async(state.cwd, true, on_file_discovered, function()
                files_callback({})
            end)
        end
    end
end

M.cmd = {
    xplrr = "Xplrr",
    xplrr_all = "XplrrAll",
    xplrr_buffers = "XplrrBuffers",
}

function M.toggle()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        close_window()
    else
        create_window("files")
    end
end

function M.toggle_all()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        close_window()
    else
        create_window("all")
    end
end

function M.toggle_buffers()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        close_window()
    else
        create_window("buffers")
    end
end

function M.setup(opts)
    opts = opts or {}
    if opts.enable_icons ~= nil then
        config.enable_icons = opts.enable_icons
    end

    if config.enable_icons then
        local ok, devicons = pcall(require, "nvim-web-devicons")
        if ok then
            devicons.setup()
            state.devicons = devicons
            state.devicons_get_icon = devicons.get_icon
        else
            config.enable_icons = false
            state.devicons_get_icon = nil
        end
    end

    vim.api.nvim_create_user_command(M.cmd.xplrr, M.toggle, { desc = "XPLRR: search files" })
    vim.api.nvim_create_user_command(M.cmd.xplrr_all, M.toggle_all, { desc = "XPLRR: search all files" })
    vim.api.nvim_create_user_command(M.cmd.xplrr_buffers, M.toggle_buffers, { desc = "XPLRR: search buffers" })
end

---

return M
