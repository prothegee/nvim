vim.api.nvim_set_keymap("n", "<C-A-Left>",
    "<C-w>h",
{
    desc = "navigate buf left",
    silent = true,
    noremap = true
})
vim.api.nvim_set_keymap("n", "<C-A-Right>",
    "<C-w>l",
{
    desc = "navigate buf left",
    silent = true,
    noremap = true
})
vim.api.nvim_set_keymap("n", "<C-A-Up>",
    "<C-w>k",
{
    desc = "navigate buf up",
    silent = true,
    noremap = true
})
vim.api.nvim_set_keymap("n", "<C-A-Down>",
    "<C-w>j",
{
    desc = "navigate buf down",
    silent = true,
    noremap = true
})

vim.api.nvim_set_keymap("n", "<C-S-k>",
    "<cmd>DiagnosticShowFloatWindow<CR>",
{
    desc = "show floating window diagnostic",
    silent = true,
    noremap = true
})

vim.keymap.set("n", "<S-j>",
    vim.lsp.buf.definition,
{
    desc = "go to definition",
    silent = true,
    noremap = true
})

vim.keymap.set("n", "]d",
    function()
        vim.diagnostic.jump({ count = 1, float = true })
    end,
{
    desc = "go to next diagnostic",
    silent = true,
    noremap = true
})

vim.keymap.set("n", "[d",
    function()
        vim.diagnostic.jump({ count = -1, float = true })
    end,
{
    desc = "go to previous diagnostic",
    silent = true,
    noremap = true
})

vim.keymap.set("n", "<C-p>",
    function()
        vim.cmd("Xplrr")
    end,
{
    desc = "XPLRR init",
    silent = true,
    noremap = true
})

vim.keymap.set("n", "<C-S-p>",
    function()
        vim.cmd("Cmdc")
    end,
{
    desc = "CMDC init",
    silent = true,
    noremap = true
})
