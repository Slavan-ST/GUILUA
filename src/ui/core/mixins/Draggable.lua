local Draggable = {}

function Draggable:initialize()
    self.draggable = true
    self.isDragging = false
    self.dragOffsetX = 0
    self.dragOffsetY = 0

    -- Подписываемся на события через dispatchEvent
    self:addEventListener("touchpressed", function(e) return self:onTouchPressed(e) end)
    self:addEventListener("touchmoved", function(e) return self:onTouchMoved(e) end)
    self:addEventListener("touchreleased", function(e) return self:onTouchReleased(e) end)
end

function Draggable:enableDrag()
    self.draggable = true
    return self
end

function Draggable:disableDrag()
    self.draggable = false
    self.isDragging = false
    return self
end

-- Обработчик начала перетаскивания
function Draggable:onTouchPressed(event)
    if not self.draggable or not self:isInside(event.x, event.y) then
        return false
    end

    self.isDragging = true
    self.dragOffsetX = event.x - self.x
    self.dragOffsetY = event.y - self.y
    self:startDrag(event)

    return true -- вернём true, чтобы указать, что событие обработано
end

-- Обработчик движения при перетаскивании
function Draggable:onTouchMoved(event)
    if not self.isDragging then return false end

    local newX = event.x - self.dragOffsetX
    local newY = event.y - self.dragOffsetY

    -- Ограничиваем позицию внутри родителя, если он есть
    if self.parent and self.parent.constrainDrag then
        newX, newY = self:constrainPositionWithinParent(newX, newY)
    else
        newX = math.max(0, newX)
        newY = math.max(0, newY)
    end

    self:setPosition(newX, newY)
    self:dispatchEvent({ type = "drag", x = newX, y = newY })

    return true
end

-- Обработчик завершения перетаскивания
function Draggable:onTouchReleased(event)
    if not self.isDragging then return false end

    self.isDragging = false
    self:endDrag(event)

    return true
end

-- Устанавливает новую позицию
function Draggable:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Ограничение координат внутри родительского контейнера
function Draggable:constrainPositionWithinParent(x, y)
    local parent = self.parent
    local maxX = parent.width - self.width
    local maxY = parent.height - self.height
    return math.max(0, math.min(maxX, x)), math.max(0, math.min(maxY, y))
end

-- События начала и окончания drag
function Draggable:startDrag(event)
    self:dispatchEvent({ type = "dragstart", x = self.x, y = self.y })
end

function Draggable:endDrag(event)
    self:dispatchEvent({ type = "dragend", x = self.x, y = self.y })
end

return Draggable