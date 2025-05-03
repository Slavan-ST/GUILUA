local UIManager = require("src.ui.core.UIManager")
local UIButton = require("src.ui.elements.UIButton")
local Fonts = require("src.ui.fonts.init")
local DebugConsole = require("src.ui.utils.DebugConsole")

function love.load()
    -- Инициализация систем
    Fonts.load()
    love.graphics.setFont(Fonts.default)
    
    -- Настройка UIManager
    local ui = UIManager.getInstance()
    ui:init(love.graphics.getWidth(), love.graphics.getHeight())

    -- Создание тестовых кнопок
    createTestUI(ui)
    
    -- Отладочная информация
    DebugConsole.log("Приложение инициализировано")
    DebugConsole.logUIHierarchy()
end

function createTestUI(ui)
    -- Основная тестовая кнопка
    local testBtn = UIButton(50, 400, 200, 60, "ТЕСТ", {
        backgroundColor = {0.2, 0.7, 0.2, 1},
        textColor = {1, 1, 1, 1},
        onClick = function()
            DebugConsole.log("Тестовая кнопка нажата!")
            testBtn.backgroundColor = {0.8, 0.2, 0.2, 1}
        end
    })
    ui.root:addChild(testBtn)
    
    -- Кнопка управления консолью
    local consoleBtn = UIButton(love.graphics.getWidth()-210, 10, 200, 40, "КОНСОЛЬ", {
        backgroundColor = {0.3, 0.3, 0.8, 1},
        textColor = {1, 1, 1, 1},
        onClick = function()
            DebugConsole.toggle()
        end
    })
    ui.root:addChild(consoleBtn)
    
    -- Кнопка отладочной информации
    local debugBtn = UIButton(50, 300, 200, 60, "ОТЛАДКА", {
        onClick = function()
            DebugConsole.toggleDebug()
        end
    })
    ui.root:addChild(debugBtn)
end

function love.update(dt)
    UIManager.getInstance():update(dt)
end

function love.draw()
    -- Очистка экрана
    love.graphics.clear(0.1, 0.1, 0.15)
    
    -- Отрисовка UI
    UIManager.getInstance():draw()
    
    -- Отрисовка консоли и отладочной информации
    DebugConsole.draw()
end

-- Обработчики ввода
function love.touchpressed(id, x, y)
    
end

function love.touchreleased(id, x, y)
    
end

function love.touchmoved(id, x, y)
    -- Перемещение консоли двумя пальцами
    if #love.touch.getTouches() == 2 then
        DebugConsole.move(x - DebugConsole.width/2, y - DebugConsole.height/2)
    end
end

function love.keypressed(key)
    -- Передача управления в консоль
    DebugConsole.handleInput(key)
    
    -- Дополнительные горячие клавиши
    if key == "f1" then
        DebugConsole.logUIHierarchy()
    end
end