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
    -- Валидация входящего события
    assert(type(event) == "table", "Event must be a table")
    assert(event.type, "Event must have a type")

    -- Инициализация свойств события
    event.target = event.target or self
    event.currentTarget = self
    event._stopped = false
    event.stopPropagation = function() 
        event._stopped = true 
    end

    -- Проверка возможности обработки события
    if not self:canHandleEvent(event) then
        return false
    end

    -- Обработка локальных слушателей
    local listeners = self._listeners[event.type]
    if listeners then
        -- Создаем копию списка слушателей на случай его изменения во время обработки
        local listenersCopy = {unpack(listeners)}
        for _, callback in ipairs(listenersCopy) do
            if not event._stopped then
                callback(event)
            end
        end
    end

    -- Обработка всплытия (если не было остановки)
    if not event._stopped then

        if self.parent and event.bubbles ~= false then
             return self.parent:dispatchEvent(event)
        end
    end

    -- Возвращаем true, если событие не было остановлено
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