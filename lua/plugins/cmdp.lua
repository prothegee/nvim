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
    ["XPLRR"] = function()
        vim.cmd("Xplrr")
    end,
    ["XPLRR: All"] = function()
        vim.cmd("XplrrAll")
    end,
    ["XPLRR: Buffers"] = function()
        vim.cmd("XplrrBuffers")
    end,
    --
    ["TGGL: Auto-Completion On/Off"] = function()
        _G._prt_autocompletion = not _G._prt_autocompletion

        local status = _G._prt_autocompletion and "on" or "off"

        vim.schedule(function()
            vim.notify("auto-completion is now " .. status, vim.log.levels.INFO)
        end)
    end,
    --
    ["SWTCH: Indent 2"] = function()
        require"prt.swtch".global_indent(2)
    end,
    ["SWTCH: Indent 4"] = function()
        require"prt.swtch".global_indent(4)
    end,
    --
    ["SWTCH: Scroll Vim"] = function()
        require"prt.swtch".scroll_type("vim")
    end,
    ["SWTCH: Scroll Nvim"] = function()
        require"prt.swtch".scroll_type("nvim")
    end,
    ["SWTCH: LineNr 0:None"] = function()
        require"prt.swtch".line_number(0)
    end,
    ["SWTCH: LineNr 1:JustNumber"] = function()
        require"prt.swtch".line_number(1)
    end,
    ["SWTCH: LineNr 2:RelativeNumber"] = function()
        require"prt.swtch".line_number(2)
    end,
    ["SWTCH: LineNr 3:RelativeNumberZeroCurrent"] = function()
        require"prt.swtch".line_number(3)
    end,
    --
}

this.setup({
    commands = commands
})

