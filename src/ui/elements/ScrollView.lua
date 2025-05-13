-- /src/ui/elements/ScrollView.lua

local class = require("lib.middleclass")
local Element = require("src.ui.core.Element")
local ScrollView = class("ScrollView", Element)

function ScrollView:initialize(options)
    options = options or {}
    Element.initialize(self, options)

    -- === Стилевые настройки из темы или опций ===
    self.scrollBarSize = options.scrollBarSize or self:getStyle("scrollbar_size", 8)
    self.scrollBarColor = options.scrollBarColor or self:getStyle("scrollbar_color", {0.9, 0.9, 0.3, 0.6})
    self.friction = options.friction or self:getStyle("friction", 0.95)
    self.maxVelocity = options.maxVelocity or self:getStyle("max_velocity", 1200)

    -- === Контент для прокрутки ===
    self.content = Element:new({
        x = 0,
        y = 0,
        width = self.width,
        height = 0,
        scissor = false,
        interactive = false
    })

    -- === Позиция прокрутки ===
    self.scrollY = 0
    self.maxScrollY = 0
    self.scrollX = 0
    self.maxScrollX = 0

    -- === Переменные для тач-управления ===
    self.touchId = nil
    self.lastTouchY = 0
    self.velocityY = 0

    -- === Добавляем контент как дочерний элемент ===
    --Element.addChild(self, self.content)

    -- === Автообновление размеров ===
    if options.autoSize ~= false then
        self:updateContentSize()
    end
    
    self.scissorEnabled = true
end

-- === Добавление дочернего элемента в content ===
function ScrollView:addChild(child)
    local offsetY = 0
    if #self.content.children > 0 then
        local lastChild = self.content.children[#self.content.children]
        offsetY = lastChild.y + lastChild.height
    end
    child.x = self.content:getPaddingLeft() or 0
    child.y = offsetY
    self.content:addChild(child)
    self:updateContentSize()
end

-- === Обновление размера контента ===
function ScrollView:updateContentSize()
    self.content.contentWidth = 0
    self.content.contentHeight = 0
    for _, child in ipairs(self.content.children) do
        self.content.contentWidth = math.max(self.content.contentWidth, child.x + child.width)
        self.content.contentHeight = math.max(self.content.contentHeight, child.y + child.height)
    end
    self.maxScrollY = math.max(0, (self.content.contentHeight or 0) - (self.height - self.content:getPaddingY()))
end

-- === Обновление позиции контента при скролле ===
function ScrollView:update(dt)
    Element.update(self, dt)

    -- Инерция скроллинга
    if not self.touchId and math.abs(self.velocityY) > 1 then
        local delta = self.velocityY * dt
        self.scrollY = math.max(0, math.min(self.maxScrollY, self.scrollY + delta))
        self.velocityY = self.velocityY * self.friction
    end
end



-- === Рисование контента ===
function ScrollView:drawContent(width, height)
    
    love.graphics.translate(0, -self.scrollY)
    self:applyScissor()
    for _, child in ipairs(self.content.children) do
        child:draw()
    end
    self:clearScissor()
    self:drawScrollBar()
end

-- === Отрисовка скроллбара ===
function ScrollView:drawScrollBar()
    if self.maxScrollY == 0 then return end

    local barHeight = math.max(30, self.height * (self.height / (self.content.contentHeight + self.content:getPaddingY())))
    local scrollAreaHeight = self.height - 4
    local barPos = self.scrollY  + (self.scrollY / self.maxScrollY) * (scrollAreaHeight - barHeight)

    love.graphics.setColor(self.scrollBarColor)
    love.graphics.rectangle(
        "fill",
        self.width - self.scrollBarSize,
        barPos,
        self.scrollBarSize,
        barHeight
    )
end

-- === Обработка касаний через InteractiveEvents ===
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
        self.velocityY = deltaY * self:getStyle("touch_scroll_multiplier", 18)
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

return ScrollView