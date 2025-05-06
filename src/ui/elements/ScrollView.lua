local class = require("lib.middleclass")
local Element = require("src.ui.core.Element")

local ScrollView = class("ScrollView", Element)



function ScrollView:initialize(x, y, w, h, options)
    options = options or {}
    Element.initialize(self, x, y, w, h, options)

    self.content = Element:new(10, 10, w - 10, h + 10, {})

    self.scrollY = 0
    self.maxScrollY = 0
    self.scrollX = 0
    self.maxScrollX = 10

    self.scrollBarVisible = false
    self.scrollBarSize = options.scrollBarSize or self:getStyle("scrollbar_size")
    self.scrollBarColor = options.scrollBarColor or self:getStyle("scrollbar_color")
    self.scrollBarMargin = options.scrollBarMargin or self:getStyle("scrollbar_margin")

    
    self.friction = self:getStyle("friction")
    self.maxVelocity = self:getStyle("max_velocity")

    
    -- Для тач-событий и инерции
    self.touchId = nil
    self.lastTouchY = 0
    self.lastTouchX = 0
    self.velocityY = 0
    
    
    
    -- Обработчики событий
    self:addEventListener("touchpressed", function(e) return self:onTouchPressed(e) end)
    self:addEventListener("touchreleased", function(e) return self:onTouchReleased(e) end)
    self:addEventListener("touchmoved", function(e) return self:onTouchMoved(e) end)
    
    --Element.addChild(self, self.content)
    
  
end

function ScrollView:setContentSize(w, h)
    self.content.width = w
    self.content.height = h
    self:updateScrollLimits()
end



function ScrollView:updateScrollLimits()
    local padding = self.content.padding or 0
    
    self.maxScrollX = math.max(0, (self.content.contentWidth or 0) + 2 * padding - self.width)
    self.maxScrollY = math.max(0, (self.content.contentHeight or 0) + 2 * padding - self.height)
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



function ScrollView:onTouchPressed(event)
    if not self:isInside(event.x, event.y) then return false end
    -- Корректируем координаты события относительно контента
    local adjustedY = event.y + self.scrollY
    for _, child in ipairs(self.content.children) do
        if child:isInside(event.x, adjustedY) then
            return child:handleEvent(event)
        end
    end
    self.touchId = event.id
    self.lastTouchY = event.y
    self.velocityY = 0
    return true
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
        -- В onTouchMoved:

        local deltaX = (self.lastTouchX - event.x)
        self.scrollX = math.max(0, math.min(self.maxScrollX, self.scrollX + deltaX))
        
        local deltaY = (self.lastTouchY - event.y)
        self.scrollY = math.max(0, math.min(self.maxScrollY, self.scrollY + deltaY))
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

    love.graphics.setScissor(self.x, self.y, self.width, self.height)

    -- Фон
    love.graphics.setColor(self:getStyle("background_color"))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    love.graphics.push()
    love.graphics.translate(self.x, self.y - self.scrollY)
    self.content:draw()
    love.graphics.pop()

    love.graphics.setScissor()

    if self.scrollBarVisible and self.maxScrollY > 0 then
        local scrollAreaHeight = self.height - self.scrollBarMargin * 2
        local scrollBarHeight = math.max(30, scrollAreaHeight * (self.height / (self.content.contentHeight or self.height)))
        local scrollBarPos = self.scrollBarMargin + (self.scrollY / self.maxScrollY) * (scrollAreaHeight - scrollBarHeight)

        love.graphics.setColor(self.scrollBarColor)
        love.graphics.rectangle("fill",
            self.x + self.width - self.scrollBarSize - self.scrollBarMargin,
            self.y + scrollBarPos,
            self.scrollBarSize,
            scrollBarHeight
        )
    end
end

function ScrollView:addChild(child)
    self.content:addChild(child)
    self.content:updateContentSize()
    self:updateScrollLimits()
end

function ScrollView:removeChild(child)
    self.content:removeChild(child)
    self:updateScrollLimits()
end

return ScrollView