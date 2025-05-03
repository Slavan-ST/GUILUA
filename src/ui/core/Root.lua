local class = require("lib.middleclass")
local Element = require("src.ui.core.Element")

local Root = class("Root", Element)

function Root:initialize(width, height)
    Element.initialize(self, 0, 0, width, height)
    self.focusedElement = nil  -- управление фокусом
    self._layersEnabled = false -- если true, использует LayeredManager (опционально)
end

-- В Root.lua, добавить после initialize:

function Root:dispatch(eventName, ...)
    -- Обрабатываем события фокуса
    if eventName == "keyPressed" then
        return self:keypressed(...)
    end
    
    -- Обрабатываем touch события
    if eventName == "touchPressed" or eventName == "touchReleased" or eventName == "touchMoved" then
        -- Здесь можно добавить логику обработки touch событий
        -- Например, передать событие дочерним элементам
        for _, child in ipairs(self.children) do
            if child.visible and child[eventName] then
                if child[eventName](child, ...) then
                    return true -- Событие обработано
                end
            end
        end
        return false
    end
    
    -- Для других событий можно использовать UIEventDispatcher
    if self._listeners and self._listeners[eventName] then
        return self:dispatchEvent(eventName, ...)
    end
    
    return false
end

--- Управление фокусом ---
function Root:setFocus(element)
    if self.focusedElement == element then return end

    -- Снимаем фокус с предыдущего элемента
    if self.focusedElement and self.focusedElement.onBlur then
        self.focusedElement:onBlur()
        self.focusedElement.hasFocus = false
    end

    -- Устанавливаем фокус на новый элемент
    self.focusedElement = element
    if element and element.onFocus then
        element:onFocus()
        element.hasFocus = true
    end
end

function Root:clearFocus()
    self:setFocus(nil)
end

function Root:getFocus()
    return self.focusedElement
end

--- Обработка событий (переопределение) ---
function Root:textinput(text)
    if self.focusedElement and self.focusedElement.textinput then
        self.focusedElement:textinput(text)
    end
end

function Root:keypressed(key, scancode, isrepeat)
    if self.focusedElement and self.focusedElement.keypressed then
        self.focusedElement:keypressed(key, scancode, isrepeat)
    end
end

--- Добавление/удаление элементов ---
-- (Теперь наследуется от Element, методы addChild/removeChild уже есть)

--- Отключение слоев (переносим в LayeredManager) ---
function Root:addToLayer(element, layer)
    error("Root:addToLayer() deprecated. Use LayeredManager instead.")
end

function Root:removeElement(element)
    -- Удаляем из детей (родительский метод)
    self:removeChild(element)
    -- Снимаем фокус, если элемент был в фокусе
    if self.focusedElement == element then
        self:clearFocus()
    end
end

function Root:touchPressed(id, x, y, dx, dy, pressure)
    return self:dispatch("touchPressed", id, x, y, dx, dy, pressure)
end

function Root:touchReleased(id, x, y, dx, dy, pressure)
    return self:dispatch("touchReleased", id, x, y, dx, dy, pressure)
end

function Root:touchMoved(id, x, y, dx, dy, pressure)
    return self:dispatch("touchMoved", id, x, y, dx, dy, pressure)
end

function Root:keyPressed(key, scancode, isrepeat)
    return self:dispatch("keyPressed", key, scancode, isrepeat)
end

--- Отрисовка и обновление (базовые методы из Element) ---
-- (Не переопределяем, если не нужно особое поведение)

return Root