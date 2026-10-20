local M = {}

local function get_text_edit_start(item)
    local edit = item.textEdit

    if type(edit) ~= "table" then
        return nil
    end

    if type(edit.range) == "table" and type(edit.range.start) == "table" then
        return edit.range.start.character
    end

    if type(edit.insert) == "table" and type(edit.insert.start) == "table" then
        return edit.insert.start.character
    end

    if type(edit.replace) == "table" and type(edit.replace.start) == "table" then
        return edit.replace.start.character
    end

    return nil
end

local function make_relative(text, item_start, line_text, word_start)
    if item_start < word_start then
        local covered = line_text:sub(item_start + 1, word_start)

        if #covered > 0 and text:sub(1, #covered) == covered then
            return text:sub(#covered + 1)
        end
    elseif item_start > word_start then
        local typed = line_text:sub(word_start + 1, item_start)

        return typed .. text
    end

    return text
end

--- Rewrites completion text to start from `word_start`.
---
--- vtsls sends a leading dot when completing right after a dot. Its text
--- edit starts on the dot, while `vim.fn.complete` starts after the typed
--- word. Removing the covered dot keeps the existing dot and avoids `Foo..BAR`.
---
--- @param item table LSP CompletionItem
--- @param line_text string current line
--- @param word_start integer 0-based column where the typed word starts
--- @return table resolved `text`, `start`, and `filter`
function M.resolve(item, line_text, word_start)
    local text = (type(item.textEdit) == "table" and item.textEdit.newText) or item.insertText

    if type(text) ~= "string" then
        text = item.label or ""
    end

    local item_start = get_text_edit_start(item) or word_start

    item_start = math.max(0, item_start)

    local filter_source = item.filterText

    if type(filter_source) ~= "string" then
        filter_source = text
    end

    return {
        text = make_relative(text, item_start, line_text, word_start),
        start = item_start,
        filter = make_relative(filter_source, item_start, line_text, word_start),
    }
end

return M
