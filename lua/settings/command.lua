--[[
note:
* only vim pack related
--]]
local _cmd = {
    nvim_pack_add = "NvimPackAdd",
    nvim_pack_list = "NvimPackList",
    nvim_pack_update = "NvimPackUpdate",
    nvim_pack_remove = "NvimPackRemove"
}

vim.api.nvim_create_user_command(_cmd.nvim_pack_add, function(opts)
    vim.notify("TODO: NvimPackAdd " .. tostring(#opts.fargs) .. " args")
end, { nargs = "*" })

vim.api.nvim_create_user_command(_cmd.nvim_pack_list, function()
    vim.notify("TODO: NvimPackList")
end, {})

vim.api.nvim_create_user_command(_cmd.nvim_pack_update, function()
    vim.pack.update()
end, {})

vim.api.nvim_create_user_command(_cmd.nvim_pack_remove, function(opts)
    vim.notify("TODO: NvimPackRemove " .. tostring(#opts.fargs) .. " args")
end, { nargs = "*" })
