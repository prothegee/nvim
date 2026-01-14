local _cmd = {
    diagnostic_show_all = "DiagnosticShowAll",
    diagnostic_show_float_window = "DiagnosticShowFloatWindow",
    diagnostic_toggle_virt_text = "DiagnosticToggleVirtText",
    diagnostic_toggle_virt_line = "DiagnosticToggleVirtLine",
    diagnostic_toggle_virt_text_and_line = "DiagnosticToggleVirtTextAndLine",
}

-- show all diagnostics in quickfix list
vim.api.nvim_create_user_command(_cmd.diagnostic_show_all, function()
        vim.diagnostic.setqflist({ open = true })
end, { desc = "Show all diagnostics in quickfix list" })

-- show diagnostic in float window
vim.api.nvim_create_user_command(_cmd.diagnostic_show_float_window, function()
        vim.diagnostic.open_float({ scope = "cursor" })
end, { desc = "Show diagnostic message in float window" })

-- diagnostic text
vim.api.nvim_create_user_command(_cmd.diagnostic_toggle_virt_text, function()
    local cfg = vim.diagnostic.config() or {}
    local virt_text = cfg.virtual_text ~= false

    vim.diagnostic.config({
        virtual_text = not virt_text
    })
end, { desc = "Toggle diagnostic virtual text" })

-- diagnostic lines
vim.api.nvim_create_user_command(_cmd.diagnostic_toggle_virt_line, function()
    local cfg = vim.diagnostic.config() or {}
    local virt_lines = cfg.virtual_lines ~= false

    vim.diagnostic.config({
        virtual_lines = not virt_lines
    })
end, { desc = "Toggle diagnostic virtual line" })

-- diagnostic text and lines
vim.api.nvim_create_user_command(_cmd.diagnostic_toggle_virt_text_and_line, function()
    local cfg = vim.diagnostic.config() or {}
    local virt_txt = cfg.virtual_text ~= false
    local virt_line = virt_txt and true or false

    vim.diagnostic.config({
        virtual_text = not virt_txt,
        virtual_lines = not virt_line
    })
end, { desc = "Toggle diagnostic virtual text and line" })
