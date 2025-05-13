-- /src/ui/core/Element.lua

local class = require("lib.middleclass")
local Drawable = require("src.ui.core.mixins.Drawable")
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
local Scissorable = require("src.ui.core.mixins.Scissorable")
local Spacing = require("src.ui.core.mixins.Spacing")
local Offsetable = require("src.ui.core.mixins.Offsetable")
local InteractiveEvents = require("src.ui.core.mixins.InteractiveEvents") -- ← NEW

local Element = class("Element")

-- Применяем миксины
Element:mixin(Drawable)
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
Element:mixin(Scissorable)
Element:mixin(Spacing)
Element:mixin(Offsetable)
Element:mixin(InteractiveEvents) -- ← NEW

function Element:initialize(options)
   self.options = options or {}
   Drawable.initialize(self, options)
   EventDispatcher.initialize(self, self.options)

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
   Scissorable.initialize(self, options)
   Spacing.initialize(self, options)
   Offsetable.initialize(self, options)
end

function Element:draw()
    if not self.visible then return end
    if self.drawSelf then self:drawSelf() end
end

function Element:update(dt)
    if self.updateAnimations then self:updateAnimations(dt) end
end

function dumpUI(element, depth)
    depth = depth or 0
    local indent = (" "):rep(depth * 2)
    require("src.ui.utils.DebugConsole").log(indent .. tostring(element))
    if element.children then
        for _, child in ipairs(element.children) do
            dumpUI(child, depth + 1)
        end
    end
end





return Element