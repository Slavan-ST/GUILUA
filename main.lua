local UIManager = require("src.ui.core.UIManager")
local UIButton = require("src.ui.elements.UIButton")
local Fonts = require("src.ui.fonts.init")
local DebugConsole = require("src.ui.utils.DebugConsole")
local ScrollView = require("src.ui.elements.ScrollView")
local Label = require("src.ui.elements.Label")

local ui = UIManager:new()


function love.load()
    Fonts.load()
    love.graphics.setFont(Fonts.default)
    
    
    
    -- Создаем ScrollView с явным указанием options
    local scrollView = ScrollView:new(
        50, 
        50, 
        love.graphics.getWidth() - 100, 
        love.graphics.getHeight() - 100, 
        {
            zIndex = 1,
            scrollBarSize = 10,
            scrollBarColor = {0.5, 0.05, 0.5, 0.1}
        }
    )
    
    scrollView:setContentSize(love.graphics.getWidth() - 100, 2000)
    
    local Element = require("src.ui.core.Element")
        -- Добавьте это в love.load() после создания scrollView
    local testRect = Element:new(10, 10, 100, 50, {backgroundColor = {0,0.5,1,1}})
    scrollView:addChild(testRect)
    
    -- Добавляем тестовые элементы
    
    for i = 1, 50 do

        
        -- Создаем Label для текста
        local label = Label:new(
            10, 15,                      -- x, y (относительно item)
            "Элемент "..i,               -- текст
            {1,1,1,1},                -- цвет (белый)
            {                            -- опции
                zIndex = 1000,
                align = "left",
                wrap = true,
                
            }
        )
        

        
        -- Добавляем элемент в scrollView
        scrollView:addChild(label)
    end
    
    ui:addElement(scrollView)
    

    
    
    
    

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