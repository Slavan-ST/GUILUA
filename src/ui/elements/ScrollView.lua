local class = require("lib.middleclass")
local Element = require("src.ui.core.Element")

local ScrollView = class("ScrollView", Element)

function ScrollView:initialize(x, y, w, h, options)
    options = options or {}
    Element:initialize(x, y, w, h, options)
    self.content = Element:new(10, 10, w - 10, h + 10, {})
    
    -- Параметры прокрутки
    self.scrollY = 0
    self.maxScrollY = 0
    self.scrollBarVisible = false
    self.scrollBarSize = options.scrollBarSize or 10
    self.scrollBarColor = options.scrollBarColor or {0.5, 0.5, 0.5, 0.7}
    self.scrollBarMargin = options.scrollBarMargin or 2
    
    -- Для тач-событий и инерции
    self.touchId = nil
    self.lastTouchY = 0
    self.velocityY = 0
    self.friction = 0.92
    self.maxVelocity = 1000
    
    -- Обработчики событий
    self:addEventListener("touchpressed", function(e) return self:onTouchPressed(e) end)
    self:addEventListener("touchreleased", function(e) return self:onTouchReleased(e) end)
    self:addEventListener("touchmoved", function(e) return self:onTouchMoved(e) end)
    
    Element.addChild(self, self.content)
end

function ScrollView:setContentSize(w, h)

end

function ScrollView:updateScrollLimits()
    self.maxScrollY = math.max(0, (self.content.contentHeight or 0) - self.height)
    self.scrollY = math.max(0, math.min(self.scrollY, self.maxScrollY))
    self.scrollBarVisible = self.maxScrollY > 0
end

function ScrollView:update(dt)
    if not self.touchId and math.abs(self.velocityY) > 1 then
        local delta = self.velocityY * dt * 60
        self.scrollY = self.scrollY + delta
        self.velocityY = self.velocityY * self.friction
        
        if self.scrollY < 0 then
            self.scrollY = self.scrollY * 0.3
            self.velocityY = 0
        elseif self.scrollY > self.maxScrollY then
            self.scrollY = self.maxScrollY + (self.scrollY - self.maxScrollY) * 0.3
            self.velocityY = 0
        end
        
        self:updateScrollLimits()
    end
end

-- Обработчики тач-событий
function ScrollView:onTouchPressed(event)
    if not self:isInside(event.x, event.y) then return false end
    
    if not self.touchId then
        self.touchId = event.id
        self.lastTouchY = event.y
        self.velocityY = 0
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

function ScrollView:onTouchMoved(event)
    if event.id == self.touchId then
        local deltaY = self.lastTouchY - event.y
        self.lastTouchY = event.y
        
        self.velocityY = math.max(-self.maxVelocity, math.min(self.maxVelocity, deltaY * 15))
        self.scrollY = self.scrollY + deltaY
        self:updateScrollLimits()
        return true
    end
    return false
end

function ScrollView:drawSelf()
    self.content.height = self.contentHeight
  
    -- Включаем обрезку по области ScrollView
    love.graphics.setScissor(self.x, self.y, self.width, self.height)
    
    -- Рисуем фон
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Сохраняем текущие настройки графики
    love.graphics.push()
    
    -- Смещаем начало координат для контента с учетом позиции ScrollView
    love.graphics.translate(self.x, self.y - self.scrollY)
    
    -- Рисуем контент (все дочерние элементы content)
    -- Передаем 0,0 так как уже сделали трансляцию
    self.content:drawSelf()
    
    -- Восстанавливаем настройки графики
    love.graphics.pop()
    
    -- Выключаем обрезку
    love.graphics.setScissor()
    
    -- Рисуем полосу прокрутки
    if self.scrollBarVisible and self.maxScrollY > 0 then
        local scrollAreaHeight = self.height - self.scrollBarMargin * 2
        local scrollBarHeight = math.max(30, scrollAreaHeight * (self.height / (self.content.contentHeight or self.height)))
        local scrollBarPos = self.scrollBarMargin + (self.scrollY / self.maxScrollY) * (scrollAreaHeight - scrollBarHeight)
        
        love.graphics.setColor(self.scrollBarColor)
        love.graphics.rectangle("fill", 
            self.x + self.width - self.scrollBarSize - self.scrollBarMargin, 
            self.y + scrollBarPos, 
            self.scrollBarSize, 
            scrollBarHeight)
    end
end

-- Методы для работы с дочерними элементами
function ScrollView:addChild(child)
    self.content:addChild(child)
    self:updateScrollLimits()
end

function ScrollView:removeChild(child)
    self.content:removeChild(child)
    self:updateScrollLimits()
end

return ScrollView