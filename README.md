# Nvim, Personal Config

__*NOTE:*__
- using vim.pack
- no package manager
- meant to use for 0.12.* or above

<br>

- check [this file](./lua/settings/lsp.lua) for lsp/s
- check [this file](./lua/settings/treesitter.lua) for treesitters

<br>

## Installed Plugins

- [fzf-lua](./lua/plugins/fzf-lua.lua)
- [gitsigns](./lua/plugins/gitsigns.lua)
- [hlchunk](./lua/plugins/hlchunk.lua)
- [smear-cursor](./lua/plugins/smear-cursor.lua)
- [typst-preview](./lua/plugins/typst-preview.lua)
- [markdown-render](./lua/plugins/markdown-render.lua)
- [markdown-preview](./lua/plugins/markdown-preview.lua)
- [nvim-lspconfig](./lua/plugins/nvim-lspconfig.lua)
- [nvim-treesitter](./lua/plugins/nvim-treesitter.lua)
- [nvim-web-devicons](./lua/plugins/nvim-web-devicons.lua)

see `./lua/plugins` directory for more details.

<br>

## [internal plugins](./lua/prt/README.md)

- [cmdp](./lua/prt/cmdp.lua)

<br>

## Configured Keymap/Shortcut

- `<C-S-p>` e.q. `ctrl+shift+p`:
    - open [cmdp](./lua/prt/cmdp.lua)

- `<C-A-t>` e.q. `ctrl+alt+t`:
    - open/close common terminal
    - *any open terminal will be closed

- `<C-A-S-t>` e.q. `ctrl+alt+t`:
    - create empty new tab

- `<C-x><C-o>` e.q. `ctrl+x ctrl+o`:
    - default completion

- `<C-x><C-s>` e.q. `ctrl+x ctrl+s`:
    - default snippet

read [this file](./lua/settings/keymaps.lua) for more information

<br>

---

###### end of readme

