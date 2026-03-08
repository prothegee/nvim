local this = require"prt.cmdp"

local commands = {
    ["MARKDOWN: Buffer Render"] = function()
        vim.cmd("RenderMarkdown toggle")
    end,
    --
    ["MARKDOWN: Browser Run"] = function()
        vim.cmd("MarkdownPreview")

        -- actual plugin config
        local m = require"plugins.markdown-preview"

        vim.schedule(function()
            vim.print("markdown-preview has start at: http://localhost:" .. m.port)
        end)
    end,
    ["MARKDOWN: Browser Stop"] = function()
        vim.cmd("MarkdownPreviewStop")

        vim.schedule(function()
            vim.print("markdown-preview has stop")
        end)
    end,
    ["MARKDOWN: Browser Refresh"] = function()
        vim.cmd("MarkdownPreviewRefresh")

        vim.schedule(function()
            vim.print("markdown-preview has stop")
        end)
    end,
    --
    ["TYPST: Preview Run"] = function()
        vim.cmd("TypstPreview")
    end,
    ["TYPST: Preview Stop"] = function()
        vim.cmd("TypstPreviewStop")
    end,
    --
    ["INIT: .clangd"] = function()
        local file = ".clangd"
        local source = vim.fn.stdpath("config") .. "/data/init/" .. file
        local target = vim.loop.cwd() .. "/" .. file

        _G.copy_file(source, target)
    end,
    ["INIT: .clang-format"] = function()
        local file = ".clang-format"
        local source = vim.fn.stdpath("config") .. "/data/init/" .. file
        local target = vim.loop.cwd() .. "/" .. file

        _G.copy_file(source, target)
    end,
    ["INIT: .rustfmt.toml"] = function()
        local file = ".rustfmt.toml"
        local source = vim.fn.stdpath("config") .. "/data/init/" .. file
        local target = vim.loop.cwd() .. "/" .. file

        _G.copy_file(source, target)
    end,
    ["INIT: .gitignore"] = function()
        local file = ".gitignore"
        local source = vim.fn.stdpath("config") .. "/data/init/" .. file
        local target = vim.loop.cwd() .. "/" .. file

        _G.copy_file(source, target)
    end,
    ["INIT: .nvimignore"] = function()
        local file = ".nvimignore"
        local source = vim.fn.stdpath("config") .. "/data/init/" .. file
        local target = vim.loop.cwd() .. "/" .. file

        _G.copy_file(source, target)
    end,
    ["INIT: License APACHE 2.0"] = function()
        local file = "LICENSE-APACHE"
        local source = vim.fn.stdpath("config") .. "/data/init/" .. file
        local target = vim.loop.cwd() .. "/" .. file

        _G.copy_file(source, target)
    end,
    ["INIT: License MIT (expat)"] = function()
        local file = "LICENSE-MIT"
        local source = vim.fn.stdpath("config") .. "/data/init/" .. file
        local target = vim.loop.cwd() .. "/" .. file

        _G.copy_file(source, target)
    end,
    ["INIT: License BSD 3 Clause (expat)"] = function()
        local file = "LICENSE-BSD-3-CLAUSE"
        local source = vim.fn.stdpath("config") .. "/data/init/" .. file
        local target = vim.loop.cwd() .. "/" .. file

        _G.copy_file(source, target)
    end,
    ["INIT: README.md"] = function()
        local file = "README.md"
        local source = vim.fn.stdpath("config") .. "/data/init/" .. file
        local target = vim.loop.cwd() .. "/" .. file

        _G.copy_file(source, target)
    end,
    --
    -- ["FZF"] = function()
    --     vim.cmd("FzfLua files")
    -- end,
    -- ["FZF: Buffers"] = function()
    --     vim.cmd("FzfLua buffers")
    -- end,
    -- ["FZF: Quickfix"] = function()
    --     vim.cmd("FzfLua quickfix")
    -- end,
    -- ["FZF: Quickfix Stack"] = function()
    --     vim.cmd("FzfLua quickfix_stack")
    -- end,
    --
    ["XPLRR"] = function() vim.cmd("Xplrr") end,
    ["XPLRR: All"] = function() vim.cmd("XplrrAll") end,
    ["XPLRR: Buffers"] = function() vim.cmd("XplrrBuffers") end,
}

this.setup({
    commands = commands
})
