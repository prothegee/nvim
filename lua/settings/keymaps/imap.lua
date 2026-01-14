-- esc when insert mode will be place as current position
vim.api.nvim_set_keymap("i", "<Esc>",
    "<Esc>l",
{
  noremap = true,
  silent = true,
  desc = "Exit insert mode without moving cursor left"
})
