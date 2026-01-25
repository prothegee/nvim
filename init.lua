vim.pack.add({
    {
        src = "git@github.com:neovim/nvim-lspconfig.git"
    },
    {
        src = "git@github.com:nvim-treesitter/nvim-treesitter.git"
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

local path_opt = vim.fn.stdpath("data") .. "/site/pack/core/opt"
for _, path in ipairs(vim.fn.glob(path_opt .. "/*", true, true)) do
    if vim.fn.isdirectory(path) then
        vim.opt.rtp:append(path)

        local luadir = path .. "/lua"

        if vim.fn.isdirectory(luadir) then
            vim.opt.rtp:append(luadir)
        end
    end
end

local path_cfg = vim.fn.stdpath("config")
for _, path in ipairs(vim.fn.glob(path_cfg .. "/lua", true, true)) do
    if vim.fn.isdirectory(path) then
        vim.opt.rtp:append(path)
    end
end

require("plugins")
require("settings")
