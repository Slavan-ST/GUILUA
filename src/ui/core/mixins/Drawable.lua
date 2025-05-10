local Drawable = {}

function Drawable:initialize(options)
    self.zIndex = options and options.zIndex or 0
end

function Drawable:drawSelf()
    if not self.visible then return end

    love.graphics.push() -- <-- Сначала push()

    -- 1. Устанавливаем scissor (обрезку), если включена
    self:applyScissor()

    -- 2. Рисуем фон элемента
    love.graphics.setColor(self:getStyle("background_color"))
    love.graphics.rectangle(
        "fill",
        self.x + self:getMarginLeft(),
        self.y + self:getMarginTop(),
        self.width - self:getMarginX(),
        self.height - self:getMarginY()
    )

    -- 3. Рисуем рамку, если задана
    local borderColor = self:getStyle("border_color")
    local borderWidth = self:getStyle("border_width") or 0

    if borderColor and borderWidth > 0 then
        love.graphics.setColor(borderColor)
        love.graphics.setLineWidth(borderWidth)
        love.graphics.rectangle(
            "line",
            self.x + self:getMarginLeft() + borderWidth / 2,
            self.y + self:getMarginTop() + borderWidth / 2,
            self.width - self:getMarginX() - borderWidth,
            self.height - self:getMarginY() - borderWidth
        )
    end

    -- 4. Переводим координаты на offset (например, для скролла)
    love.graphics.translate(
        self:getOffsetX(),
        self:getOffsetY()
    )

    -- 5. Рисуем содержимое внутри padding'ов
    love.graphics.translate(
        self.x + self:getMarginLeft() + self:getPaddingLeft(),
        self.y + self:getMarginTop() + self:getPaddingTop()
    )

    -- Вызываем drawContent(), если определён (может быть у контейнеров/прокрутки)
    if self.drawContent then
        self:drawContent()
    end

    love.graphics.pop() -- <-- pop() закрывает весь блок
    self:clearScissor() -- <-- восстанавливаем старый scissor вне push/pop
end
function Drawable:drawContent()
  if self.children and #self.children > 0 then
                  for _, child in ipairs(self.children) do
                      
                      child:draw()
                      
                  end
            end
end

return Drawable