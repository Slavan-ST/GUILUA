local class = require("lib.middleclass")
local Element = require("src.ui.core.Element")

local Button = class("Button", Element)

function Button:initialize(x, y, w, h, text, options)
    Element.initialize(self, x, y, w, h, options)
    self.text = text or "Button"
    self.pressed = false
    self.onClick = options and options.onClick
    self.backgroundColor = options and options.backgroundColor or {0.5, 0.5, 0.5, 1}
    self.textColor = options and options.textColor or {1, 1, 1, 1}
    
    
    

    self:addEventListener("touchpressed", function(event)
        if self:isInside(event.x, event.y) then
            self.pressed = true
        end
    end)
    
    -- Например, при выходе за границы экрана или при других событиях
    self:addEventListener("touchmoved", function(event)
        if self.pressed and not self:isInside(event.x, event.y) then
            self.pressed = false
        end
    end)

-- 

    self:addEventListener("touchreleased", function(event)
      
        -- в будущем поправить чтобы при выходе за элемент всё нориально работало
        
        if self.pressed and self:isInside(event.x, event.y) then
            
            if self.onClick then self.onClick(self, event) end
      
            
        end
        
        self.pressed = false
    end)
end

function Button:draw()
    if not self.visible then return end

    local bgColor = self.pressed and {0.4, 0.4, 1} or {0.2, 0.2, 0.8}
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