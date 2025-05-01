local class = require("lib.middleclass")
local Element = require("src.ui.core.Element")

local Root = class("Root", Element)

function Root:initialize(width, height)
    Element.initialize(self, 0, 0, width, height)
    self.focusedElement = nil
    self._layers = {
        background = {},
        default = {},
        popup = {},
        overlay = {}
    }
end

function Root:addToLayer(element, layer)
    local target = self._layers[layer] or self._layers.default
    table.insert(target, element)
    element.parent = self
end

function Root:removeElement(element)
    if self.focusedElement == element then
        self:clearFocus()
    end

    for _, layer in pairs(self._layers) do
        for i, e in ipairs(layer) do
            if e == element then
                table.remove(layer, i)
                e.parent = nil
                return
            end
        end
    end
end

function Root:draw()
    for _, layer in pairs(self._layers) do
        for _, element in ipairs(layer) do
            if element.visible and element.draw then
                element:draw()
            end
        end
    end
end

function Root:update(dt)
    for _, layer in pairs(self._layers) do
        for _, element in ipairs(layer) do
            if element.visible and element.update then
                element:update(dt)
            end
        end
    end
end

function Root:dispatch(eventName, ...)
    for _, layer in pairs(self._layers) do
        for i = #layer, 1, -1 do
            local element = layer[i]
            if element.visible and element.handleEvent and element:handleEvent(eventName, ...) then
                return true
            end
        end
    end
    return false
end

function Root:setFocus(element)
    if self.focusedElement == element then return end
    if self.focusedElement and self.focusedElement.onBlur then
        self.focusedElement:onBlur()
        self.focusedElement.hasFocus = false
    end
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

function Root:keyreleased(key, scancode)
    if self.focusedElement and self.focusedElement.keyreleased then
        self.focusedElement:keyreleased(key, scancode)
    end
end

return Root