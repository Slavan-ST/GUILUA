-- main.lua

local UIManager = require("src.ui.core.UIManager")
local UIButton = require("src.ui.elements.Button")
local Fonts = require("src.ui.fonts.init")
local DebugConsole = require("src.ui.utils.DebugConsole")
local ScrollView = require("src.ui.elements.ScrollView")
local UIInputField = require("src.ui.elements.UIInputField")
local Label = require("src.ui.elements.Label")
local ThemeManager = require("src.ui.core.ThemeManager")

local ui = UIManager.getInstance()

-- === Безопасный вызов с логированием ошибок ===
local function safeCall(fn)
    return function(...)
        local status, err = pcall(fn, ...)
        if not status then
            DebugConsole.log("Ошибка в главном цикле: " .. tostring(err))
        end
    end
end

function love.load()
    safeCall(real_load)()
end

function real_load()
    -- Загрузка шрифтов
    Fonts.load()

    -- Установка шрифта по умолчанию
    if Fonts.default then
        love.graphics.setFont(Fonts.default)
    else
        DebugConsole.log("Шрифт не загружен!")
    end

    -- Установка темы
    ThemeManager.setTheme("dark")

    -- === Создание ScrollView ===
    local scrollView = ScrollView:new({
        x = 100,
        y = 100,
        width = love.graphics.getWidth() - 200,
        height = love.graphics.getHeight() - 200,
        scrollBarSize = 10,
        zIndex = 1
    })

    for i = 1, 50 do
        local label = Label:new({
            text = "Элемент " .. i,
            align = "left",
            wrap = true,
            padding = 8
        })
        scrollView:addChild(label)
    end

    ui:addElement(scrollView)

    -- === Кнопка открытия консоли ===
    local consoleBtn = UIButton({
        x = love.graphics.getWidth() - 210,
        y = 10,
        width = 200,
        height = 40,
        text = "КОНСОЛЬ",
        onClick = function()
            DebugConsole.toggle()
        end
    })

    -- === Тестовая кнопка (показ/скрытие ScrollView) ===
    local testBtn = UIButton({
        x = love.graphics.getWidth() - 210,
        y = 50,
        width = 200,
        height = 40,
        text = "scrollView",
        zIndex = 1,
        onClick = function()
            scrollView.visible = not scrollView.visible
            scrollView.enabled = not scrollView.enabled
        end
    })

    ui:addElement(consoleBtn)
    ui:addElement(testBtn)

    -- === Поле ввода текста ===
    local input = UIInputField:new({
        x = 100,
        y = 150,
        width = 300,
        height = 40,
        placeholder = "Введите имя...",
        onTextChanged = function(field, text)
            --DebugConsole.log("Текст изменён:", text)
        end,
        onEnterPressed = function(field, text)
            DebugConsole.log("Нажат Enter:", text)
        end
    })

    ui:addElement(input)

    DebugConsole.log("UI инициализирован через UIManager")
    DebugConsole.log("save in:", love.filesystem.getSaveDirectory())
end

function love.update(dt)
    safeCall(real_update)(dt)
end

function real_update(dt)
    local ui = UIManager.getInstance()
    ui:update(dt)
    if DebugConsole.update then
        DebugConsole.update(dt)
    end
end

function love.draw()
    safeCall(real_draw)()
end

function real_draw()
    love.graphics.clear(0.1, 0.1, 0.15)
    local ui = UIManager.getInstance()
    ui:draw()
    DebugConsole.draw()
end

-- === Обработчики событий ===
function love.touchpressed(id, x, y, dx, dy, pressure)
    safeCall(function()
        local ui = UIManager.getInstance()
        ui:handleEvent({
            type = "touchpressed",
            id = id,
            x = x,
            y = y,
            dx = dx,
            dy = dy,
            pressure = pressure
        })
    end)()
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    safeCall(function()
        local ui = UIManager.getInstance()
        ui:handleEvent({
            type = "touchreleased",
            id = id,
            x = x,
            y = y,
            dx = dx,
            dy = dy,
            pressure = pressure
        })
    end)()
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    safeCall(function()
        local ui = UIManager.getInstance()
        ui:handleEvent({
            type = "touchmoved",
            id = id,
            x = x,
            y = y,
            dx = dx,
            dy = dy,
            pressure = pressure
        })
    end)()
end

function love.textinput(text)
    safeCall(function()
        local ui = UIManager.getInstance()
        ui:handleEvent({ type = "textinput", text = text })
    end)()
end

function love.keypressed(key, scancode, isrepeat)
    safeCall(function()
        local ui = UIManager.getInstance()
        ui:handleEvent({ type = "keypressed", key = key, scancode = scancode, isrepeat = isrepeat })
    end)()
end