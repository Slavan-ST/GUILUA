local class = require("lib.middleclass")
local Element = require("src.ui.core.Element")

local UIButton = class("UIButton", Element)

function UIButton:initialize(x, y, width, height, label, options)
    Element.initialize(self, x, y, width, height)
    
    self.label = label or "Button"
    self.options = options or {}
    
    -- Внешний вид
    self.backgroundColor = self.options.backgroundColor or {0.2, 0.4, 0.8, 1}
    self.textColor = self.options.textColor or {1, 1, 1, 1}
    self.font = self.options.font or love.graphics.getFont()
    self.borderRadius = self.options.borderRadius or 4
    self.padding = self.options.padding or 8
    
    -- Состояния
    self.pressed = false
    self.hovered = false
    self.enabled = true
    
    -- Коллбэки
    self.onClick = self.options.onClick
end

function UIButton:onTouchPressed(id, x, y, dx, dy, pressure)
    if not self.enabled then return false end
    self.pressed = true
    return true -- Обработано
end

function UIButton:onTouchReleased(id, x, y, dx, dy, pressure)
    if not self.enabled or not self.pressed then return false end
    
    self.pressed = false
    
    -- Если отпускание произошло внутри кнопки
    if self:isInside(x, y) and self.onClick then
        self.onClick(self)
    end
    
    return true -- Обработано
end

function UIButton:onTouchMoved(id, x, y, dx, dy, pressure)
    if not self.enabled or not self.pressed then return false end
    
    -- Обновляем состояние наведения
    self.hovered = self:isInside(x, y)
    
    return true -- Обработано
end

function UIButton:setLabel(label)
    self.label = label
end

function UIButton:setEnabled(enabled)
    self.enabled = enabled
end

function UIButton:draw()
    
        -- Отладочная рамка
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    if not self.visible then return end
    
    -- Сохраняем текущий цвет
    local r, g, b, a = love.graphics.getColor()
    
    -- Определяем цвет кнопки на основе состояния
    local bgColor = {unpack(self.backgroundColor)}
    
    if not self.enabled then
        -- Делаем цвет более серым для отключенного состояния
        bgColor[1] = bgColor[1] * 0.7
        bgColor[2] = bgColor[2] * 0.7
        bgColor[3] = bgColor[3] * 0.7
        bgColor[4] = bgColor[4] * 0.7
    elseif self.pressed then
        -- Затемняем для нажатого состояния
        bgColor[1] = bgColor[1] * 0.8
        bgColor[2] = bgColor[2] * 0.8
        bgColor[3] = bgColor[3] * 0.8
    elseif self.hovered then
        -- Делаем ярче для наведения
        bgColor[1] = math.min(bgColor[1] * 1.2, 1)
        bgColor[2] = math.min(bgColor[2] * 1.2, 1)
        bgColor[3] = math.min(bgColor[3] * 1.2, 1)
    end
    
    -- Рисуем фон кнопки
    love.graphics.setColor(unpack(bgColor))
    
    -- Если LÖVE поддерживает скругленные прямоугольники
    if love.graphics.newCanvas then -- Проверка поддержки новой функциональности
        if self.borderRadius > 0 then
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.borderRadius, self.borderRadius)
        else
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        end
    else
        -- Запасной вариант для старых версий
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end
    
    -- Рисуем текст по центру
    love.graphics.setColor(unpack(self.textColor))
    love.graphics.setFont(self.font)
    
    local textWidth = self.font:getWidth(self.label)
    local textHeight = self.font:getHeight()
    local textX = self.x + (self.width - textWidth) / 2
    local textY = self.y + (self.height - textHeight) / 2
    
    love.graphics.print(self.label, textX, textY)
    
    -- Восстанавливаем старый цвет
    love.graphics.setColor(r, g, b, a)
    
    -- Рисуем дочерние элементы (если есть)
    for _, child in ipairs(self.children) do
        if child.draw then
            child:draw()
        end
    end
end

return UIButton