local class = require("lib.middleclass")
local EventDispatcher = require("src.ui.core.EventDispatcher")

-- Подключаем миксины
local Hierarchy = require("src.ui.core.mixins.Hierarchy")
local Visibility = require("src.ui.core.mixins.Visibility")
local Geometry = require("src.ui.core.mixins.Geometry")
local ZIndex = require("src.ui.core.mixins.ZIndex")
local Interactivity = require("src.ui.core.mixins.Interactivity")
local ContentLayout = require("src.ui.core.mixins.ContentLayout")
local Stylable = require("src.ui.core.mixins.Stylable")
local Draggable = require("src.ui.core.mixins.Draggable")
local DropTarget = require("src.ui.core.mixins.DropTarget")
local Animation = require("src.ui.core.mixins.Animation")



local Element = class("Element")

-- Применяем миксины
Element:mixin(Hierarchy)
Element:mixin(Visibility)
Element:mixin(Geometry)
Element:mixin(ZIndex)
Element:mixin(Interactivity)
Element:mixin(ContentLayout)
Element:mixin(EventDispatcher)
Element:mixin(Stylable) -- <<< Добавляем стилизуемость
Element:mixin(Draggable)
Element:mixin(DropTarget)
Element:mixin(Animation)

function Element:initialize(options)
  
   self.options = options or {}
  
    -- Инициализируем EventDispatcher
    EventDispatcher.initialize(self, self.options)

    -- Инициализируем миксины
    Hierarchy.initialize(self, self.options)
    Visibility.initialize(self, self.options)
    Geometry.initialize(self, self.options)
    ZIndex.initialize(self, self.options)
    Interactivity.initialize(self, self.options)
    ContentLayout.initialize(self, self.options)
    Stylable.initialize(self, self.options)
    Draggable.initialize(self, self.options)
    DropTarget.initialize(self, self.options)
    Animation.initialize(self, self.options)
    
end

-- Обработка события
-- src/ui/core/Element.lua

function Element:handleEvent(event)
    return self:dispatchEvent(event)
end

function Element:draw()
    if not self.visible then return end

    self:sortChildren()

    love.graphics.push()
    --love.graphics.translate(self.x, self.y)

    self:drawSelf()

    if self.children and #self.children > 0 then
        for _, child in ipairs(self.children) do
            child:draw()
        end
    end

    love.graphics.pop()
end

function Element:update(dt)
    self:updateAnimations(dt) -- <<< Добавьте это
    -- ... остальной код ...
end

function Element:drawSelf()
    -- Рисуем фон
    
    love.graphics.setColor(self:getStyle("background_color"))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
end


return Element