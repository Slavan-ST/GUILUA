-- /src/ui/elements/UIInputField.lua

local class = require("lib.middleclass")
local TextEditable = require("src.ui.core.mixins.TextEditable")
local Element = require("src.ui.core.Element")
local UIInputField = class("UIInputField", Element)
UIInputField:mixin(TextEditable)

function UIInputField:initialize(options)
    Element.initialize(self, options)
    TextEditable.initialize(self, options)

    self:setStyle({
        background_color = options.backgroundColor or {0.2, 0.2, 0.2, 1}
    })

    -- Запрашиваем фокус при касании
    self:addEventListener("touchpressed", function(e)
        self:requestFocus()
        love.keyboard.setTextInput(true)
        return true
    end)

    -- Обрабатываем ввод текста и клавиш
    self:addEventListener("textinput", function(text)
        self:textinput(text)
        return true
    end)

    self:addEventListener("keypressed", function(keyEvent)
        self:keypressed(keyEvent.key)
        return true
    end)
end

function UIInputField:drawContent()
    if not self.visible then return end
    love.graphics.setColor(0.5, 0.5, 0.5, 0.7)
    love.graphics.rectangle("fill", 0,0, self.width, self.height)

    
    self:drawTextContent()
end

return UIInputField