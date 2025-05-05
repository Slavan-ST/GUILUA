local class = require("lib.middleclass")
local EventDispatcher = require("src.ui.core.EventDispatcher")

-- Подключаем миксины
local Hierarchy = require("src.ui.core.mixins.Hierarchy")
local Visibility = require("src.ui.core.mixins.Visibility")
local Geometry = require("src.ui.core.mixins.Geometry")
local ZIndex = require("src.ui.core.mixins.ZIndex")
local Interactivity = require("src.ui.core.mixins.Interactivity")
local ContentLayout = require("src.ui.core.mixins.ContentLayout")

local Element = class("Element")

-- Применяем миксины
Element:mixin(Hierarchy)
Element:mixin(Visibility)
Element:mixin(Geometry)
Element:mixin(ZIndex)
Element:mixin(Interactivity)
Element:mixin(ContentLayout)
Element:mixin(EventDispatcher)


function Element:initialize(x, y, w, h, options)
    -- Инициализируем EventDispatcher
    EventDispatcher.initialize(self)

    -- Инициализируем миксины
    Hierarchy.initialize(self)
    Visibility.initialize(self)
    Geometry.initialize(self)
    ZIndex.initialize(self)
    Interactivity.initialize(self)
    ContentLayout.initialize(self)

    -- Инициализация свойств
    self.x = x or 0
    self.y = y or 0
    self.width = w or 0
    self.height = h or 0
    self.zIndex = options and options.zIndex or 0
end

-- Обработка события
function Element:handleEvent(event)
    -- Проверка попадания в элемент
    if event.x and event.y and not self:isInside(event.x, event.y) then
        return false
    end
    
    -- Передаем событие в EventDispatcher 
    return self:dispatchEvent(event) 
end

function Element:draw()
    if not self.visible then return end
    love.graphics.setColor(0.7, 0.6, 0.4, 1) -- hsl(256,66.6%,48.1%)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    if not self._childrenSorted then
        self:sortChildren()
    end
    
    
    self:drawSelf()
    -- Рисуем дочерние элементы
    if self.children and #self.children > 0 then
        for _, child in ipairs(self.children) do
            child:drawSelf()
        end
    end
end

function Element:drawSelf()
  --метод переопределяется в дечерних классах
end

return Element