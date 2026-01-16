vim.pack.add({
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
    }
})

local paths = vim.fn.stdpath"data" .. "/site/pack/core/opt"
for _, path in ipairs(vim.fn.glob(paths .. "/*", true, true)) do
	if vim.fn.isdirectory(path) then
	    vim.opt.rtp:append(path)

	    local path_lua_dir = path .. "/lua"

	    if vim.fn.isdirectory(path_lua_dir) then
		vim.opt.rtp:append(path_lua_dir)
	    end
	end
end

local paths_nvimprt = vim.fn.stdpath"config" .. "/lua/nvim-prt"
for _, path in ipairs(vim.fn.glob(paths_nvimprt .. "/*", true, true)) do
    if vim.fn.isdirectory(path) then
        vim.opt.rtp:append(path)
    end
end

require"plugins.gitsigns"
require"plugins.hlchunk"
require"plugins.onedarkpro"
require"plugins.render-markdown"
require"plugins.cmp"
require"plugins.typst-preview"
require"plugins.smear-cursor"
require"plugins.nvim-prt"
