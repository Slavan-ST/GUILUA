local class = require("lib.middleclass")
local Element = require("src.ui.core.Element")

local Button = class("Button", Element)

function Button:initialize(options)
    Element.initialize(self, options)

    -- === Текст кнопки ===
    self.text = options and options.text or "Button"
    self.pressed = false
    self.onClick = options and options.onClick

    -- === Стили ===
    self:setStyle({
        background_color = options and options.backgroundColor or {0.5, 0.5, 0.5, 1},
        border_color     = options and options.borderColor or nil,
        border_width     = options and options.borderWidth or 0,
        text_color       = options and options.textColor or {1, 1, 1, 1}
    })

    -- === Отступы ===
    if options then
        -- Padding
        if options.padding then
            self:setPadding(options.padding)
        else
            self:setPadding(
                options.paddingLeft or self.paddingLeft,
                options.paddingRight or self.paddingRight,
                options.paddingTop or self.paddingTop,
                options.paddingBottom or self.paddingBottom
            )
        end

        -- Margin
        if options.margin then
            self:setMargin(options.margin)
        else
            self:setMargin(
                options.marginLeft or self.marginLeft,
                options.marginRight or self.marginRight,
                options.marginTop or self.marginTop,
                options.marginBottom or self.marginBottom
            )
        end

        -- Scissor
        if options.scissor ~= nil then
            self:enableScissor(options.scissor)
        else
            self:enableScissor(false)
        end
    end

    -- === События нажатия ===
    self:addEventListener("touchpressed", function(event)
        if self:isInside(event.x, event.y) then
            self.pressed = true
        end
        return true -- Захватываем событие
    end)

    self:addEventListener("touchmoved", function(event)
        if self.pressed and not self:isInside(event.x, event.y) then
            self.pressed = false
        end
        return false
    end)

    self:addEventListener("touchreleased", function(event)
        if self.pressed and self:isInside(event.x, event.y) then
            if self.onClick then self.onClick(self, event) end
        end
        self.pressed = false
        return false
    end)
end

-- === Рисование контента кнопки ===
function Button:drawContent()
    love.graphics.setColor(self:getStyle("text_color"))
    love.graphics.printf(
        self.text,
        0, -- Уже учитываем padding в translate
        self.height / 2 - 6,
        self.width,
        "center"
    )
end

return Button