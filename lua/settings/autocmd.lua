local cap = require("settings.capability")

local etn_augroup = vim.api.nvim_create_augroup("EnsureTrailingNewline", { clear = true })
local ipc_augroup = vim.api.nvim_create_augroup("InsertPumpCompletion", { clear = true })

local COMPLETION_DELAY = 150 -- milliseconds

-- BufEnter
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function(args)
        local buffer = args.buf

        if not vim.api.nvim_buf_is_valid(buffer) then return end

        cap.default_completion(buffer)
    end
})

-- BufLeave
vim.api.nvim_create_autocmd("BufLeave", {
    pattern = "*",
    callback = function(args)
        local buffer = args.buf

        if not vim.api.nvim_buf_is_valid(buffer) then return end
    end
})

-- LspAttach
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local buffer = args.buf
        local buffer_name = vim.api.nvim_buf_get_name(buffer)

        if not vim.api.nvim_buf_is_valid(buffer) then return end
        if not client then return end
        if buffer_name == "" then return end

        cap.default_completion(buffer)
        cap.on_attach(client, buffer)
    end
})

-- LspDetach
vim.api.nvim_create_autocmd("LspDetach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local buffer = args.buf
        local buffer_name = vim.api.nvim_buf_get_name(buffer)

        if not vim.api.nvim_buf_is_valid(buffer) then return end
        if not client then return end
        if buffer_name == "" then return end
    end
})

-- FileType
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
        local buffer = args.buf

        if not vim.api.nvim_buf_is_valid(buffer) then return end

        local filetype = vim.bo[buffer].filetype
        for _, lang in ipairs(_G._prt_TS) do
            if lang == filetype then
                vim.treesitter.start(buffer, lang)
                break
            end
        end

        cap.default_completion(buffer)
    end
})

-- BufNewFile & BufRead
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    -- force file .h to c ad not c++
    pattern = "*.h",
    callback = function()
        if vim.bo.filetype == "" or vim.bo.filetype == "cpp" then
            vim.bo.filetype = "c"
        end
    end
})

-- BufWrite
vim.api.nvim_create_autocmd("BufWrite", {
    group = etn_augroup,
    pattern = "*",
    callback = function()
        -- TODO: bffrwrt
        local optf = vim.fn.stdpath("config") .. "/options.json"
        local opt = _G.read_json_file(optf)

        if opt ~= nil then
            if opt.add_new_endline == true then
                _G.add_empty_line_at_end()
            end
        end
    end
})

-- TextChangedI and/or InsertCharPre
-- MAYBE: add config to not load this one
local completion_timer = vim.uv.new_timer()

-- gate for the auto popup, flipped by the cmdp "TGGL: Auto-Completion On/Off"
-- command. manual completion (ctrl+x ctrl+o) stays usable when this is off.
if _G._prt_autocompletion == nil then
    _G._prt_autocompletion = true
end

vim.api.nvim_create_autocmd({"InsertCharPre"}, {
    group = ipc_augroup,
    pattern = "*",
    callback = function(args)
        local buffer = args.buf
        local buffer_name = vim.api.nvim_buf_get_name(buffer)

        if _G._prt_autocompletion == false then return end
        if not vim.api.nvim_buf_is_valid(buffer) then return end
        if buffer_name == "" then return end
        if vim.fn.mode() ~= "i" or vim.fn.pumvisible() == 1 then return end

        -- debounce: restart on every keystroke, fires once after typing pauses
        completion_timer:stop()
        completion_timer:start(COMPLETION_DELAY, 0, vim.schedule_wrap(function()
            if vim.fn.mode() ~= "i" or vim.fn.pumvisible() == 1 then return end

            vim.fn.feedkeys(vim.keycode(
                -- "<C-x><C-o>",
                "<cmd>call v:lua._prt_fuzzy_completion(0, '')<CR>"
            ), "n")
        end))
    end
})
