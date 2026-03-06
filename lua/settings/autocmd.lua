local ts = require("settings.treesitter")
local cap = require("settings.capability")

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
        for _, lang in ipairs(ts.TS) do
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
    pattern = "*",
    callback = function()
        -- TODO: bffrwrt
    end
})
