-- UTF8Utils.lua
local UTF8Utils = {}

-- Подсчёт количества символов в UTF-8 строке
function UTF8Utils.len(s)
    local _, count = string.gsub(s, "([%z\1-\127\194-\244][\128-\191]*)", "")
    return count
end

-- Получение i-го символа из строки
function UTF8Utils.get_char_at(s, i)
    local pos = 0
    local char_count = 0
    while pos < #s do
        char_count = char_count + 1
        local c = s:byte(pos + 1)
        local size
        if c < 128 then
            size = 1
        elseif c < 192 then
            return nil -- invalid byte
        elseif c < 224 then
            size = 2
        elseif c < 240 then
            size = 3
        elseif c < 245 then
            size = 4
        else
            return nil -- invalid byte
        end
        if char_count == i then
            return s:sub(pos + 1, pos + size)
        end
        pos = pos + size
    end
    return nil
end

-- Безопасное "utf8.sub" — работает как utf8.sub, но без использования оригинального модуля
function UTF8Utils.sub(s, start_idx, end_idx)
    local len = UTF8Utils.len(s)
    start_idx = start_idx or 1
    end_idx = end_idx or len

    if start_idx < 1 then
        start_idx = 1
    elseif start_idx > len then
        return ""
    end

    if end_idx < 1 then
        return ""
    elseif end_idx > len then
        end_idx = len
    end

    local result = ""
    for i = start_idx, end_idx do
        local c = UTF8Utils.get_char_at(s, i)
        if not c then break end
        result = result .. c
    end

    return result
end

return UTF8Utils