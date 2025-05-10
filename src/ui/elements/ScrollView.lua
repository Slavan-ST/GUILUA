local class = require("lib.middleclass")
local Element = require("src.ui.core.Element")

local ScrollView = class("ScrollView", Element)

function ScrollView:initialize(options)
    options = options or {}
    Element.initialize(self, options)
    self.scissorEnabled = true

    -- === Содержимое прокрутки ===
    self.content = Element:new({
        x = 0,
        y = 0,
        width = self.width,
        height = 0,
        scissor = false,
    })

    

    -- === Позиция прокрутки ===
    self.scrollY = 0
    self.maxScrollY = 0
    self.scrollX = 0
    self.maxScrollX = 0

    -- === Настройки скроллбара ===
    self.scrollBarVisible = false
    self.scrollBarSize = options.scrollBarSize or self:getStyle("scrollbar_size") or 10
    self.scrollBarColor = options.scrollBarColor or self:getStyle("scrollbar_color") or {0.5, 0.5, 0.5, 0.8}
    self.scrollBarMargin = options.scrollBarMargin or self:getStyle("scrollbar_margin") or 4

    -- === Физика инерции ===
    self.friction = options.friction or self:getStyle("friction") or 0.92
    self.maxVelocity = options.maxVelocity or self:getStyle("max_velocity") or 2000

    -- === Переменные для тач-управления ===
    self.touchId = nil
    self.lastTouchY = 0
    self.velocityY = 0

    -- === События ===
    self:addEventListener("touchpressed", function(e) return self:onTouchPressed(e) end)
    self:addEventListener("touchmoved", function(e) return self:onTouchMoved(e) end)
    self:addEventListener("touchreleased", function(e) return self:onTouchReleased(e) end)

    -- === Для драг-н-дропа (если нужно) ===
    self.content.onDrop = function(target, event)
        print("Элемент перетащен сюда:", tostring(target))
    end
    
    --self:addChild(self.content) -- Добавляем контент как дочерний элемент
end

-- === Добавление дочерних элементов в content ===
function ScrollView:addChild(child)
    local offsetY = 0
    if #self.content.children > 0 then
        local lastChild = self.content.children[#self.content.children]
        offsetY = lastChild.y + lastChild.height
    end

    child.x = self.content:getPaddingLeft() or 0
    child.y = offsetY
    self.content:addChild(child)

    self.content:updateContentSize()
    self:updateScrollLimits()
end

-- === Удаление дочернего элемента ===
function ScrollView:removeChild(child)
    self.content:removeChild(child)
    self.content:updateContentSize()
    self:updateScrollLimits()
end

-- === Обновление ограничений прокрутки ===
function ScrollView:updateScrollLimits()
    local padding = self.content:getPaddingY()
    self.maxScrollY = math.max(0, (self.content.contentHeight or 0) - (self.height - padding))
    self.scrollY = math.max(0, math.min(self.scrollY, self.maxScrollY))
    self.scrollBarVisible = self.maxScrollY > 0
end

-- === Логика обновления (для инерции) ===
function ScrollView:update(dt)
    Element.update(self, dt)

    if not self.touchId and math.abs(self.velocityY) > 1 then
        local delta = self.velocityY * dt
        self.scrollY = math.max(0, math.min(self.maxScrollY, self.scrollY + delta))
        self.velocityY = self.velocityY * self.friction

        -- Границы
        if self.scrollY < 0 then
            self.scrollY = 0
            self.velocityY = 0
        elseif self.scrollY > self.maxScrollY then
            self.scrollY = self.maxScrollY
            self.velocityY = 0
        end
    end
end

-- === Обработка событий ===

function ScrollView:onTouchPressed(event)
    if not self:isInside(event.x, event.y) then return false end
    self.touchId = event.id
    self.lastTouchY = event.y
    self.velocityY = 0
    return true
end

function ScrollView:onTouchMoved(event)
    if event.id == self.touchId then
        local deltaY = self.lastTouchY - event.y
        self.lastTouchY = event.y
        self.scrollY = math.max(0, math.min(self.maxScrollY, self.scrollY + deltaY))
        self.velocityY = deltaY * 15
        return true
    end
    return false
end

function ScrollView:onTouchReleased(event)
    if event.id == self.touchId then
        self.touchId = nil
        return true
    end
    return false
end

function ScrollView:drawContent(width, height)
    love.graphics.push()
    love.graphics.translate(0, -self.scrollY)
    
    -- Применяем scissor один раз для всего контента
    self:applyScissor()
    
    -- Рисуем содержимое
    for _, child in ipairs(self.content.children) do
        child:draw()
    end
    
    -- Очищаем scissor после отрисовки всего контента
    self:clearScissor()
    
    love.graphics.pop()
end

-- === Отрисовка скроллбара ===
function ScrollView:drawScrollBar()
    if not self.scrollBarVisible or self.maxScrollY <= 0 then return end

    local scrollAreaHeight = self.height - self.scrollBarMargin * 2
    local scrollBarHeight = math.max(30, scrollAreaHeight * (self.height / (self.content.contentHeight + self.content:getPaddingY())))
    local scrollBarPos = self.scrollBarMargin + (self.scrollY / self.maxScrollY) * (scrollAreaHeight - scrollBarHeight)

    love.graphics.setColor(self.scrollBarColor)
    love.graphics.rectangle("fill",
        self.width - self.scrollBarSize - self.scrollBarMargin,
        scrollBarPos,
        self.scrollBarSize,
        scrollBarHeight
    )
end


-- === drawSelf() наследуется из Element и вызывает drawContent() ===

return ScrollView