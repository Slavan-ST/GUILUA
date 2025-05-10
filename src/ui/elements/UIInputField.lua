local class = require("lib.middleclass")
local TextEditable = require("src.ui.core.mixins.TextEditable")
local Element = require("src.ui.core.Element")

UIInputField = class("UIInputField", Element)
UIInputField:mixin(TextEditable)

function UIInputField:initialize(options)
    Element.initialize(self, options)
    TextEditable.initialize(self, options)
    self:setStyle({ background_color = options.backgroundColor or {0.2, 0.2, 0.2, 1} })
end

function UIInputField:draw()
    if not self.visible then return end
    love.graphics.setColor(0.5,0.5,0.5,0.7)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    self:drawTextContent()
    love.graphics.pop()
end 

return UIInputField