local class = require("lib.middleclass")
local Root = require("src.ui.core.Root")
local LayeredManager = require("src.ui.core.LayeredManager")
local DebugConsole = require("src.ui.utils.DebugConsole")

local UIManager = class("UIManager")

-- Синглтон
local instance = nil

function UIManager.getInstance()
    if not instance then
        instance = UIManager()
    end
    return instance
end

function UIManager:initialize()
    self.root = nil
    self.layeredManager = nil
    self.width = 0
    self.height = 0
    self.touchHandlers = {}
    self.lastTouch = {x = 0, y = 0}
end

function UIManager:init(width, height)
    self.width = width or love.graphics.getWidth()
    self.height = height or love.graphics.getHeight()
    
    self.root = Root(self.width, self.height)
    self.layeredManager = LayeredManager()
    
    self:setupLoveHandlers()
    DebugConsole.log("UIManager initialized " .. self.width .. "  " .. self.height)
end

function UIManager:setupLoveHandlers()
    -- Сохраняем оригинальные обработчики
    self.originalHandlers = {
        touchpressed = love.touchpressed,
        touchreleased = love.touchreleased,
        touchmoved = love.touchmoved,
        keypressed = love.keypressed
    }

    -- Переопределяем обработчики LÖVE
    love.touchpressed = function(id, x, y, dx, dy, pressure)
        -- Преобразуем координаты в числа для Android
        x, y = tonumber(x) or 0, tonumber(y) or 0
        self.lastTouch.x, self.lastTouch.y = x, y
        
        -- Вызываем оригинальный обработчик если есть
        if self.originalHandlers.touchpressed then 
            self.originalHandlers.touchpressed(id, x, y, dx, dy, pressure) 
        end
        
        -- Обрабатываем событие
        self:handleTouchPressed(id, x, y, dx, dy, pressure)
    end

    love.touchreleased = function(id, x, y, dx, dy, pressure)
        x, y = tonumber(x) or 0, tonumber(y) or 0
        if self.originalHandlers.touchreleased then 
            self.originalHandlers.touchreleased(id, x, y, dx, dy, pressure) 
        end
        self:handleTouchReleased(id, x, y, dx, dy, pressure)
    end

    love.touchmoved = function(id, x, y, dx, dy, pressure)
        x, y = tonumber(x) or 0, tonumber(y) or 0
        self.lastTouch.x, self.lastTouch.y = x, y
        if self.originalHandlers.touchmoved then 
            self.originalHandlers.touchmoved(id, x, y, dx, dy, pressure) 
        end
        self:handleTouchMoved(id, x, y, dx, dy, pressure)
    end

    love.keypressed = function(key, scancode, isrepeat)
        if self.originalHandlers.keypressed then 
            self.originalHandlers.keypressed(key, scancode, isrepeat) 
        end
        self:handleKeyPressed(key, scancode, isrepeat)
    end
end

function UIManager:handleTouchPressed(id, x, y, dx, dy, pressure)
    -- Масштабирование для высоких DPI
    x = x * (self.width / love.graphics.getWidth())
    y = y * (self.height / love.graphics.getHeight())

    local handled = false
    
    -- 1. Попробовать обработать в layeredManager
    if self.layeredManager then
        handled = self.layeredManager:touchPressed(id, x, y, dx, dy, pressure)
        print("LayeredManager handled:", handled)
    end

    -- 2. Если не обработано, попробовать root
    if not handled and self.root then
        handled = self.root:dispatch("touchPressed", id, x, y, dx, dy, pressure)
        print("Root handled:", handled)
    end

    -- 3. Дополнительные обработчики
    for _, handler in ipairs(self.touchHandlers) do
        if handler.onTouchPressed then
            handler:onTouchPressed(id, x, y, dx, dy, pressure)
        end
    end

    return handled
end

function UIManager:handleTouchReleased(id, x, y, dx, dy, pressure)
    x = x * (self.width / love.graphics.getWidth())
    y = y * (self.height / love.graphics.getHeight())

    local handled = false
    
    if self.layeredManager then
        handled = self.layeredManager:touchReleased(id, x, y, dx, dy, pressure)
    end

    if not handled and self.root then
        handled = self.root:dispatch("touchReleased", id, x, y, dx, dy, pressure)
    end

    for _, handler in ipairs(self.touchHandlers) do
        if handler.onTouchReleased then
            handler:onTouchReleased(id, x, y, dx, dy, pressure)
        end
    end

    return handled
end


function UIManager:handleTouchMoved(id, x, y, dx, dy, pressure)
    x = x * (self.width / love.graphics.getWidth())
    y = y * (self.height / love.graphics.getHeight())

    local handled = false
    
    if self.layeredManager then
        handled = self.layeredManager:touchMoved(id, x, y, dx, dy, pressure) -- Используем алиас
    end


    if not handled and self.root then
        handled = self.root:dispatch("touchMoved", id, x, y, dx, dy, pressure)
    end

    for _, handler in ipairs(self.touchHandlers) do
        if handler.onTouchMoved then
            handler:onTouchMoved(id, x, y, dx, dy, pressure)
        end
    end

    return handled
end

function UIManager:handleKeyPressed(key, scancode, isrepeat)
    local handled = false
    
    if self.layeredManager then
        handled = self.layeredManager:keyPressed(key, scancode, isrepeat)
    end

    if not handled and self.root then
        handled = self.root:dispatch("keyPressed", key, scancode, isrepeat)
    end

    for _, handler in ipairs(self.keyHandlers) do
        if handler.onKeyPressed then
            handler:onKeyPressed(key, scancode, isrepeat)
        end
    end

    return handled
end

function UIManager:update(dt)
    if self.layeredManager then self.layeredManager:update(dt) end
    if self.root then self.root:update(dt) end
end

function UIManager:draw()
    -- Отладочная информация
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("line", self.lastTouch.x, self.lastTouch.y, 20)
    
    -- Отрисовка UI
    if self.layeredManager then self.layeredManager:draw() end
    if self.root then self.root:draw() end
end

function UIManager:resize(w, h)
    self.width, self.height = w, h
    if self.root then
        self.root.width, self.root.height = w, h
    end
    print("Resized to:", w, h)
end

-- Вспомогательные методы для отладки
function UIManager:printHierarchy()
    print("=== UI Hierarchy ===")
    local function printElement(el, indent)
        indent = indent or 0
        local str = string.rep("  ", indent) .. tostring(el)
        if el.label then str = str .. " (" .. el.label .. ")" end
        str = str .. string.format(" [%d,%d %dx%d]", el.x, el.y, el.width, el.height)
        print(str)
        
        if el.children then
            for _, child in ipairs(el.children) do
                printElement(child, indent + 1)
            end
        end
    end
    
    if self.root then printElement(self.root) end
end

return UIManager