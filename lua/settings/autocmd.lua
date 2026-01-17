local CAPABILITY = require"settings.capability"

local TREESITTERS = {
    "lua",
    "c", "cpp", "cmake",
    "rust",
    "go",
    "ziggy", "ziggy_schema",
    "javascript", "typescript",
    "svelte", "vue",
    "gdscript", "gdshader",
    "python",
    "html", "css", "scss", -- "drogon-csp",
    "json", "jsonc", "json5",
    "markdown", "typst",
    "yaml", "toml",
    "bash",
    "sql",
}

-- BufEnter
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function(args)
        local buffer = args.buf

        if not vim.api.nvim_buf_is_valid(buffer) then return end

        CAPABILITY.default_completion(buffer)

        -- cmake: syntax case
        if vim.bo.filetype == "cmake" then
           vim.cmd("syntax off")
        end
    end
})
-- BufEnter
vim.api.nvim_create_autocmd("BufLeave", {
    pattern = "*",
    callback = function(args)
        local buffer = args.buf

        if not vim.api.nvim_buf_is_valid(buffer) then return end

        -- cmake: syntax case
        if vim.bo.filetype == "cmake" then
           vim.cmd("syntax on")
        end
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

        CAPABILITY.default_completion(buffer)
        CAPABILITY.on_attach(client, buffer)
    end
})
-- FileType
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
        local buffer = args.buf
        if not vim.api.nvim_buf_is_valid(buffer) then return end

        CAPABILITY.default_completion(buffer)
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

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
        local buffer = args.buf
        local filetype = vim.bo[buffer].filetype

        for _, treesitter in pairs(TREESITTERS) do
            if treesitter == filetype then
                if vim.treesitter.language.add(treesitter) then
                    vim.treesitter.start(buffer, treesitter)
                end
                break
            end
        end
    end,
})
