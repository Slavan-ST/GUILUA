local class = require("lib.middleclass")

local UIEventDispatcher = class("UIEventDispatcher")

function UIEventDispatcher:initialize()
    self._listeners = {}
end

-- Добавление слушателя события
function UIEventDispatcher:addEventListener(eventType, callback, context)
    self._listeners[eventType] = self._listeners[eventType] or {}
    table.insert(self._listeners[eventType], {callback = callback, context = context})
    return callback
end

-- Удаление слушателя события
function UIEventDispatcher:removeEventListener(eventType, callback)
    local listeners = self._listeners[eventType]
    if not listeners then return false end
    
    for i = #listeners, 1, -1 do
        if listeners[i].callback == callback then
            table.remove(listeners, i)
            return true
        end
    end
    
    return false
end

-- Удаление всех слушателей
function UIEventDispatcher:removeEventListeners(eventType)
    if eventType then
        self._listeners[eventType] = nil
    else
        self._listeners = {}
    end
end

-- Проверка наличия слушателей
function UIEventDispatcher:hasEventListener(eventType)
    return self._listeners[eventType] ~= nil and #self._listeners[eventType] > 0
end

-- Вызов события
function UIEventDispatcher:dispatchEvent(eventType, ...)
    local listeners = self._listeners[eventType]
    if not listeners then return false end
    
    local result = false
    for _, listener in ipairs(listeners) do
        if listener.context then
            listener.callback(listener.context, ...)
        else
            listener.callback(...)
        end
        result = true
    end
    
    return result
end

-- Альтернативная реализация mixin для middleclass
function UIEventDispatcher.mixin(targetClass)
    -- Копируем методы из UIEventDispatcher в targetClass
    for name, method in pairs(UIEventDispatcher) do
        if name ~= "initialize" and name ~= "mixin" and type(method) == "function" then
            targetClass[name] = method
        end
    end
    
    -- Сохраняем оригинальный initialize если есть
    local originalInitialize = targetClass.initialize
    
    -- Переопределяем initialize
    function targetClass:initialize(...)
        if originalInitialize then
            originalInitialize(self, ...)
        end
        self._listeners = {}
    end
end

return UIEventDispatcher