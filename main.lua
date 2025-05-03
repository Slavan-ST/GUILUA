local UIManager = require("src.ui.core.UIManager")
local UIButton = require("src.ui.elements.UIButton")
local Fonts = require("src.ui.fonts.init")
local DebugConsole = require("src.ui.utils.DebugConsole")

local ui = UIManager:new()

function love.load()
    Fonts.load()
    love.graphics.setFont(Fonts.default)

    -- Кнопка консоли
    local consoleBtn = UIButton(love.graphics.getWidth() - 210, 10, 200, 40, "КОНСОЛЬ", {
        backgroundColor = {0.3, 0.3, 0.8, 1},
        textColor = {1, 1, 1, 1},
        onClick = function()
            DebugConsole.toggle()
        end
    })

    -- Тестовая кнопка
    local testBtn = UIButton(50, 400, 200, 60, "ТЕСТ", {
        backgroundColor = {0.2, 0.7, 0.2, 1},
        textColor = {1, 1, 1, 1},
        onClick = function()
            DebugConsole.log("Нажата тестовая кнопка")
            testBtn:setBackgroundColor(0.8, 0.2, 0.2, 1)
        end,
        zIndex = 1
    })

    ui:addElement(consoleBtn)
    ui:addElement(testBtn)

    DebugConsole.log("UI инициализирован через UIManager")
end

function love.update(dt)
    ui:update(dt)
    if DebugConsole.update then DebugConsole.update(dt) end
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.15)
    ui:draw()
    DebugConsole.draw()
end

-- TOUCH (Android)
function love.touchpressed(id, x, y, dx, dy, pressure)
    ui:handleEvent({ type = "touchpressed", id = id, x = x, y = y, dx = dx, dy = dy, pressure = pressure })
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    ui:handleEvent({ type = "touchreleased", id = id, x = x, y = y, dx = dx, dy = dy, pressure = pressure })
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    ui:handleEvent({ type = "touchmoved", id = id, x = x, y = y, dx = dx, dy = dy, pressure = pressure })
end