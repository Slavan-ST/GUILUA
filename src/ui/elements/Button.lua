local class = require("lib.middleclass")
local Element = require("src.ui.core.Element")
local Button = class("Button", Element)




local class = require("lib.middleclass")
local Element = require("src.ui.core.Element")

local Button = class("Button", Element)


function Button:initialize(x, y, w, h, text, options)
    
    Element.initialize(self, x, y, w, h, options or {})
    self.text = text or "Button"
    self.pressed = false
    self.onClick = options and options.onClick
    self:setStyle(
      { background_color = options and options.backgroundColor or {0.5, 0.5, 0.5, 1} 
      })
    self.textColor = options and options.textColor or {1, 1, 1, 1}
    
    
    

    self:addEventListener("touchpressed", function(event)
        if self:isInside(event.x, event.y) then
            self.pressed = true
        end
        return true -- ВАЖНО!
    end)
    
    self:addEventListener("touchmoved", function(event)
        if self.pressed and not self:isInside(event.x, event.y) then
            self.pressed = false
        end
        return false -- разрешаем другим обработчикам реагировать
    end)
    
    self:addEventListener("touchreleased", function(event)
        if self.pressed and self:isInside(event.x, event.y) then
            if self.onClick then self.onClick(self, event) end
        end
        self.pressed = false
        return false
    end)
end



function Button:draw()
    if not self.visible then return end
    

    -- Вместо этого используйте стили:
    
    -- В Button:draw()
    local bgColor =  self:getStyle("background_color")
    love.graphics.setColor(bgColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.text, self.x, self.y + self.height / 2 - 6, self.width, "center")

    -- Debug frame
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    -- Отрисовка дочерних (если есть)
    for _, child in ipairs(self.children) do
        child:draw()
    end
end

return Button