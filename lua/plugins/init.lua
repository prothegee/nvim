local _uv = vim.uv

local function _copy_file(src, dst)
    vim.schedule(function()
        local src_fd, open_err = _uv.fs_open(src, "r", 420) -- 420 = 0o644
        if not src_fd then
            vim.notify("fail to open source file: " .. open_err, vim.log.levels.ERROR)
            return
        end

        local stat, stat_err = _uv.fs_fstat(src_fd)
        if not stat then
            _uv.fs_close(src_fd)
            vim.notify("fail to read file metadata: " .. stat_err, vim.log.levels.ERROR)
            return
        end

        local dst_fd, create_err = _uv.fs_open(dst, "w", 420)
        if not dst_fd then
            _uv.fs_close(src_fd)
            vim.notify("fail to create file destination: " .. create_err, vim.log.levels.ERROR)
            return
        end

        local buf = _uv.fs_read(src_fd, stat.size, 0)
        if not buf then
            _uv.fs_close(src_fd)
            _uv.fs_close(dst_fd)
            vim.notify("failed to read file", vim.log.levels.ERROR)
            return
        end

        local written = _uv.fs_write(dst_fd, buf, 0)
        if not written or written ~= #buf then
            vim.notify("fail to write file", vim.log.levels.WARN)
        end

        _uv.fs_close(src_fd)
        _uv.fs_close(dst_fd)
    end)
end

---

local _gitsigns = require("gitsigns")

_gitsigns.setup()

---

local _hlchunk = require("hlchunk")

local _hlchunk_delay = 90

_hlchunk.setup({
    chunk = {
        enable = true,
        delay = _hlchunk_delay
    },
    indent = {
        enable = true,
        delay = _hlchunk_delay,
        style = {
            "#484848"
        }
    },
    line_num = {
        enable = true,
        delay = _hlchunk_delay
    },
    blank = {
        enable = false
    },
    context = {
        enable = false
    }
})

---

local _cmp = require("cmp")

local _cmp_win_opts = {
    border = "rounded",
    -- winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
}

_cmp.setup({
    enabled = function()
        local buftype = vim.bo.filetype
        if buftype == "prompt" then
            return false
        end
        local is_floating = vim.api.nvim_win_get_config(0).relative ~= ""
        if is_floating then
            return false
        end
        return true
    end,
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },
    window = {
        completion = _cmp.config.window.bordered(_cmp_win_opts),
        documentation = _cmp.config.window.bordered(_cmp_win_opts),
    },
    mapping = _cmp.mapping.preset.insert({
        -- ["<C-b>"] = _cmp.mapping.scroll_docs(-4),
        -- ["<C-f>"] = _cmp.mapping.scroll_docs(4),
        -- ["<C-Space>"] = _cmp.mapping.complete(),
        ["<C-e>"] = _cmp.mapping.abort(),
        ["<CR>"] = _cmp.mapping.confirm({ select = false }),
    }),
    sources = _cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "vsnip" },
    }, {
        { name = "buffer" },
        { name = "path" },
    })
})

---

vim.g.vsnip_highlight_match = 0

vim.g.vsnip_snippet_dir = "~/.config/nvim/data/vsnip"

---

local _render_markdown = require("render-markdown")

_render_markdown.setup()

_render_markdown.disable()

---

local _typst_preview = require("typst-preview")

_typst_preview.setup({
    -- debug = false,
    -- port = 20202,
    -- open_cmd = "firefox %s -P typst-preview --class typst-preview"
})

---

local _smear_cursor = require("smear_cursor")

_smear_cursor.setup()

---

local _markdown_preview = require("markdown_preview")

_markdown_preview.setup({
    port = 5555,
    debounce_ms = 300,
    open_browser = true
})

---

local _xplrr = require("plugins.xplrr")

_xplrr.setup()

---

local _cmdc = require("plugins.cmdc")

_cmdc.setup({
    commands = {
        ["Markdown: Toggle Render (NVIM BUFFER)"] = function()
            vim.cmd("RenderMarkdown toggle")
        end,
        --
        ["XPLRR"] = function()
            _xplrr.toggle()
        end,
        ["XPLRR: All"] = function()
            _xplrr.toggle_all()
        end,
        ["XPLRR: Buffer"] = function()
            _xplrr.toggle_buffers()
        end,
        --
        ["Typst Preview: Run"] = function()
            vim.cmd("TypstPreview")
        end,
        ["Typst Preview: Stop"] = function()
            vim.cmd("TypstPreviewStop")
        end,
        --
        ["TAB: New"] = function()
            vim.cmd("tabnew")
        end,
        ["TAB: New Term"] = function()
            vim.cmd("tabnew +term")
        end,
        --
        ["INIT: .clangd"] = function()
            local file = ".clangd"
            local source = vim.fn.stdpath("config") .. "/data/init/" .. file
            local target = vim.loop.cwd() .. "/" .. file

            _copy_file(source, target)
        end,
        ["INIT: .clang-format"] = function()
            local file = ".clang-format"
            local source = vim.fn.stdpath("config") .. "/data/init/" .. file
            local target = vim.loop.cwd() .. "/" .. file

            _copy_file(source, target)
        end,
        ["INIT: .rustfmt.toml"] = function()
            local file = ".rustfmt.toml"
            local source = vim.fn.stdpath("config") .. "/data/init/" .. file
            local target = vim.loop.cwd() .. "/" .. file

            _copy_file(source, target)
        end,
        ["INIT: .gitignore"] = function()
            local file = ".gitignore"
            local source = vim.fn.stdpath("config") .. "/data/init/" .. file
            local target = vim.loop.cwd() .. "/" .. file

            _copy_file(source, target)
        end,
        ["INIT: .nvimignore"] = function()
            local file = ".nvimignore"
            local source = vim.fn.stdpath("config") .. "/data/init/" .. file
            local target = vim.loop.cwd() .. "/" .. file

            _copy_file(source, target)
        end,
        ["INIT: License MIT (expat)"] = function()
            local file = "LICENSE-MIT"
            local source = vim.fn.stdpath("config") .. "/data/init/" .. file
            local target = vim.loop.cwd() .. "/" .. file

            _copy_file(source, target)
        end,
        ["INIT: License BSD 3 Clause (expat)"] = function()
            local file = "LICENSE-BSD-3-CLAUSE"
            local source = vim.fn.stdpath("config") .. "/data/init/" .. file
            local target = vim.loop.cwd() .. "/" .. file

            _copy_file(source, target)
        end,
        ["INIT: README.md"] = function()
            local file = "README.md"
            local source = vim.fn.stdpath("config") .. "/data/init/" .. file
            local target = vim.loop.cwd() .. "/" .. file

            _copy_file(source, target)
        end,
        --
        ["Markdown Preview: Start"] = function()
            vim.cmd("MarkdownPreview")
        end,
        ["Markdown Preview: Refresh"] = function()
            vim.cmd("MarkdownPreviewRefresh")
        end,
        ["Markdown Preview: Stop"] = function()
            vim.cmd("MarkdownPreviewStop")
        end,
        --
        ["JSON: json"] = function()
            vim.cmd("set filetype=json")
        end,
        ["JSON: json5"] = function()
            vim.cmd("set filetype=json5")
        end,
    }
})
