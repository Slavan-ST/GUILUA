local DebugConsole = {
    messages = {},
    maxLines = 15,
    visible = true,
    x = 10,
    y = 10,
    width = 300,
    height = 300,
    backgroundColor = {0, 0, 0, 0.7},
    textColor = {1, 1, 1, 1},
    
}

function DebugConsole.log(text)
    table.insert(DebugConsole.messages, 1, tostring(text))
    if #DebugConsole.messages > DebugConsole.maxLines then
        table.remove(DebugConsole.messages)
    end
    print("[DEBUG] " .. text) -- Дублируем в системный лог
end

function DebugConsole.draw()
    if not DebugConsole.visible then return end
    
    
    -- Фон консоли
    love.graphics.setColor(unpack(DebugConsole.backgroundColor))
    love.graphics.rectangle("fill", DebugConsole.x, DebugConsole.y, 
                          DebugConsole.width, DebugConsole.height)
    
    -- Текст консоли
    love.graphics.setColor(unpack(DebugConsole.textColor))
    for i, msg in ipairs(DebugConsole.messages) do
        love.graphics.print(msg, DebugConsole.x + 5, DebugConsole.y + 5 + (i-1)*20)
    end
    
    
end

function DebugConsole.toggle()
    DebugConsole.visible = not DebugConsole.visible
end

return DebugConsole