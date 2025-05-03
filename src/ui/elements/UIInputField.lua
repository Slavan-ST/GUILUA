local class = require("lib.middleclass")
local Element = require("src.ui.core.Element")

local UIInputField = class("UIInputField", Element)

function UIInputField:initialize(x, y, width, height, options)
    Element.initialize(self, x, y, width, height)
    
    options = options or {}
    
    -- Свойства текста
    self.text = options.text or ""
    self.placeholder = options.placeholder or ""
    self.font = options.font or love.graphics.getFont()
    self.textColor = options.textColor or {1, 1, 1, 1}
    self.placeholderColor = options.placeholderColor or {0.7, 0.7, 0.7, 1}
    
    -- Внешний вид
    self.backgroundColor = options.backgroundColor or {0.2, 0.2, 0.2, 1}
    self.borderColor = options.borderColor or {0.5, 0.5, 0.5, 1}
    self.focusBorderColor = options.focusBorderColor or {0.7, 0.7, 1, 1}
    self.borderWidth = options.borderWidth or 1
    self.borderRadius = options.borderRadius or 2
    self.padding = options.padding or 5
    
    -- Состояние
    self.hasFocus = false
    self.cursorPos = #self.text
    self.cursorVisible = true
    self.cursorBlinkTime = 0.5
    self.cursorTimer = 0
    self.passwordMode = options.passwordMode or false
    self.maxLength = options.maxLength or -1
    
    -- Фильтрация ввода
    self.inputFilter = options.inputFilter -- функция для фильтрации символов
    
    -- Callback
    self.onTextChanged = options.onTextChanged
    self.onEnterPressed = options.onEnterPressed
end

function UIInputField:getText()
    return self.text
end

function UIInputField:setText(text)
    self.text = text or ""
    self.cursorPos = math.min(self.cursorPos, #self.text)
    
    if self.onTextChanged then
        self.onTextChanged(self, self.text)
    end
end

function UIInputField:setPlaceholder(placeholder)
    self.placeholder = placeholder or ""
end

function UIInputField:onFocus()
    self.hasFocus = true
    self.cursorTimer = 0
    self.cursorVisible = true
end

function UIInputField:onBlur()
    self.hasFocus = false
end

-- Обработка текстового ввода
function UIInputField:textinput(text)
    if not self.hasFocus then return end
    
    -- Применяем фильтр ввода при необходимости
    if self.inputFilter and not self.inputFilter(text) then
        return
    end
    
    -- Проверяем макс. длину
    if self.maxLength > 0 and #self.text >= self.maxLength then
        return
    end
    
    -- Добавляем текст в текущую позицию курсора
    local newText = string.sub(self.text, 1, self.cursorPos) .. text .. string.sub(self.text, self.cursorPos + 1)
    self:setText(newText)
    self.cursorPos = self.cursorPos + #text
end

-- Обработка нажатия клавиш
function UIInputField:keypressed(key, scancode, isrepeat)
    if not self.hasFocus then return end
    
    if key == "backspace" then
        if self.cursorPos > 0 then
            local newText = string.sub(self.text, 1, self.cursorPos - 1) .. string.sub(self.text, self.cursorPos + 1)
            self:setText(newText)
            self.cursorPos = self.cursorPos - 1
        end
    elseif key == "delete" then
        if self.cursorPos < #self.text then
            local newText = string.sub(self.text, 1, self.cursorPos) .. string.sub(self.text, self.cursorPos + 2)
            self:setText(newText)
        end
    elseif key == "left" then
        self.cursorPos = math.max(0, self.cursorPos - 1)
    elseif key == "right" then
        self.cursorPos = math.min(#self.text, self.cursorPos + 1)
    elseif key == "home" then
        self.cursorPos = 0
    elseif key == "end" then
        self.cursorPos = #self.text
    elseif key == "return" or key == "kpenter" then
        if self.onEnterPressed then
            self.onEnterPressed(self, self.text)
        end
    end
    
    -- Сбрасываем таймер моргания курсора
    self.cursorTimer = 0
    self.cursorVisible = true
end

function UIInputField:onTouchPressed(id, x, y, dx, dy, pressure)
    if self:isInside(x, y) then
        self:focus()
        
        -- Установка позиции курсора по клику
        local clickX = x - self.x - self.padding
        local currentPos = 0
        local bestDist = math.huge
        
        for i = 0, #self.text do
            local textPart = self.passwordMode and string.rep("*", i) or string.sub(self.text, 1, i)
            local width = self.font:getWidth(textPart)
            local dist = math.abs(width - clickX)
            
            if dist < bestDist then
                bestDist = dist
                currentPos = i
            end
        end
        
        self.cursorPos = currentPos
        return true
    else
        if self.hasFocus then
            self:blur()
        end
        return false
    end
end

function UIInputField:update(dt)
    Element.update(self, dt)
    
    -- Обновление курсора
    if self.hasFocus then
        self.cursorTimer = self.cursorTimer + dt
        if self.cursorTimer >= self.cursorBlinkTime then
            self.cursorTimer = self.cursorTimer - self.cursorBlinkTime
            self.cursorVisible = not self.cursorVisible
        end
    end
end

function UIInputField:draw()
    if not self.visible then return end
    
    -- Сохраняем текущие настройки графики
    local r, g, b, a = love.graphics.getColor()
    local currentFont = love.graphics.getFont()
    
    -- Рисуем фон
    love.graphics.setColor(unpack(self.backgroundColor))
    
    if self.borderRadius > 0 and love.graphics.newCanvas then
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.borderRadius, self.borderRadius)
    else
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end
    
    -- Рисуем границу
    local borderColor = self.hasFocus and self.focusBorderColor or self.borderColor
    love.graphics.setColor(unpack(borderColor))
    
    if self.borderRadius > 0 and love.graphics.newCanvas then
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height, self.borderRadius, self.borderRadius)
    else
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    end
    
    -- Устанавливаем шрифт
    love.graphics.setFont(self.font)
    
    -- Определяем, какой текст отображать
    local displayText = self.text
    if self.passwordMode then
        displayText = string.rep("*", #self.text)
    end
    
    -- Вычисляем область отображения текста
    local textX = self.x + self.padding
    local textY = self.y + (self.height - self.font:getHeight()) / 2
    
    -- Рисуем текст или плейсхолдер
    if #self.text > 0 then
        love.graphics.setColor(unpack(self.textColor))
        love.graphics.print(displayText, textX, textY)
    else
        love.graphics.setColor(unpack(self.placeholderColor))
        love.graphics.print(self.placeholder, textX, textY)
    end
    
    -- Рисуем курсор, если поле в фокусе
    if self.hasFocus and self.cursorVisible then
        local cursorX = textX
        if #self.text > 0 and self.cursorPos > 0 then
            local textBeforeCursor = self.passwordMode and string.rep("*", self.cursorPos) or string.sub(self.text, 1, self.cursorPos)
            cursorX = textX + self.font:getWidth(textBeforeCursor)
        end
        
        love.graphics.setColor(unpack(self.textColor))
        love.graphics.rectangle("fill", cursorX, textY, 1, self.font:getHeight())
    end
    
    -- Восстанавливаем настройки графики
    love.graphics.setColor(r, g, b, a)
    love.graphics.setFont(currentFont)
    
    -- Рисуем дочерние элементы
    for _, child in ipairs(self.children) do
        if child.draw then
            child:draw()
        end
    end
end

function UIInputField:focus()
    Element.focus(self)
end

function UIInputField:blur()
    if self.parent and self.parent.clearFocus then
        self.parent:clearFocus()
    end
end

return UIInputField