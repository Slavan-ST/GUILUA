local Drawable = {}

function Drawable:drawSelf()
    -- Обрезка по границам элемента
    love.graphics.setScissor(self.x, self.y, self.width, self.height)

    -- Фон
    if self:getStyle("background_color") then
        love.graphics.setColor(self:getStyle("background_color"))
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height,
            self:getStyle("corner_radius") or 0)
    end

    -- Рамка
    if self:getStyle("border_color") and (self.style.border_width or 0) > 0 then
        love.graphics.setColor(self:getStyle("border_color"))
        love.graphics.setLineWidth(self.style.border_width or 1)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height,
            self:getStyle("corner_radius") or 0)
    end

    -- Сброс обрезки
    love.graphics.setScissor()

    -- Тело контента (если есть)
    love.graphics.push()
    love.graphics.translate(self.x + self:getPaddingLeft(), self.y + self:getPaddingTop())

    self:drawContent()

    love.graphics.pop()
end

-- Можно переопределять в потомках
function Drawable:drawContent()
    -- По умолчанию ничего не рисует
end

return Drawable