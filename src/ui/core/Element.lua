local class = require("lib.middleclass")
local UIEventDispatcher = require("src.ui.core.UIEventDispatcher")

local Element = class("Element")

-- Миксин для событий
UIEventDispatcher:mixin(Element)

function Element:initialize(x, y, w, h)
    self.x, self.y = x or 0, y or 0
    self.width, self.height = w or 0, h or 0
    self.visible = true
    self.enabled = true
    self.parent = nil
    self.children = {}
    self._listeners = {} -- для совместимости (можно удалить после рефакторинга)
end

--- Базовые методы ---

-- Добавление/удаление дочерних элементов
function Element:addChild(child)
    child.parent = self
    table.insert(self.children, child)
end

function Element:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            c.parent = nil
            break
        end
    end
end

function Element:clearChildren()
    for _, child in ipairs(self.children) do
        child.parent = nil
    end
    self.children = {}
end

-- Видимость
function Element:show()
    self.visible = true
end

function Element:hide()
    self.visible = false
end

function Element:isVisible()
    return self.visible
end

-- Геометрия
function Element:isInside(x, y)
    return x >= self.x and y >= self.y and x <= self.x + self.width and y <= self.y + self.height
end

function Element:setPosition(x, y)
    self.x, self.y = x, y
end

function Element:setSize(w, h)
    self.width, self.height = w, h
end

--- Отрисовка и обновление ---
-- (Базовые методы, которые можно переопределять)

function Element:draw()
    if not self.visible then return end
    -- Переопределяется в потомках
    for _, child in ipairs(self.children) do
        child:draw()
    end
end

function Element:update(dt)
    if not self.enabled then return end
    -- Переопределяется в потомках
    for _, child in ipairs(self.children) do
        child:update(dt)
    end
end

--- Обработка событий ---
-- (Используем UIEventDispatcher вместо ручного управления)

function Element:handleEvent(eventName, ...)
    -- 1. Проверяем наличие специализированного обработчика вида "on{EventName}"
    -- (например: onTouchPressed, onKeyReleased)
    local handler = self["on" .. eventName]
    if handler then
        local result = handler(self, ...)
        if result ~= nil then
            return result -- Возвращаем результат, если обработчик явно вернул true/false
        end
    end

    -- 2. Проверяем прямой метод события (для совместимости)
    -- (например: touchPressed(), keyReleased())
    local directHandler = self[eventName]
    if directHandler then
        local result = directHandler(self, ...)
        if result ~= nil then
            return result
        end
    end

    -- 3. Если элемент имеет UIEventDispatcher (миксин), проверяем слушатели
    if self._listeners and self._listeners[eventName] then
        local stopped = self:dispatchEvent(eventName, ...)
        if stopped then
            return true
        end
    end

    -- 4. Пробрасываем событие родителю (если есть и он поддерживает handleEvent)
    if self.parent and self.parent.handleEvent then
        return self.parent:handleEvent(eventName, ...)
    end

    -- 5. Событие не обработано
    return false
end

-- Фокус
function Element:onFocus() end -- Переопределяется
function Element:onBlur() end  -- Переопределяется

function Element:focus()
    if self.parent and self.parent.setFocus then
        self.parent:setFocus(self)
    end
end

--- Устаревшие методы (можно удалить после рефакторинга) ---
-- (Их заменяет UIEventDispatcher)
function Element:on(eventName, callback) end
function Element:off(eventName, callback) end
function Element:trigger(eventName, ...) end

return Element