local middleclass = require("lib.middleclass")

local LayeredManager = middleclass("LayeredManager")

function LayeredManager:initialize()
    self.layers = {
        background = {},
        default = {},
        popups = {},
        overlay = {},
    }
    self.layerOrder = { "background", "default", "popups", "overlay" }
    self.zIndex = {}
end

function LayeredManager:addElementToLayer(element, layer)
    if self.layers[layer] then
        table.insert(self.layers[layer], element)
    end
end

function LayeredManager:bringToFront(element)
    for layer, elements in pairs(self.layers) do
        for i, el in ipairs(elements) do
            if el == element then
                table.remove(elements, i)
                table.insert(self.layers[layer], element)
                return
            end
        end
    end
end

function LayeredManager:setZIndex(element, zIndex)
    self.zIndex[element] = zIndex
end

function LayeredManager:getSortedElements()
    local sorted = {}
    for _, layer in ipairs(self.layerOrder) do
        local elements = self.layers[layer]
        for _, el in ipairs(elements) do
            table.insert(sorted, el)
        end
    end
    table.sort(sorted, function(a, b)
        return (self.zIndex[a] or 0) < (self.zIndex[b] or 0)
    end)
    return sorted
end

function LayeredManager:update(dt)
    for _, el in ipairs(self:getSortedElements()) do
        if el.update then el:update(dt) end
    end
end

function LayeredManager:draw()
    for _, el in ipairs(self:getSortedElements()) do
        if el.visible ~= false and el.draw then
            el:draw()
        end
    end
end

function LayeredManager:handleTouchPressed(id, x, y, dx, dy, pressure)
    for i = #self.layerOrder, 1, -1 do -- от верхнего слоя к нижнему
        local elements = self.layers[self.layerOrder[i]]
        for j = #elements, 1, -1 do
            local el = elements[j]
            if el.touchPressed and el:touchPressed(id, x, y, dx, dy, pressure) then
                return true -- остановить дальше
            end
        end
    end
end

function LayeredManager:handleTouchReleased(id, x, y, dx, dy, pressure)
    for i = #self.layerOrder, 1, -1 do
        local elements = self.layers[self.layerOrder[i]]
        for j = #elements, 1, -1 do
            local el = elements[j]
            if el.touchReleased and el:touchReleased(id, x, y, dx, dy, pressure) then
                return true
            end
        end
    end
end

function LayeredManager:handleTouchMoved(id, x, y, dx, dy, pressure)
    for i = #self.layerOrder, 1, -1 do
        local elements = self.layers[self.layerOrder[i]]
        for j = #elements, 1, -1 do
            local el = elements[j]
            if el.touchMoved and el:touchMoved(id, x, y, dx, dy, pressure) then
                return true
            end
        end
    end
end

return LayeredManager