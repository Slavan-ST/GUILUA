local class = require("lib.middleclass")
local Element = require("src.ui.core.Element")

local ContainerElement = class("ContainerElement", Element)

function ContainerElement:initialize(x, y, w, h)
    Element.initialize(self, x, y, w, h)
end

function ContainerElement:addChild(child)
    Element.addChild(self, child)
end

function ContainerElement:removeChild(child)
    Element.removeChild(self, child)
end

function ContainerElement:update(dt)
    if not self.visible then return end
    if self.onUpdate then self:onUpdate(dt) end
    for _, child in ipairs(self.children) do
        if child.update then
            child:update(dt)
        end
    end
end

function ContainerElement:draw()
    if not self.visible then return end
    if self.onDraw then self:onDraw() end
    for _, child in ipairs(self.children) do
        if child.draw then
            child:draw()
        end
    end
end

-- Пробрасываем касания детям
function ContainerElement:touchPressed(id, x, y, dx, dy, pressure)
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        if child.touchPressed and child:touchPressed(id, x, y, dx, dy, pressure) then
            return true
        end
    end
    return false
end

function ContainerElement:touchReleased(id, x, y, dx, dy, pressure)
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        if child.touchReleased and child:touchReleased(id, x, y, dx, dy, pressure) then
            return true
        end
    end
    return false
end

function ContainerElement:touchMoved(id, x, y, dx, dy, pressure)
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        if child.touchMoved and child:touchMoved(id, x, y, dx, dy, pressure) then
            return true
        end
    end
    return false
end

return ContainerElement