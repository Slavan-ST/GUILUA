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

    -- Инициализация события
    event.target = event.target or self
    event.currentTarget = self
    event.stopPropagation = function() event._stopped = true end
    event._stopped = false

    -- Проверка возможности обработки (с учетом родителей)
    if not self:canHandleEvent(event) then
        return false
    end

    -- Обработка слушателей текущего элемента
    local listeners = self._listeners[event.type]
    if listeners then
        for _, callback in ipairs(listeners) do
            callback(event)
            if event._stopped then break end
        end
    end

    -- Всплытие события к родителям (если не остановлено)
    if not event._stopped and self.parent then
        return self.parent:dispatchEvent(event)
    end

    return not event._stopped
end

-- Метод для добавления миксина
function EventDispatcher.mixin(target)
    target.initialize = EventDispatcher._wrapInit(target.initialize)
    for k, v in pairs(EventDispatcher) do
        if k ~= "mixin" and k ~= "_wrapInit" then
            target[k] = v
        end
    end
end

-- Обёртка для инициализации
function EventDispatcher._wrapInit(origInit)
    return function(self, ...)
        if origInit then origInit(self, ...) end
        EventDispatcher.initialize(self)
    end
end

-- Проверка, можно ли обработать событие
function EventDispatcher:canHandleEvent(event)
    return self.visible and self.enabled  -- проверка видимости и активности
end

return EventDispatcher