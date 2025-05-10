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
    self.wrap = options.wrap or false     -- Перенос текста
    self.limit = options.limit            -- Ширина для переноса

    -- === Цвет текста через стиль ===
    self:setStyle({
        text_color = options.color or {1, 1, 1, 1} -- Белый по умолчанию
    })

    -- === Автоматическое обновление размеров ===
    self:autoSize()
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

-- === Рисование контента (текста) внутри padding'ов ===
function Label:drawContent(width, height)
    if #self.text == 0 or not self.font then return end

    local color = self:getStyle("text_color") or {1, 1, 1, 1}
    love.graphics.setFont(self.font)
    love.graphics.setColor(color)

    local x = 0
    local y = 0

    if self.wrap and self.limit then
        love.graphics.printf(self.text, x, y, self.limit, self.align)
    else
        if self.align == "center" then
            x = width / 2
        elseif self.align == "right" then
            x = width
        end

        love.graphics.print(self.text, x, y, 0, 1, 1,
            self.align == "center" and width / 2 or
            self.align == "right" and width or 0)
    end
end

return Label