local _prt = {
    slr = require"nvim-prt.slr",
    cmdc = require"nvim-prt.cmdc",
    xplrr = require"nvim-prt.xplrr",
    snppts = require"nvim-prt.snppts"
}

---

-- cmdc
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

---

_prt.slr.setup()
_prt.xplrr.setup()
_prt.snppts.setup()
