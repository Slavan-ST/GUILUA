local DebugConsole = {
    messages = {},
    maxLines = 15,
    visible = true,
    x = 10,
    y = 10,
    width = 300,
    height = 200,
    backgroundColor = {0, 0, 0, 0.7},
    textColor = {1, 1, 1, 1},
    scrollOffset = 0,
    lastMessageTime = 0,
    autoScroll = true,
    debugTouchVisible = true,
    debugUIHierarchy = false
}

-- Логирование сообщений
function DebugConsole.log(text)
    table.insert(DebugConsole.messages, 1, {
        text = tostring(text),
        time = love.timer.getTime()
    })
    
    -- Обрезка старых сообщений
    if #DebugConsole.messages > DebugConsole.maxLines * 3 then
        table.remove(DebugConsole.messages)
    end
    
    -- Автопрокрутка к новым сообщениям
    if DebugConsole.autoScroll then
        DebugConsole.scrollOffset = 0
    end
    
    print("[DEBUG] " .. text)
end

-- Отрисовка консоли
function DebugConsole.draw()
    if not DebugConsole.visible then return end
    
    -- Фон консоли
    love.graphics.setColor(unpack(DebugConsole.backgroundColor))
    love.graphics.rectangle("fill", DebugConsole.x, DebugConsole.y, 
                          DebugConsole.width, DebugConsole.height)
    
    -- Текст консоли
    love.graphics.setColor(unpack(DebugConsole.textColor))
    local visibleLines = math.min(DebugConsole.maxLines, #DebugConsole.messages)
    local startIndex = 1 + DebugConsole.scrollOffset
    local endIndex = math.min(startIndex + visibleLines - 1, #DebugConsole.messages)
    
    for i = startIndex, endIndex do
        local msg = DebugConsole.messages[i]
        local relIndex = i - startIndex
        love.graphics.print(msg.text, 
            DebugConsole.x + 5, 
            DebugConsole.y + 5 + relIndex * 20)
    end
    
    -- Отладочная информация (если включена)
    if DebugConsole.debugTouchVisible then
        DebugConsole.drawDebugInfo()
    end
end

-- Отладочная информация
function DebugConsole.drawDebugInfo()
    local ui = UIManager and UIManager.getInstance()
    if not ui then return end
    
    -- Последнее касание
    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.circle("fill", ui.lastTouch.x, ui.lastTouch.y, 15)
    
    -- FPS и координаты
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, love.graphics.getHeight() - 30)
    love.graphics.print(string.format("Touch: %d, %d", ui.lastTouch.x, ui.lastTouch.y), 
        10, love.graphics.getHeight() - 60)
end

-- Логирование иерархии UI
function DebugConsole.logUIHierarchy()
    local ui = UIManager and UIManager.getInstance()
    if not ui or not ui.root then 
        DebugConsole.log("UI Hierarchy: No root element")
        return
    end
    
    DebugConsole.log("=== UI Hierarchy ===")
    local function logElement(el, level)
        local indent = string.rep("  ", level)
        local info = string.format("%s%s [%d,%d %dx%d] %s",
            indent, tostring(el), el.x, el.y, el.width, el.height,
            el.label or "")
        DebugConsole.log(info)
        
        if el.children then
            for _, child in ipairs(el.children) do
                logElement(child, level + 1)
            end
        end
    end
    
    logElement(ui.root, 0)
end

-- Управление консолью
function DebugConsole.toggle()
    DebugConsole.visible = not DebugConsole.visible
    DebugConsole.log("Console " .. (DebugConsole.visible and "shown" or "hidden"))
end

function DebugConsole.toggleDebug()
    DebugConsole.debugTouchVisible = not DebugConsole.debugTouchVisible
    DebugConsole.debugUIHierarchy = not DebugConsole.debugUIHierarchy
    DebugConsole.log("Debug mode: " .. (DebugConsole.debugTouchVisible and "ON" or "OFF"))
end

-- Прокрутка консоли
function DebugConsole.scroll(direction)
    local maxOffset = math.max(0, #DebugConsole.messages - DebugConsole.maxLines)
    DebugConsole.scrollOffset = math.max(0, math.min(maxOffset, DebugConsole.scrollOffset + direction))
    DebugConsole.autoScroll = DebugConsole.scrollOffset == 0
end

-- Обработка ввода для консоли
function DebugConsole.handleInput(key)
    if key == "d" then
        DebugConsole.toggleDebug()
    elseif key == "h" then
        DebugConsole.logUIHierarchy()
    elseif key == "pageup" then
        DebugConsole.scroll(-5)
    elseif key == "pagedown" then
        DebugConsole.scroll(5)
    elseif key == "home" then
        DebugConsole.scrollOffset = 0
        DebugConsole.autoScroll = true
    elseif key == "end" then
        DebugConsole.scrollOffset = math.max(0, #DebugConsole.messages - DebugConsole.maxLines)
        DebugConsole.autoScroll = false
    end
end

-- Перемещение консоли
function DebugConsole.move(x, y)
    DebugConsole.x = math.max(0, math.min(love.graphics.getWidth() - DebugConsole.width, x))
    DebugConsole.y = math.max(0, math.min(love.graphics.getHeight() - DebugConsole.height, y))
end

return DebugConsole