local class = require("lib.middleclass")


local EventDispatcher = require("src.ui.core.mixins.EventDispatcher")
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
Element:mixin(Stylable)
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

function Element:draw()
    if not self.visible then return end
    self:drawSelf()
end

function Element:update(dt)
    self:updateAnimations(dt)
end

function Element:drawSelf()
    love.graphics.setColor(self:getStyle("background_color"))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end


return Element