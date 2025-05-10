local UIManager = require("src.ui.core.UIManager")
local UIButton = require("src.ui.elements.Button")
local Fonts = require("src.ui.fonts.init")
local DebugConsole = require("src.ui.utils.DebugConsole")
local ScrollView = require("src.ui.elements.ScrollView")
local UIInputField = require("src.ui.elements.UIInputField")
local Label = require("src.ui.elements.Label")
local ThemeManager = require("src.ui.core.ThemeManager")
local Element = require("src.ui.core.Element")

local ui = UIManager.getInstance()

function love.load()
    -- Загрузка шрифтов
    Fonts.load()
    love.graphics.setFont(Fonts.default)

    -- Установка темы
    ThemeManager.setTheme("dark")

    -- Создание ScrollView
    local scrollView = ScrollView:new({
        x = 100,
        y = 100,
        width = love.graphics.getWidth() - 200,
        height =love.graphics.getHeight() - 200,
        
            zIndex = 1,
            scrollBarSize = 10,
            
        })
    for i = 1, 50 do
        local label = Label:new(
          {
            x = 10, y = 15,
            text = "Элемент " .. i,
            
            
                zIndex = 1000,
                align = "left",
                wrap = true
            }
        )
        scrollView:addChild(label)
    end

    ui:addElement(scrollView)

    -- Кнопка открытия консоли
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

    -- Тестовая кнопка (показ/скрытие scrollView)
    local testBtn = UIButton({
        x = love.graphics.getWidth() - 210,
        y = 50,
        width = 200,
        height = 40,
        text = "scrollView",
        
            onClick = function()
                scrollView.visible = not scrollView.visible
                scrollView.enabled = not scrollView.enabled
            end,
            zIndex = 1
        })

    ui:addElement(consoleBtn)
    ui:addElement(testBtn)
    
    local input = UIInputField:new({
    x = 100,
    y = 150,
    width = 300,
    height = 40,
    placeholder = "Введите имя...",
    onTextChanged = function(field, text)
        DebugConsole.log("Текст изменён:", text)
    end,
    onEnterPressed = function(field, text)
        DebugConsole.log("Нажат Enter:", text)
    end
})
ui:addElement(input)

    DebugConsole.log("UI инициализирован через UIManager")
end

function love.update(dt)
    ui:update(dt)
    if DebugConsole.update then
        DebugConsole.update(dt)
    end
end

function love.draw()
    --love.graphics.clear(0.1, 0.1, 0.15)
    ui:draw()
    DebugConsole.draw()
end

-- TOUCH обработчики событий
function love.touchpressed(id, x, y, dx, dy, pressure)
    ui:handleEvent({
        type = "touchpressed",
        id = id,
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        pressure = pressure
    })
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    ui:handleEvent({
        type = "touchreleased",
        id = id,
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        pressure = pressure
    })
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    ui:handleEvent({
        type = "touchmoved",
        id = id,
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        pressure = pressure
    })
  
  function love.textinput(text)
    ui:handleEvent({ type = "textinput", text = text })
end

function love.keypressed(key, scancode, isrepeat)
    ui:handleEvent({ type = "keypressed", key = key, scancode = scancode, isrepeat = isrepeat })
end
end