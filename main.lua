-- Импортируем необходимые модули
local LayeredManager = require("src.ui.core.LayeredManager")  -- Путь к вашему менеджеру слоёв
local Element = require("src.ui.core.Element")  -- Путь к базовому элементу

-- Инициализация LayeredManager
local manager = LayeredManager()

-- Пример кнопки, которая будет реагировать на тач-события
local Button = Element:subclass("Button")

function Button:initialize(x, y, width, height, label)
    Element.initialize(self, x, y, width, height)
    self.label = label or "Button"
end

function Button:onTouchPressed(id, x, y, dx, dy, pressure)
    print("Button touched!")
    -- Здесь можно добавить логику, например, переход на другой экран
end

-- Создаём кнопку
local button = Button(100, 100, 200, 50, "Click me!")

-- Добавляем кнопку в LayeredManager на основной слой
manager:addElementToLayer(button, "default")

-- Функции обработки тач-событий

function love.touchpressed(id, x, y, dx, dy, pressure)
    manager:handleTouchPressed(id, x, y, dx, dy, pressure)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    manager:handleTouchReleased(id, x, y, dx, dy, pressure)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    manager:handleTouchMoved(id, x, y, dx, dy, pressure)
end

-- Основные функции love2d

function love.load()
    -- Инициализация игры, настройка и т.д.
end

function love.update(dt)
    -- Логика обновления
end

function love.draw()
    -- Отображение всех элементов на экране
    manager:draw()  -- Предположим, у вас есть метод draw в LayeredManager для отрисовки элементов
end