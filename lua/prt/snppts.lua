--[[
# SNPPTS
SNiPPeTS
--]]
local M = {}

M.snippet_store = {}
M.completion_start_col = {}

M.SNIPPET_TRIGGER = "<C-x><C-i>"

---

local function get_available_snippet_files()
    local available = {}
    local snippet_dir = vim.fn.stdpath("config") .. "/data/snippet"
    local files = vim.fn.glob(snippet_dir .. "/*.json", true, true)

    for _, fp in ipairs(files) do
        local filename = vim.fn.fnamemodify(fp, ":t:r")
        available[filename] = fp
    end

    return available
end

local function load_snippets_from_file(filepath, filetype)
    local file = io.open(filepath, "r")
    if not file then return end

    local content = file:read("*all")
    file:close()

    local ok, snippets = pcall(vim.json.decode, content)
    if not ok then
        vim.notify("[Warn] failed to parse snippet file: " .. filepath, vim.log.levels.WARN)
        return
    end

    M.snippet_store[filetype] = M.snippet_store[filetype] or {}

    for name, snippet in pairs(snippets) do
        local prefix = snippet.prefix
        if type(prefix) == "string" then
            prefix = {prefix}
        end

        for _, p in ipairs(prefix) do
            table.insert(M.snippet_store[filetype], {
                prefix = p,
                body = snippet.body,
                description = name,
            })
        end
    end
end

local function get_snippet_completion(base, filetype, start_col)
    M.load_filetype(filetype)
    local matches = {}
    local snippets = M.snippet_store[filetype] or {}

    for _, snippet in ipairs(snippets) do
        if not base or #base == 0 or snippet.prefix:sub(1, #base) == base then
            table.insert(matches, {
                abbr = snippet.prefix,
                word = snippet.prefix,
                menu = "[snip] " .. (snippet.description or ""),
                kind = "Snippet",
                icase = 1,
                dup = 0,
                user_data = vim.json.encode({
                    _snippet_source = true,
                    body = snippet.body,
                    start_col = start_col,
                }),
            })
        end
    end

    return matches
end

---

function M.load_filetype(filetype)
    if M.snippet_store[filetype] then
        return
    end

    local available_files = get_available_snippet_files()
    local snippet_file = available_files[filetype]

    if snippet_file then
        load_snippets_from_file(snippet_file, filetype)
    end
end

function M.trigger_snippet_completion()
    if vim.fn.mode() ~= "i" then return end

    local bufnr = vim.api.nvim_get_current_buf()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local match = line:sub(1, col):match("[%w_]*$") or ""
    local start_col = col - #match
    local base = match

    M.completion_start_col[bufnr] = start_col

    local filetype = vim.bo.filetype
    local results = get_snippet_completion(base, filetype, start_col)

    if #results > 0 then
        vim.fn.complete(start_col + 1, results)
    end
end

function M.omnifunc(findstart, base)
    local bufnr = vim.api.nvim_get_current_buf()

    if findstart == 1 then
        local col = vim.api.nvim_win_get_cursor(0)[2]
        local line = vim.api.nvim_get_current_line()
        local match = line:sub(1, col):match("[%w_]*$") or ""
        M.completion_start_col[bufnr] = col - #match
        return M.completion_start_col[bufnr]
    else
        local filetype = vim.bo.filetype
        local start_col = M.completion_start_col[bufnr] or 0
        return get_snippet_completion(base, filetype, start_col)
    end
end

function M.on_complete_done()
    local completed_item = vim.v.completed_item
    if not completed_item or not completed_item.user_data then
        return
    end

    local ok, data = pcall(vim.json.decode, completed_item.user_data)
    if not ok or not data or not data._snippet_source then
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1] - 1
    local col = cursor[2]
    local start_col = data.start_col or M.completion_start_col[bufnr]

    if start_col == nil then
        return
    end

    local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
    local before = line:sub(1, start_col)
    local after = line:sub(col + 1)
    local cleaned_line = before .. after

    vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, { cleaned_line })
    vim.api.nvim_win_set_cursor(0, { row + 1, start_col })
    vim.snippet.expand(table.concat(data.body, "\n"))

    M.completion_start_col[bufnr] = nil
end

---

function M.setup()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        group = vim.api.nvim_create_augroup("SnpptsLoad", { clear = true }),
        callback = function(ev)
            local ft = vim.bo[ev.buf].filetype
            M.load_filetype(ft)
        end,
    })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        group = vim.api.nvim_create_augroup("SnpptsKeymap", { clear = true }),
        callback = function(ev)
            vim.keymap.set("i", M.SNIPPET_TRIGGER, function()
                M.trigger_snippet_completion()
            end, { buffer = ev.buf, desc = "Snippet completion" })
        end,
    })

    -- expand snippet on CompleteDone
    vim.api.nvim_create_autocmd("CompleteDone", {
        group = vim.api.nvim_create_augroup("SnpptsComplete", { clear = true }),
        callback = function()
            M.on_complete_done()
        end,
    })

    -- tabstop navigation
    vim.keymap.set("i", "<Tab>", function()
        if vim.snippet.active({ direction = 1 }) then
            vim.snippet.jump(1)
            return ""
        end
        return "<Tab>"
    end, { expr = true, desc = "Snippet jump forward" })
    vim.keymap.set("i", "<S-Tab>", function()
        if vim.snippet.active({ direction = -1 }) then
            vim.snippet.jump(-1)
            return ""
        end
        return "<S-Tab>"
    end, { expr = true, desc = "Snippet jump backward" })
end

---

-- DEBUG
function M.debug_snippet_store()
    return M.snippet_store
end

function M.debug_available_files()
    return get_available_snippet_files()
end

---

return M
