local EventDispatcher = {}

function EventDispatcher:initialize()
    self._listeners = {}  -- Слушатели для текущего элемента
end

-- Добавление слушателя
function EventDispatcher:addEventListener(eventType, callback)
    assert(type(callback) == "function", "Callback must be a function")
    if not self._listeners[eventType] then
        self._listeners[eventType] = {}
    end
    table.insert(self._listeners[eventType], callback)
end

-- Удаление слушателя
function EventDispatcher:removeEventListener(eventType, callback)
    local listeners = self._listeners[eventType]
    if not listeners then return end
    for i = #listeners, 1, -1 do
        if listeners[i] == callback then
            table.remove(listeners, i)
            break
        end
    end
end

-- Диспетчеризация события
function EventDispatcher:dispatchEvent(event)
    assert(type(event) == "table", "Event must be a table")
    assert(event.type, "Event must have a type")

    event.target = event.target or self
    event._stopped = false
    event._immediateStopped = false
    event.stopPropagation = function() 
        event._stopped = true 
    end
    event.stopImmediatePropagation = function()
        event._immediateStopped = true
        event._stopped = true
    end

    -- Сбор цепочки от текущего объекта до корня
    local chain = {}
    local current = self
    while current do
        table.insert(chain, 1, current)  -- Вставляем в начало — чтобы сверху вниз
        current = current.parent
    end

    -- Phase 1: Capture (from root to target)
    for i = 1, #chain - 1 do
        current = chain[i]
        event.currentTarget = current
        event.eventPhase = "capture"

        if current:canHandleEvent(event) then
            local listeners = current._listeners["oncapture_" .. event.type]
            if listeners then
                local copy = { unpack(listeners) }
                for _, callback in ipairs(copy) do
                    if event._immediateStopped then break end
                    callback(event)
                end
            end
        end

        if event._stopped then break end
    end

    -- Phase 2: Target (the actual object where the event was triggered)
    event.currentTarget = self
    event.eventPhase = "target"

    if self:canHandleEvent(event) then
        local listeners = self._listeners[event.type]
        if listeners then
            local copy = { unpack(listeners) }
            for _, callback in ipairs(copy) do
                if event._immediateStopped then break end
                callback(event)
            end
        end
    end

    -- Phase 3: Bubbling (from target to root)
    if event.bubbles ~= false then
        for i = #chain - 1, 1, -1 do
            current = chain[i]
            event.currentTarget = current
            event.eventPhase = "bubbling"

            if current:canHandleEvent(event) then
                local listeners = current._listeners[event.type]
                if listeners then
                    local copy = { unpack(listeners) }
                    for _, callback in ipairs(copy) do
                        if event._immediateStopped then break end
                        callback(event)
                    end
                end
            end

            if event._stopped then break end
        end
    end

    return not event._immediateStopped
end


-- Проверка, можно ли обработать событие
function EventDispatcher:canHandleEvent(event)
    return self.visible and self.enabled  -- проверка видимости и активности
end

return EventDispatcher