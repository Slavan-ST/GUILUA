local UIManager = require("src.ui.core.UIManager")
local UIButton = require("src.ui.elements.UIButton")
local Fonts = require("src.ui.fonts.init")
local DebugConsole = require("src.ui.utils.DebugConsole")

-- Глобальные отладочные переменные
local debugTouchVisible = true
local debugUIHierarchy = false

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
    
    logUIHierarchy(ui) -- Вывод иерархии UI
end

function createTestUI(ui)
    -- Основная тестовая кнопка
    local testBtn = UIButton(50, 400, 200, 60, "ТЕСТ", {
        backgroundColor = {0.2, 0.7, 0.2, 1},
        textColor = {1, 1, 1, 1},
        onClick = function()
            DebugConsole.log("Тестовая кнопка нажата!")
            testBtn.backgroundColor = {0.8, 0.2, 0.2, 1} -- Меняем цвет при нажатии
        end
    })
    ui.root:addChild(testBtn)
    
    -- Кнопка управления консолью
    local consoleBtn = UIButton(love.graphics.getWidth()-210, 10, 200, 40, "КОНСОЛЬ", {
        backgroundColor = {0.3, 0.3, 0.8, 1},
        textColor = {1, 1, 1, 1},
        onClick = function()
            DebugConsole.toggle()
            DebugConsole.log("Консоль " .. (DebugConsole.visible and "показана" or "скрыта"))
        end
    })
    ui.root:addChild(consoleBtn)
    
    -- Кнопка отладочной информации
    local debugBtn = UIButton(50, 300, 200, 60, "ОТЛАДКА", {
        onClick = function()
            debugTouchVisible = not debugTouchVisible
            debugUIHierarchy = not debugUIHierarchy
            DebugConsole.log("Режим отладки: " .. (debugTouchVisible and "ВКЛ" or "ВЫКЛ"))
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
    
    -- Отрисовка консоли
    DebugConsole.draw()
    
    -- Отладочная информация
    if debugTouchVisible then
        drawDebugInfo()
    end
end

function drawDebugInfo()
    local ui = UIManager.getInstance()
    -- Отображение последнего касания
    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.circle("fill", ui.lastTouch.x, ui.lastTouch.y, 15)
    
    -- Отладочный текст
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, love.graphics.getHeight() - 30)
    love.graphics.print("Последнее касание: " .. ui.lastTouch.x .. ", " .. ui.lastTouch.y, 10, love.graphics.getHeight() - 60)
end

function logUIHierarchy(ui)
    DebugConsole.log("=== Иерархия UI ===")
    local function logElement(el, level)
        local indent = string.rep("  ", level)
        local info = indent .. tostring(el) .. " (" .. (el.label or "no label") .. ")"
        info = info .. string.format(" [%d,%d %dx%d]", el.x, el.y, el.width, el.height)
        DebugConsole.log(info)
        
        if el.children then
            for _, child in ipairs(el.children) do
                logElement(child, level + 1)
            end
        end
    end
    
    if ui.root then
        logElement(ui.root, 0)
    else
        DebugConsole.log("Корневой элемент не создан!")
    end
end

-- Обработчики ввода с улучшенной отладкой
function love.touchpressed(id, x, y)
    DebugConsole.log("касание")
    
end

function love.touchreleased(id, x, y)
    print("")
end

function love.touchmoved(id, x, y)
    -- Перемещение консоли двумя пальцами
    if #love.touch.getTouches() == 2 then
        DebugConsole.x = x - DebugConsole.width/2
        DebugConsole.y = y - DebugConsole.height/2
    end
    
end

function love.keypressed(key)
    -- Горячие клавиши для отладки
    if key == "d" then
        debugTouchVisible = not debugTouchVisible
    elseif key == "h" then
        logUIHierarchy(UIManager.getInstance())
    end
end