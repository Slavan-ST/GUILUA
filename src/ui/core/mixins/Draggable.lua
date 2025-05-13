local UIManager = require("src.ui.core.UIManager")
local uiManager = UIManager.getInstance()

local Draggable = {}

function Draggable:initialize()
    self.draggable = true
    self.isDragging = false

    -- Позиция начала касания для определения драга
    self.startDragX = 0
    self.startDragY = 0
    self.dragThreshold = 5 -- порог смещения в пикселях

    -- Основные параметры драга
    self.dragOffsetX = 0
    self.dragOffsetY = 0

    -- Флаги
    self.constrainDrag = true     -- ограничивать ли перемещение
    self.dragXOnly = false        -- только по X?
    self.dragYOnly = false        -- только по Y?
    self.autoRaise = true         -- поднимать элемент при драге?

    -- Для временного хранения оригинального zIndex
    self.originalZIndex = nil

    -- События
    self:addEventListener("touchpressed", function(e) return self:onTouchPressed(e) end)
    self:addEventListener("touchmoved", function(e) return self:onTouchMoved(e) end)
    self:addEventListener("touchreleased", function(e) return self:onTouchReleased(e) end)

    if self.options.drag then
        self:addEventListener("drag", function(e) return self.options.drag(e) end)
    end
    if self.options.dragstart then
        self:addEventListener("dragstart", function(e) return self.options.dragstart(e) end)
    end
    if self.options.dragend then
        self:addEventListener("dragend", function(e) return self.options.dragend(e) end)
    end
end

-- === Начало касания ===
function Draggable:onTouchPressed(event)
    if not self.draggable or not self:isInside(event.x, event.y) then
        return false
    end

    self.isDragging = false -- не драгаем пока

    -- Сохраняем стартовую точку
    self.startDragX = event.x
    self.startDragY = event.y

    self.dragOffsetX = event.x - self.x
    self.dragOffsetY = event.y - self.y

    return true
end

-- === Проверка начала драга ===
function Draggable:checkDragStart(event)
    local dx = math.abs(event.x - self.startDragX)
    local dy = math.abs(event.y - self.startDragY)

    if dx > self.dragThreshold or dy > self.dragThreshold then
        self.isDragging = true

        -- Поднимаем элемент наверх
        if self.autoRaise then
            self.originalZIndex = self.zIndex
            self:setZIndex(9999)
            uiManager.needsSort = true
        end

        self:startDrag(event)
        return true
    end

    return false
end

-- === Перемещение при драге ===
function Draggable:onTouchMoved(event)
    if self.isDragging then
        local newX = self.x
        local newY = self.y

        if not self.dragXOnly then
            newX = event.x - self.dragOffsetX
        end

        if not self.dragYOnly then
            newY = event.y - self.dragOffsetY
        end

        -- Ограничение по родителю или экрану
        if self.constrainDrag then
            if self.parent then
                newX, newY = self:constrainPositionWithinParent(newX, newY)
            else
                newX, newY = self:constrainPositionWithinScreen(newX, newY)
            end
        end

        self:setPosition(newX, newY)
        self:dispatchEvent({ type = "drag", x = newX, y = newY })

        return true
    else
        return self:checkDragStart(event)
    end
end

-- === Завершение драга ===
function Draggable:onTouchReleased(event)
    if not self.isDragging then return false end

    self.isDragging = false

    -- Восстанавливаем zIndex
    if self.autoRaise then
        local dropTarget = self:findDropTarget(event)
        if dropTarget then
            self:setZIndex(dropTarget.zIndex + 1)
        else
            self:setZIndex(self.originalZIndex)
        end
        self.originalZIndex = nil
        uiManager.needsSort = true
    end

    self:endDrag(event)

    local dropTarget = self._currentDropTarget
    self._currentDropTarget = nil

    if dropTarget then
        dropTarget:onDrop(event)
    end

    return true
end

-- === findDropTarget ===
function Draggable:findDropTarget(event)
    local uiManager = UIManager.getInstance()
    local originalX, originalY = self.x, self.y

    -- Смещаем элемент немного в сторону, чтобы проверка не проходила через него
    self.x = -10000
    self.y = -10000

    local target = uiManager:findTargetElement(event)

    -- Возвращаем позицию
    self.x, self.y = originalX, originalY

    -- Сохраняем целевой элемент
    self._currentDropTarget = target

    return target
end

-- === События начала и окончания драга ===
function Draggable:startDrag(event)
    self:dispatchEvent({ type = "dragstart", x = self.x, y = self.y })
end

function Draggable:endDrag(event)
    self:dispatchEvent({ type = "dragend", x = self.x, y = self.y })
end

-- === Изменение позиции ===
function Draggable:setPosition(x, y)
    self.x = x
    self.y = y
end

-- === Ограничение внутри родителя ===
function Draggable:constrainPositionWithinParent(x, y)
    local parent = self.parent
    local maxX = parent.width - self.width
    local maxY = parent.height - self.height
    return math.max(0, math.min(maxX, x)), math.max(0, math.min(maxY, y))
end

-- === Ограничение по экрану ===
function Draggable:constrainPositionWithinScreen(x, y)
    local sw, sh = love.graphics.getDimensions()
    local minX, minY = 0, 0
    local maxX = sw - self.width
    local maxY = sh - self.height
    return math.max(minX, math.min(maxX, x)), math.max(minY, math.min(maxY, y))
end

return Draggable