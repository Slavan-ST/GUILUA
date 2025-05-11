-- /src/ui/elements/Button.lua

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
        if options.scissor ~= nil then
            self:enableScissor(options.scissor)
        else
            self:enableScissor(false)
        end
    end

    -- === Добавляем обработчик клика ===
    self:addEventListener("click", function()
        if self.onClick then
            self.onClick(self)
        end
    end)
end

-- === Рисование контента кнопки ===
function Button:drawContent()
    love.graphics.setColor(unpack(self:getStyle("text_color") or {1,1,1,1}))
    love.graphics.printf(
        self.text,
        0,
        self.height / 2 - 6,
        self.width,
        "center"
    )
end

return Button