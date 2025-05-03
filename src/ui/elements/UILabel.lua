local class = require("lib.middleclass")
local Element = require("src.ui.core.Element")

local UILabel = class("UILabel", Element)

function UILabel:initialize(x, y, text, options)
    options = options or {}
    local width = options.width or 100
    local height = options.height or 30
    
    Element.initialize(self, x, y, width, height)
    
    -- Свойства
    self.text = text or ""
    self.options = options
    self.font = options.font or love.graphics.getFont()
    self.textColor = options.textColor or {1, 1, 1, 1}
    self.backgroundColor = options.backgroundColor or {0, 0, 0, 0} -- Прозрачный по умолчанию
    self.textAlign = options.textAlign or "left" -- left, center, right
    self.verticalAlign = options.verticalAlign or "middle" -- top, middle, bottom
    self.padding = options.padding or {left = 5, top = 5, right = 5, bottom = 5}
    
    -- Если ширина не задана явно, устанавливаем по размеру текста
    if not options.width then
        self:updateDimensions()
    end
end

function UILabel:setText(text)
    self.text = text
    if not self.options.width then
        self:updateDimensions()
    end
end

function UILabel:setFont(font)
    self.font = font
    if not self.options.width then
        self:updateDimensions()
    end
end

function UILabel:updateDimensions()
    if self.font then
        self.width = self.font:getWidth(self.text) + self.padding.left + self.padding.right
        self.height = self.font:getHeight() + self.padding.top + self.padding.bottom
    end
end

function UILabel:draw()
    if not self.visible then return end
    
    -- Сохраняем текущие настройки графики
    local r, g, b, a = love.graphics.getColor()
    local currentFont = love.graphics.getFont()
    
    -- Рисуем фон, если он не полностью прозрачный
    if self.backgroundColor[4] > 0 then
        love.graphics.setColor(unpack(self.backgroundColor))
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end
    
    -- Устанавливаем шрифт и цвет текста
    love.graphics.setFont(self.font)
    love.graphics.setColor(unpack(self.textColor))
    
    -- Вычисляем X-координату текста на основе выравнивания
    local textX = self.x + self.padding.left
    local textWidth = self.font:getWidth(self.text)
    
    if self.textAlign == "center" then
        textX = self.x + (self.width - textWidth) / 2
    elseif self.textAlign == "right" then
        textX = self.x + self.width - textWidth - self.padding.right
    end
    
    -- Вычисляем Y-координату текста на основе вертикального выравнивания
    local textY = self.y + self.padding.top
    local textHeight = self.font:getHeight()
    
    if self.verticalAlign == "middle" then
        textY = self.y + (self.height - textHeight) / 2
    elseif self.verticalAlign == "bottom" then
        textY = self.y + self.height - textHeight - self.padding.bottom
    end
    
    -- Рисуем текст
    love.graphics.print(self.text, textX, textY)
    
    -- Восстанавливаем настройки графики
    love.graphics.setColor(r, g, b, a)
    love.graphics.setFont(currentFont)
    
    -- Рисуем дочерние элементы (если есть)
    for _, child in ipairs(self.children) do
        if child.draw then
            child:draw()
        end
    end
end

return UILabel