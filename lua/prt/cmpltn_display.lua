local M = {}

local function get_origin(item, label_details)
    local description = label_details.description

    if type(description) == "string" and description ~= "" then
        return description
    end

    local detail = item.detail

    if type(detail) == "string" and detail ~= "" then
        return detail
    end

    return nil
end

--- Builds the fields shown in the completion popup.
---
--- `labelDetails.description` is the import path for vtsls auto imports.
--- Some servers put the source path in `detail` instead, e.g. lua_ls.
--- Vim has one right-side text field, so the origin goes after the category.
---
--- @param item table LSP CompletionItem
--- @return table fields `abbr`, `kind`, and `menu`
function M.fields(item)
    local label_details = type(item.labelDetails) == "table" and item.labelDetails or {}
    local kind = type(item.kind) == "number" and item.kind or 0
    local kind_text = vim.lsp.protocol.CompletionItemKind[kind] or ""
    local origin = get_origin(item, label_details)
    local menu = kind_text

    if origin then
        menu = kind_text ~= "" and (kind_text .. "  " .. origin) or origin
    end

    return {
        abbr = type(item.label) == "string" and item.label or "",
        kind = kind_text:sub(1, 1):lower(),
        menu = menu,
    }
end

return M
