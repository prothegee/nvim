# nvim - config

__*NOTE:*__
- using vim.pack
- minimalism attempt
- most keymap are default [except](#configured keymap or shortcut])
- meant to use for 0.12.* or above

<br>

## note

- configured for:
    - c, c++, cmake, go, js, ts, python, rust, zig
    <!-- - markdown, sql, html, css, scss, htmx, vue, svelte -->
- check [this file](./lua/settings/lsp.lua) for lsp/s
- check [this file](./lua/settings/treesitter.lua) for treesitters

<br>

## used plugins

see [this file](./lua/plugins/init.lua) for more information

<br>

## internal modules

- [slr](lua/nvim-prt/slr.lua)

- [xplrr](lua/nvim-prt/xplrr.lua)

<!-- - [snppts](lua/nvim-prt/snppts.lua) -->

<br>

## configured keymap or shortcut

- `<C-p>` e.q. `ctrl+p`:
    - open [xplrr](./lua/nvim-prt/xplrr.lua)

- `<C-S-p>` e.q. `ctrl+shift+p`:
    - open [cmdc](./lua/nvim-prt/cmdc.lua)

- `<C-A-t>` e.q. `ctrl+alt+t`:
    - open/close common terminal
    - *any open terminal will be closed

- `<C-A-S-t>` e.q. `ctrl+alt+shift+t`:
    - create empty new tab

<!-- - `<C-x><C-p>`:
    - global fuzzy completion

- `<C-x><C-[>`:
    - global snippet from snppts -->

<br>

---

###### end of readme

