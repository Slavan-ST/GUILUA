-- /src/ui/elements/Label.lua

local class = require("lib.middleclass")
local Element = require("src.ui.core.Element")
local Label = class("Label", Element)

function Label:initialize(options)
    options = options or {}
    Element.initialize(self, options)

    -- === Текст ===
    self.text = options.text or ""
    self.font = options.font or love.graphics.getFont()
    self.align = options.align or "left" -- left, center, right
    self.verticalAlign = options.verticalAlign or "middle" -- top, middle, bottom
    self.wrap = options.wrap or false     -- Перенос текста
    self.limit = options.limit            -- Ширина для переноса

    -- === Цвет текста через стиль ===
    self.textColor = options.color or {1, 1, 1, 1}

    -- === Стили ===
    if options.backgroundColor then
        self:setStyle({ background_color = options.backgroundColor })
    end

    -- === Автоматическое обновление размеров ===
    self:autoSize()

    -- === Обработчики событий ===
    if options.onClick then
        self:addEventListener("click", function(e) return options.onClick(self, e) end)
    end
end

-- === Автоматически вычисляет ширину и высоту под текст ===
function Label:autoSize()
    if not self.font then return end

    if self.wrap and self.limit then
        self.contentWidth = self.limit
        local _, wrapped = self.font:getWrap(self.text, self.limit)
        self.contentHeight = #wrapped * self.font:getHeight()
    else
        self.contentWidth = self.font:getWidth(self.text)
        self.contentHeight = self.font:getHeight()
    end

    -- Если не заданы width/height явно — используем contentWidth/contentHeight
    if not self._widthSetExplicitly then
        self.width = self.contentWidth + self:getPaddingX()
    end
    if not self._heightSetExplicitly then
        self.height = self.contentHeight + self:getPaddingY()
    end
end

-- === Обновляем размеры при изменении текста ===
function Label:setText(text)
    self.text = text or ""
    self:autoSize()
    return self
end

-- === Устанавливаем шрифт ===
function Label:setFont(font)
    self.font = font or love.graphics.getFont()
    self:autoSize()
    return self
end

-- === Устанавливаем выравнивание ===
function Label:setAlign(align)
    self.align = align or "left"
    return self
end

-- === drawContent — рисует внутри padding'а элемента ===
function Label:drawContent(width, height)
    if #self.text == 0 or not self.font then return end

    local color = self.textColor or self:getStyle("text_color") or {1, 1, 1, 1}
    love.graphics.setFont(self.font)
    love.graphics.setColor(color)

    local x = self:getPaddingLeft()
    local y = self:getPaddingTop()
    local availableWidth = self.width - self:getPaddingX()

    if self.wrap and availableWidth > 0 then
        love.graphics.printf(self.text, x, y, availableWidth, self.align)
    else
        if self.align == "center" then
            x = self.width / 2
        elseif self.align == "right" then
            x = self.width - self:getPaddingRight()
        end

        if self.verticalAlign == "middle" then
            y = self.height / 2 - self.font:getHeight() / 2
        elseif self.verticalAlign == "bottom" then
            y = self.height - self.font:getHeight() - self:getPaddingBottom()
        end

        love.graphics.print(self.text, x, y)
    end
end

return Label