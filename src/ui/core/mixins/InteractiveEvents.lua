-- /src/ui/core/mixins/InteractiveEvents.lua

local InteractiveEvents = {}

function InteractiveEvents:initialize()
    -- Подписываемся на события через EventDispatcher
    self:addEventListener("touchpressed", function(e) return self:onTouchPressed(e) end)
    self:addEventListener("touchreleased", function(e) return self:onTouchReleased(e) end)
    self:addEventListener("touchmoved", function(e) return self:onTouchMoved(e) end)
    self:addEventListener("keypressed", function(e) return self:onKeyPressed(e) end)
    self:addEventListener("textinput", function(e) return self:onTextInput(e) end)
end

-- Базовая обработка нажатия
function InteractiveEvents:onTouchPressed(event)
    if not self.interactive or not self.enabled then return false end
    self.pressed = true
    return true
end

-- Обработка отпускания
function InteractiveEvents:onTouchReleased(event)
    if self.pressed and self:isInside(event.x, event.y) then
        self:dispatchEvent({ type = "click" })
    end
    self.pressed = false
    return true
end

-- Перемещение пальца
function InteractiveEvents:onTouchMoved(event)
    if self.pressed and not self:isInside(event.x, event.y) then
        self.pressed = false
    end
    return false
end

-- Нажатие клавиши (например Enter)
function InteractiveEvents:onKeyPressed(event)
    return false
end

-- Ввод текста (например, при использовании UIInputField)
function InteractiveEvents:onTextInput(text)
    return false
end

return InteractiveEvents