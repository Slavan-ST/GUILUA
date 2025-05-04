local UIManager = {}
UIManager.__index = UIManager

function UIManager:new()
    local obj = {
        elements = {},
        sorted = false
    }
    setmetatable(obj, self)
    return obj
end

function UIManager:addElement(element)
    table.insert(self.elements, element)
    self.needsSort = true  -- Флаг для отложенной сортировки
end

function UIManager:removeElement(element)
    for i, el in ipairs(self.elements) do
        if el == element then
            table.remove(self.elements, i)
            self.needsSort = true
            break
        end
    end
end

function UIManager:sortElements()
    table.sort(self.elements, function(a, b)
        return (a.zIndex or 0) < (b.zIndex or 0)
    end)
    self.needsSort = false
end

function UIManager:draw()
    if self.needsSort then
        self:sortElements()
    end

    for _, el in ipairs(self.elements) do
        if el.draw then el:draw() end
    end
end

function UIManager:sortByZIndex()
    table.sort(self.elements, function(a, b)
        return (a.zIndex or 0) < (b.zIndex or 0)
    end)
    self.sorted = true
end

function UIManager:update(dt)
    for _, el in ipairs(self.elements) do
        if el.update then el:update(dt) end
    end
end


function UIManager:handleEvent(event)
    if not self.sorted then
        self:sortByZIndex()
    end

    -- Перебираем от верхнего к нижнему
    for i = #self.elements, 1, -1 do
        local el = self.elements[i]
        if el.handleEvent and el.isInside and event.x and event.y then
            if el:isInside(event.x, event.y) then
                if el:handleEvent(event) then
                    return true -- событие обработано, не передаём дальше
                end
            end
        end
    end
    return false
end

function UIManager:setFocus(element)
    if self.focused == element then
        return  -- уже в фокусе
    end

    -- Снимаем фокус с предыдущего элемента и его родителей
    if self.focused then
        local oldFocus = self.focused
        oldFocus.hasFocus = false
        oldFocus:dispatchEvent({ type = "focuslost" })

        -- Всплытие focuslost для родителей
        local parent = oldFocus.parent
        while parent do
            parent:dispatchEvent({ type = "focuslost", bubbles = true })
            parent = parent.parent
        end
    end

    -- Устанавливаем фокус на новый элемент
    self.focused = element
    if element then
        element.hasFocus = true
        element:dispatchEvent({ type = "focusgained" })

        -- Всплытие focusgained для родителей
        local parent = element.parent
        while parent do
            parent:dispatchEvent({ type = "focusgained", bubbles = true })
            parent = parent.parent
        end
    end
end

return UIManager