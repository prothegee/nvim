vim.pack.add({
    {
        src = "git@github.com:neovim/nvim-lspconfig.git"
    },
    {
        src = "git@github.com:nvim-treesitter/nvim-treesitter.git"
    },
    {
        src = "git@github.com:olimorris/onedarkpro.nvim.git"
    },
    {
        src = "git@github.com:shellRaining/hlchunk.nvim.git"
    },
    {
        src = "git@github.com:lewis6991/gitsigns.nvim.git"
    },
    {
        src = "git@github.com:MeanderingProgrammer/render-markdown.nvim.git"
    },
    {
        src = "git@github.com:hrsh7th/cmp-nvim-lsp.git"
    },
    {
        src = "git@github.com:hrsh7th/cmp-buffer.git"
    },
    {
        src = "git@github.com:hrsh7th/cmp-path.git"
    },
    {
        src = "git@github.com:hrsh7th/cmp-cmdline.git"
    },
    {
        src = "git@github.com:hrsh7th/nvim-cmp.git"
    },
    {
        src = "git@github.com:hrsh7th/cmp-vsnip.git"
    },
    {
        src = "git@github.com:hrsh7th/vim-vsnip.git"
    },
    {
        src = "git@github.com:hrsh7th/vim-vsnip-integ.git"
    },
    {
        src = "git@github.com:chomosuke/typst-preview.nvim.git"
    },
    {
        src = "git@github.com:sphamba/smear-cursor.nvim.git"
    },
})

---

local path_opt = vim.fn.stdpath"data" .. "/site/pack/core/opt"
for _, path in ipairs(vim.fn.glob(path_opt .. "/*", true, true)) do
    if vim.fn.isdirectory(path) then
        vim.opt.rtp:append(path)

        local luadir = path .. "/lua"

        if vim.fn.isdirectory(luadir) then
            vim.opt.rtp:append(luadir)
        end
    end
end

local path_nvim_prt = vim.fn.stdpath"config" .. "/lua/nvim-prt"
for _, path in ipairs(vim.fn.glob(path_nvim_prt .. "/*", true, true)) do
    if vim.fn.isdirectory(path) then
        vim.opt.rtp:append(path)
    end
end

---

local _gitsigns = require"gitsigns"

_gitsigns.setup()

---

local _hlchunk = require"hlchunk"

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

local _cmp = require"cmp"

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
        completion = _cmp.config.window.bordered(),
        documentation = _cmp.config.window.bordered(),
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

vim.g.vsnip_highlight_match = 0

vim.g.vsnip_snippet_dir = "~/.config/nvim/data/vsnip"

---

local _render_markdown = require"render-markdown"

_render_markdown.setup()

_render_markdown.disable()

---

local _typst_preview = require"typst-preview"

_typst_preview.setup({
    -- debug = false,
    -- port = 20202,
    -- open_cmd = "firefox %s -P typst-preview --class typst-preview"
})

---

local _smear_cursor = require"smear_cursor"

_smear_cursor.setup()

---

local _prt = {
    -- slr = require"nvim-prt.slr",
    cmdc = require"nvim-prt.cmdc",
    xplrr = require"nvim-prt.xplrr",
    -- snppts = require"nvim-prt.snppts"
}

_prt.cmdc.setup({
    commands = {
        ["Markdown: Toggle Render"] = function()
            vim.cmd("RenderMarkdown toggle")
        end,
        --
        ["XPLRR"] = function()
            _prt.xplrr.toggle()
        end,
        ["XPLRR: All"] = function()
            _prt.xplrr.toggle_all()
        end,
        ["XPLRR: Buffer"] = function()
            _prt.xplrr.toggle_buffers()
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
    }
})


-- _prt.slr.setup()

_prt.xplrr.setup()

-- _prt.snppts.setup()
