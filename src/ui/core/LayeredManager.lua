local middleclass = require("lib.middleclass")
local UIEventDispatcher = require("src.ui.core.UIEventDispatcher")

local LayeredManager = middleclass("LayeredManager")

-- Миксин для событий
UIEventDispatcher:mixin(LayeredManager)

function LayeredManager:initialize()
    -- Слои и их порядок отрисовки (снизу вверх)
    self.layers = {
        background = {}, -- Фоновые элементы
        default = {},    -- Основной слой (аналогично Root)
        popups = {},     -- Модальные окна
        overlay = {}     -- Оверлеи (курсоры, уведомления)
    }
    self.layerOrder = { "background", "default", "popups", "overlay" }
    self.zIndex = {}     -- zIndex для элементов внутри слоев
end

--- Управление элементами ---
function LayeredManager:addToLayer(element, layerName, zIndex)
    local layer = self.layers[layerName or "default"]
    if not layer then
        error("Invalid layer: " .. tostring(layerName))
    end

    table.insert(layer, element)
    self.zIndex[element] = zIndex or 0
    element.parent = self -- Для проброса событий вверх
end

function LayeredManager:removeElement(element)
    for _, layerName in ipairs(self.layerOrder) do
        local layer = self.layers[layerName]
        for i, el in ipairs(layer) do
            if el == element then
                table.remove(layer, i)
                self.zIndex[el] = nil
                el.parent = nil
                return true
            end
        end
    end
    return false
end

--- Управление zIndex ---
function LayeredManager:setZIndex(element, zIndex)
    if not element or not self.zIndex[element] then
        error("Element not found in layers")
    end
    self.zIndex[element] = zIndex
end

--- Отрисовка (с учетом zIndex) ---
function LayeredManager:draw()
    for _, layerName in ipairs(self.layerOrder) do
        local layer = self.layers[layerName]
        -- Сортировка элементов внутри слоя по zIndex
        table.sort(layer, function(a, b)
            return (self.zIndex[a] or 0) < (self.zIndex[b] or 0)
        end)
        -- Отрисовка
        for _, element in ipairs(layer) do
            if element.visible and element.draw then
                element:draw()
            end
        end
    end
end

--- Обновление ---
function LayeredManager:update(dt)
    for _, layerName in ipairs(self.layerOrder) do
        for _, element in ipairs(self.layers[layerName]) do
            if element.visible and element.update then
                element:update(dt)
            end
        end
    end
end

--- Обработка событий (тач, клавиатура) ---
function LayeredManager:handleEvent(eventName, ...)
    -- Обработка событий с верхних слоев вниз
    for i = #self.layerOrder, 1, -1 do
        local layer = self.layers[self.layerOrder[i]]
        for j = #layer, 1, -1 do
            local element = layer[j]
            if element.visible and element.handleEvent then
                if element:handleEvent(eventName, ...) then
                    return true -- Событие обработано
                end
            end
        end
    end
    return false
end

-- Алиасы для удобства (можно вызывать напрямую)
function LayeredManager:touchPressed(...)
    return self:handleEvent("touchPressed", ...)
end

function LayeredManager:touchReleased(...)
    return self:handleEvent("touchReleased", ...)
end

function LayeredManager:touchMoved(...)
    return self:handleEvent("touchMoved", ...)
end

function LayeredManager:keyPressed(...)
    return self:handleEvent("keyPressed", ...)
end


return LayeredManager