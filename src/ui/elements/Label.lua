local Element = require("src.ui.core.Element")
local class = require("lib.middleclass")

local Label = class("Label", Element)

function Label:initialize(x, y, text, color, options)
    options = options or {}
    Element.initialize(self, x, y, 0, 0, options) -- Ширина и высота будут вычислены при установке текста
    
    self.text = text or ""
    self.font = love.graphics.getFont()
    self.color = color or {1, 1, 1, 1} -- Белый цвет по умолчанию
    self.align = options.align or "left" -- left, center, right
    self.wrap = options.wrap or false -- Перенос текста
    self.limit = options.limit -- Максимальная ширина текста
    
    
    
    -- Вычисляем размеры при инициализации
    self:updateDimensions()
end

-- Обновляет размеры label в соответствии с текстом
function Label:updateDimensions()
    if not self.font then return end
    
    if self.wrap and self.limit then
        self.width = self.limit
        local _, wrapped = self.font:getWrap(self.text, self.limit)
        self.height = #wrapped * self.font:getHeight()
    else
        self.width = self.font:getWidth(self.text)
        self.height = self.font:getHeight()
    end
end

-- Устанавливает текст и обновляет размеры
function Label:setText(text)
    self.text = text or ""
    self:updateDimensions()
    return self
end

-- Устанавливает шрифт и обновляет размеры
function Label:setFont(font)
    self.font = font or love.graphics.getFont()
    self:updateDimensions()
    return self
end

-- Устанавливает цвет текста
function Label:setColor(color)
    self.color = color or {1, 1, 1, 1}
    return self
end

-- Устанавливает выравнивание текста
function Label:setAlign(align)
    self.align = align or "left"
    return self
end

-- Отрисовка label
function Label:drawSelf()
    
    if not self.visible or not self.font or #self.text == 0 then return end
    
    
    
    local oldColor = {love.graphics.getColor()}
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.color)
    
    if self.wrap and self.limit then
        love.graphics.printf(self.text, self.x, self.y, self.limit, self.align)
    else
        local x = self.x
        if self.align == "center" then
            x = x + (self.width / 2)
        elseif self.align == "right" then
            x = x + self.width
        end
        
        love.graphics.print(self.text, x, self.y, 0, 1, 1, 
                           self.align == "center" and self.width/2 or 
                           self.align == "right" and self.width or 0)
    end
    
    love.graphics.setColor(oldColor)
end

return Label