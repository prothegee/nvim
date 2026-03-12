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
- [netrw-nvim](./lua/plugins/netrw.lua)
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
- [snppts](./lua/prt/snppts.lua)
- [cmpltn](./lua/prt/cmpltn.lua)

<br>

## Configured/Default Keymap/Shortcut


- __*<C-p>*__ e.q. __*ctrl+p*__:
    - open [xplrr](./lua/prt/xplrr.lua)

- __*<C-`>*__ e.q. __*ctrl+alt+t*__:
    - open/close common terminal
    - *any open terminal will be closed

- __*<C-S-p>*__ e.q. __*ctrl+shift+p*__:
    - open [cmdp](./lua/prt/cmdp.lua)

- __*<C-A-S-t>*__ e.q. __*ctrl+alt+t*__:
    - create empty new tab

- __*<C-x><C-o>*__ e.q. __*ctrl+x ctrl+o*__:
    - default completion

- __*<C-x><C-i>*__ e.q. __*ctrl+x ctrl+i*__:
    - internal snippet

read [this file](./lua/settings/keymaps.lua) for more information

<br>

---

###### end of readme

