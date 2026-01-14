local NVIM_PRT = {}

local version = {
    major = 0,
    minor = 15,
    patch = 0,
    dates = 20260114,
}

---

-- actual nvim-prt dir
NVIM_PRT.dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")

NVIM_PRT.version = {
    major = version.major,
    minor = version.minor,
    patch = version.patch,
    dates = version.dates,
    strings = string.format("%d.%d.%d.%d", version.major, version.minor, version.patch, version.dates)
}

-- -- nvim-prt options
-- NVIM_PRT.options = {
--     default = false,
-- }

---

-- TMP: disable to preserve
-- function NVIM_PRT.setup(opts)
--     opts = vim.tbl_extend("force", NVIM_PRT.options, opts or {})
--
--     if next(opts) == nil then
--         vim.schedule(function()
--             vim.notify("INFO: NVIM_PRT opts from setup is nil", vim.log.levels.INFO)
--         end)
--         return
--     end
--
--     if opts.default then
--         -- TODO
--     end
-- end

---

return NVIM_PRT

