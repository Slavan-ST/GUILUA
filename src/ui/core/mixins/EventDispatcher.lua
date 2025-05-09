local EventDispatcher = {}

-- Вспомогательная функция для переворота массива
local function reverse(tbl)
    local reversed = {}
    for i = #tbl, 1, -1 do
        table.insert(reversed, tbl[i])
    end
    return reversed
end

function EventDispatcher:initialize()
    self._listeners = {}  -- Хранение слушателей по типам событий
end

-- Добавление слушателя с уникальным ключом
function EventDispatcher:addEventListener(eventType, callback, useCapture)
    assert(type(callback) == "function", "Callback must be a function")
    if not self._listeners[eventType] then
        self._listeners[eventType] = {
            capture = { list = {}, map = {} },
            bubble = { list = {}, map = {} }
        }
    end
    local phase = useCapture and "capture" or "bubble"
    local key = tostring(callback)
    
    -- Проверка на дубликаты через хэш-таблицу
    if not self._listeners[eventType][phase].map[key] then
        table.insert(self._listeners[eventType][phase].list, callback)
        self._listeners[eventType][phase].map[key] = true
    end
end

-- Удаление слушателя через хэш-таблицу
function EventDispatcher:removeEventListener(eventType, callback, useCapture)
    local phase = useCapture and "capture" or "bubble"
    local listeners = self._listeners[eventType]
    if not listeners then return end
    
    local phase_data = listeners[phase]
    local key = tostring(callback)
    
    if phase_data.map[key] then
        -- Поиск и удаление из списка
        for i = 1, #phase_data.list do
            if phase_data.list[i] == callback then
                table.remove(phase_data.list, i)
                phase_data.map[key] = nil
                break
            end
        end
    end
end

-- Диспетчеризация события с корректными фазами
function EventDispatcher:dispatchEvent(event)
    assert(type(event) == "table", "Event must be a table")
    assert(event.type, "Event must have a type")
    
    -- Инициализация событийных свойств
    event.target = self
    event.currentTarget = nil
    event.eventPhase = nil
    event._stopped = false
    event._immediateStopped = false
    
    -- Остановочные методы
    event.stopPropagation = function() event._stopped = true end
    event.stopImmediatePropagation = function()
        event._immediateStopped = true
        event.stopPropagation()
    end
    
    -- Сбор цепочки объектов с защитой от циклов
    local chain = {}
    local current = self
    local max_depth = 1000
    local visited = {}
    
    while current and #chain < max_depth do
        if visited[current] then break end
        visited[current] = true
        table.insert(chain, current)
        current = current.parent
    end
    
    -- Переворачиваем для фазы capture (корень → цель)
    chain = reverse(chain)
    
    -- Фаза capture (от корня к цели)
    for i = 1, #chain do
        current = chain[i]
        event.currentTarget = current
        event.eventPhase = "capture"
        
        if current:canHandleEvent(event) then
            local listeners = current._listeners[event.type]
            if listeners then
                for _, callback in ipairs(listeners.capture.list) do
                    if event._immediateStopped then break end
                    callback(event)
                end
            end
        end
        
        if event._stopped then break end
    end

    -- Фаза target (сам объект)
    event.currentTarget = self
    event.eventPhase = "target"
    
    if self:canHandleEvent(event) then
        local listeners = self._listeners[event.type]
        if listeners then
            for _, callback in ipairs(listeners.bubble.list) do
                if event._immediateStopped then break end
                callback(event)
            end
        end
    end

    -- Фаза bubbling (от цели к корню)
    if event.bubbles == nil then event.bubbles = true end
    -- Фаза bubbling (от цели к корню)
    if event.bubbles then
        -- Итерация от родителя цели к корню (исключаем сам target)
        for i = #chain-1, 1, -1 do  -- Исправление: начинаем с #chain-1 (родитель)
            current = chain[i]
            event.currentTarget = current
            event.eventPhase = "bubbling"
            
            if current:canHandleEvent(event) then
                local listeners = current._listeners[event.type]
                if listeners then
                    for _, callback in ipairs(listeners.bubble.list) do
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

-- Проверка условий обработки события
function EventDispatcher:canHandleEvent(event)
    -- Если свойства не указаны, считаем их true
    return (self.visible ~= false) and (self.enabled ~= false)
end

return EventDispatcher