local class = require("lib.middleclass")

local Element = class("Element")



function Element:initialize(x, y, w, h)
    self.x, self.y = x or 0, y or 0
    self.width, self.height = w or 0, h or 0
    self.visible = true
    self.parent = nil
    self.children = {}
    self._listeners = {}
end

-- Добавление события
function Element:on(eventName, callback)
    self._listeners[eventName] = self._listeners[eventName] or {}
    table.insert(self._listeners[eventName], callback)
end

-- Удаление события
function Element:off(eventName, callback)
    local list = self._listeners[eventName]
    if not list then return end
    for i = #list, 1, -1 do
        if list[i] == callback then
            table.remove(list, i)
        end
    end
end

-- Вызов события
function Element:trigger(eventName, ...)
    local list = self._listeners[eventName]
    if not list then return end
    for _, callback in ipairs(list) do
        callback(...)
    end
end

-- Базовая реализация: переопределяется в потомках
function Element:handleEvent(eventName, ...)
    if self[eventName] then
        return self[eventName](self, ...)
    end
end

-- Вспомогательные функции
function Element:isInside(x, y)
    return x >= self.x and y >= self.y and x <= self.x + self.width and y <= self.y + self.height
end

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
    for _, c in ipairs(self.children) do
        c.parent = nil
    end
    self.children = {}
end

-- Отрисовка (рекурсивно)
function Element:draw()
    if not self.visible then return end
    if self.onDraw then self:onDraw() end
    for _, child in ipairs(self.children) do
        child:draw()
    end
end

-- Обновление (рекурсивно)
function Element:update(dt)
    if not self.enabled then return end
    if self.onUpdate then self:onUpdate(dt) end
    for _, child in ipairs(self.children) do
        child:update(dt)
    end
end

-- Обработка событий
function Element:emit(eventName, ...)
    local handler = self["on" .. eventName]
    if handler then
        local handled = handler(self, ...)
        if handled then return true end
    end

    if self.parent then
        if self.parent.emit then
            return self.parent:emit(eventName, ...)
        elseif self.parent.dispatch then
            return self.parent:dispatch(eventName, ...)
        end
    end

    return false
end

function Element:trigger(eventName, ...)
    if not self._listeners or not self._listeners[eventName] then return end
    for _, callback in ipairs(self._listeners[eventName]) do
        callback(...)
    end
end

function Element:onFocus() end
function Element:onBlur() end
function Element:focus()
    if self.parent and self.parent.setFocus then
        self.parent:setFocus(self)
    end
end

-- В классе Element
function Element:show()
    self.visible = true
end

function Element:hide()
    self.visible = false
end

function Element:isVisible()
    return self.visible
end

function Element:clearEventListeners()
    self.eventListeners = {}
end

function Element:updateLayout()
    -- Простейший пример: если в родителе есть автолейаут, перерассчитываем позицию.
    if self.parent and self.parent.updateLayout then
        self.parent:updateLayout()
    end
end

function Element:touchPressed(id, x, y, dx, dy, pressure)
    if self:isInside(x, y) then
        if self.onTouchPressed then
            self:onTouchPressed(id, x, y, dx, dy, pressure)
        end
        self:trigger("touchPressed", id, x, y, dx, dy, pressure)
        return true
    end
    return false
end

function Element:touchReleased(id, x, y, dx, dy, pressure)
    if self:isInside(x, y) then
        if self.onTouchReleased then
            self:onTouchReleased(id, x, y, dx, dy, pressure)
        end
        self:trigger("touchReleased", id, x, y, dx, dy, pressure)
        return true
    end
    return false
end

function Element:touchMoved(id, x, y, dx, dy, pressure)
    if self:isInside(x, y) then
        if self.onTouchMoved then
            self:onTouchMoved(id, x, y, dx, dy, pressure)
        end
        self:trigger("touchMoved", id, x, y, dx, dy, pressure)
        return true
    end
    return false
end

return Element