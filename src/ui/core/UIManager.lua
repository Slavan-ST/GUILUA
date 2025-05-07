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
    self:sortElements() -- Сортируем сразу
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


-- src/ui/core/UIManager.lua

function UIManager:findTargetElement(event)
    if not event.x or not event.y then return nil end

    -- Сортируем по z-index
    if self.needsSort then
        self:sortElements()
    end

    local target = nil

    -- Проверяем с конца (самый верхний)
    for i = #self.elements, 1, -1 do
        local el = self.elements[i]
        if el.visible and el.enabled and el:isInside(event.x, event.y) then
            target = self:checkChildrenForTarget(el, event)
            if target then break end
        end
    end

    return target
end

function UIManager:checkChildrenForTarget(element, event)
    -- Если есть дочерние элементы, проверяем их рекурсивно
    if element.children and #element.children > 0 then
        for i = #element.children, 1, -1 do
            local child = element.children[i]
            if child.visible and child.enabled and child:isInside(event.x, event.y) then
                local result = self:checkChildrenForTarget(child, event)
                if result then return result end
            end
        end
    end

    return element -- если среди детей никто не подошёл, возвращаем сам элемент
end

function UIManager:handleEvent(event)
    local target = self:findTargetElement(event)

    if target then
        event.target = target
        return target:dispatchEvent(event)
    end

    return false
end


function UIManager:setFocus(element)
    if not element or not element.interactive then return end -- 
    
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