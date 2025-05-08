local UIManager = require("src.ui.core.UIManager")
local UIButton = require("src.ui.elements.Button")
local Fonts = require("src.ui.fonts.init")
local DebugConsole = require("src.ui.utils.DebugConsole")
local ScrollView = require("src.ui.elements.ScrollView")
local Label = require("src.ui.elements.Label")
local ThemeManager = require("src.ui.core.ThemeManager")


local ui = require("src.ui.core.UIManager").getInstance()


function love.load()
    Fonts.load()
    love.graphics.setFont(Fonts.default)
    
    ThemeManager.setTheme("dark")
    
    -- Создаем ScrollView с явным указанием options
    local scrollView = ScrollView:new(
        100, 
        100, 
        love.graphics.getWidth() - 200, 
        love.graphics.getHeight() - 200, 
        {
            zIndex = 1,
            scrollBarSize = 10,
            scrollBarColor = {0.1, 0.5, 0.2, 0.1}
        }
    )
    

    
    local Element = require("src.ui.core.Element")
        -- Добавьте это в love.load() после создания scrollView
    
    
    
    
    
    
    
    
    
    

    

    
    
    
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
    

        -- Тестовый drop-таргет
    local dropZone = Element:new(10, 100, 200, 200, { backgroundColor = {0.3, 0.3, 0.3, 1},  
      drop = function(event) DebugConsole.log("drop в позиции:", event.x, event.y) end,
    })
    
    
    ui:addElement(dropZone)
    
    local draggableBtn = UIButton(love.graphics.getWidth() - 210, 80, 200, 50, "Перетащи меня", {
        onClick = function() DebugConsole.log("Клик!") end,
        dragstart = function(event) end,
        drag = function(event) end,
        dtagend = function(event)  end
    })
    ui:addElement(draggableBtn)
    
  
    
    
    
    

    -- Кнопка консоли
    local consoleBtn = UIButton(love.graphics.getWidth() - 210, 10, 200, 40, "КОНСОЛЬ", {
        
        onClick = function()
            DebugConsole.toggle()
        end
    })

    -- Тестовая кнопка
    local testBtn = UIButton(love.graphics.getWidth() - 210, 50, 200, 40, "scrollView", {
        
        onClick = function()
            scrollView.visible = not scrollView.visible
            scrollView.enabled = not scrollView.enabled
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