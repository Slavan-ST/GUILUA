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
local Scissorable = require("src.ui.core.mixins.Scissorable")
local Spacing = require("src.ui.core.mixins.Spacing")
local Offsetable = require("src.ui.core.mixins.Offsetable")


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
Element:mixin(Scissorable)
Element:mixin(Spacing)
Element:mixin(Offsetable)


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
    Scissorable.initialize(self, options)
    Spacing.initialize(self, options)
    Offsetable.initialize(self, options)
    
end

function Element:draw()
    if not self.visible then return end
    self:drawSelf()
end

function Element:update(dt)
    self:updateAnimations(dt)
end

function Element:drawSelf()
    if not self.visible then return end

    love.graphics.push() -- <-- Сначала push()

    -- 1. Устанавливаем scissor (обрезку), если включена
    self:applyScissor()

    -- 2. Рисуем фон элемента
    love.graphics.setColor(self:getStyle("background_color"))
    love.graphics.rectangle(
        "fill",
        self.x + self:getMarginLeft(),
        self.y + self:getMarginTop(),
        self.width - self:getMarginX(),
        self.height - self:getMarginY()
    )

    -- 3. Рисуем рамку, если задана
    local borderColor = self:getStyle("border_color")
    local borderWidth = self:getStyle("border_width") or 0

    if borderColor and borderWidth > 0 then
        love.graphics.setColor(borderColor)
        love.graphics.setLineWidth(borderWidth)
        love.graphics.rectangle(
            "line",
            self.x + self:getMarginLeft() + borderWidth / 2,
            self.y + self:getMarginTop() + borderWidth / 2,
            self.width - self:getMarginX() - borderWidth,
            self.height - self:getMarginY() - borderWidth
        )
    end

    -- 4. Переводим координаты на offset (например, для скролла)
    love.graphics.translate(
        self:getOffsetX(),
        self:getOffsetY()
    )

    -- 5. Рисуем содержимое внутри padding'ов
    love.graphics.translate(
        self.x + self:getMarginLeft() + self:getPaddingLeft(),
        self.y + self:getMarginTop() + self:getPaddingTop()
    )

    -- Вызываем drawContent(), если определён (может быть у контейнеров/прокрутки)
    if self.drawContent then
        self:drawContent()
    end

    love.graphics.pop() -- <-- pop() закрывает весь блок
    self:clearScissor() -- <-- восстанавливаем старый scissor вне push/pop
end
function Element:drawContent()
  if self.children and #self.children > 0 then
                  for _, child in ipairs(self.children) do
                      
                      child:draw()
                      
                  end
            end
end

return Element