local class = require("lib.middleclass")
local EventDispatcher = require("src.ui.core.EventDispatcher")

local Element = class("Element")
EventDispatcher.mixin(Element)

-- Инициализация
function Element:initialize(x, y, w, h, options)
    self.x = x or 0
    self.y = y or 0
    self.width = w or 0
    self.height = h or 0
    self.visible = true
    self.enabled = true
    self.parent = nil
    self.children = {}
    self.zIndex = options and options.zIndex or 0  -- Защита от nil
    self.contentWidth = 0  -- Ширина контента
    self.contentHeight = 0 -- Высота контента
    self.padding = 0      -- Отступ между элементами (опционально)

    EventDispatcher.initialize(self)
end

-- Проверка, попадает ли точка внутри элемента (hit test)
function Element:isInside(x, y)
    return x >= self.x and y >= self.y and x <= self.x + self.width and y <= self.y + self.height
end

-- Обработка события
function Element:handleEvent(event)
    -- Рассчитываем глобальные координаты с учетом родителей
    local globalX, globalY = self:toGlobal(event.x, event.y)

    -- Проверка попадания в элемент
    if event.x and event.y and not self:isInside(globalX, globalY) then
        return false  -- событие не попало в элемент
    end

    -- Обновляем локальные координаты относительно текущего элемента
    event.localX = globalX - self.x
    event.localY = globalY - self.y

    -- Передаем событие в EventDispatcher
    return self:dispatchEvent(event)
end

-- Преобразует глобальные координаты с учетом иерархии
function Element:toGlobal(x, y)
    local node = self
    while node.parent do
        x = x + node.parent.x
        y = y + node.parent.y
        node = node.parent
    end
    return x, y
end


-- Модифицируем метод addChild
-- Модифицируем метод addChild для автоматического размещения
function Element:addChild(child)
    assert(child, "Child cannot be nil")
    
    -- Если у ребенка уже есть родитель, сначала удаляем его
    if child.parent then
        child.x, child.y = child.x - child.parent.x, child.y - child.parent.y
        child.parent:removeChild(child)
    end
    
    child.parent = self
    
    -- Автоматическое позиционирование (например, вертикальное)
    child.x = self.padding or 0
    child.y = (self.contentHeight or 0) + (self.padding or 0)
    
    -- Обновляем размеры контента родителя
    self.contentWidth = math.max(self.contentWidth or 0, child.x + child.width)
    self.contentHeight = math.max(self.contentHeight or 0, child.y + child.height)
    
    -- Преобразуем координаты к глобальным
    child.x, child.y = child:toGlobal(child.x, child.y)
    
    table.insert(self.children, child)
    
    -- Автоматическая сортировка по zIndex
    self:sortChildren()
end

-- Метод для ручного обновления размеров контента
function Element:updateContentSize()
    self.contentWidth = 0
    self.contentHeight = 0
    
    for _, child in ipairs(self.children) do
        self.contentWidth = math.max(self.contentWidth, child.x + child.width)
        self.contentHeight = math.max(self.contentHeight, child.y + child.height)
    end
end


function Element:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            c.parent = nil
            return
        end
    end
end

-- Отображение и обновление
function Element:show() self.visible = true; return self end
function Element:hide() self.visible = false; return self end
function Element:enable() self.enabled = true; return self end
function Element:disable() self.enabled = false; return self end

function Element:setZIndex(value)
    self.zIndex = value or 0
    if self.parent then
        self.parent:sortChildren()
    end
end

function Element:sortChildren()
    table.sort(self.children, function(a, b)
        return (a.zIndex or 0) < (b.zIndex or 0)
    end)
    -- Помечаем, что дети отсортированы
    self._childrenSorted = true
end



-- Модифицируем метод drawSelf
function Element:drawSelf()
    local globalX, globalY = self.x, self.y
    -- Базовая реализация (может быть переопределена в дочерних классах)
    love.graphics.setColor(1, 0.1, 0.4, 1) --rgb(
    love.graphics.rectangle("line", globalX, globalY, self.width, self.height)
        -- Рисуем дочерние элементы
    if self.children then
        for _, child in ipairs(self.children) do
            child:draw()
        end
    end
end
function Element:draw()
    --DebugConsole.log("Drawing element at", self.x, self.y, "visible:", self.visible, self.class:typeof())
    if not self.visible then return end

    -- Сортируем детей, если нужно
    if not self._childrenSorted then
        self:sortChildren()
    end

    -- Рисуем сам элемент
    self:drawSelf()
    

end

-- Устанавливает фокус на элемент (с учетом иерархии)
function Element:setFocus()
    local root = self:getRoot()
    if root.setFocus then
        root:setFocus(self)  -- делегируем UIManager
    end
end

-- Возвращает текущий элемент с фокусом в поддереве
function Element:getFocusedChild()
    for _, child in ipairs(self.children) do
        local focused = child:getFocusedChild()
        if focused then
            return focused
        end
    end
    return self.hasFocus and self or nil
end

function Element:update(dt)
    if not self.enabled then return end
    --self:updateSelf(dt)
    for _, child in ipairs(self.children) do
        child:update(dt)
    end
end

function Element:focus()
    if self:getRoot().setFocus then
        self:getRoot():setFocus(self)
    end
end

function Element:getRoot()
    local node = self
    while node.parent do
        node = node.parent
    end
    return node
end

return Element