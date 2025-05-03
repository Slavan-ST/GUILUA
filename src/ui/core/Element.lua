local class = require("lib.middleclass")
local EventDispatcher = require("src.ui.core.EventDispatcher")

local Element = class("Element")
EventDispatcher.mixin(Element)

-- Инициализация
function Element:initialize(x, y, w, h, options)
    self.x = x or 0
    self.y = y or 0
    self.width = w or 0
    self.height = h or 0
    self.visible = true
    self.enabled = true
    self.parent = nil
    self.children = {}
    self.zIndex = options.zIndex or 0

    EventDispatcher.initialize(self)
end

-- Проверка, попадает ли точка внутри элемента (hit test)
function Element:isInside(x, y)
    return x >= self.x and y >= self.y and x <= self.x + self.width and y <= self.y + self.height
end

-- Обработка события
function Element:handleEvent(event)
    if event.x and event.y then
        event.localX = event.x - self.x
        event.localY = event.y - self.y
        if not self:isInside(event.x, event.y) then
            return false
        end
    end

    -- Передаем событие в EventDispatcher для дальнейшей обработки
    return self:dispatchEvent(event)
end

-- Добавление дочернего элемента
function Element:addChild(child)
    assert(child, "Child cannot be nil")
    child.parent = self
    table.insert(self.children, child)
    table.sort(self.children, function(a, b)
        return (a.zIndex or 0) < (b.zIndex or 0)
    end)
end

function Element:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            c.parent = nil
            return
        end
    end
end

-- Отображение и обновление
function Element:show() self.visible = true; return self end
function Element:hide() self.visible = false; return self end
function Element:enable() self.enabled = true; return self end
function Element:disable() self.enabled = false; return self end

function Element:draw()
    if not self.visible then return end
    self:drawSelf()
    for _, child in ipairs(self.children) do
        child:draw()
    end
end

function Element:update(dt)
    if not self.enabled then return end
    --self:updateSelf(dt)
    for _, child in ipairs(self.children) do
        child:update(dt)
    end
end

function Element:focus()
    if self:getRoot().setFocus then
        self:getRoot():setFocus(self)
    end
end

function Element:getRoot()
    local node = self
    while node.parent do
        node = node.parent
    end
    return node
end

return Element