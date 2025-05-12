-- /src/ui/core/mixins/TextEditable.lua
local UIManager = require("src.ui.core.UIManager")
-- В начале файла:
local utf8 = require("src.ui.utils.UTF8Utils") -- загружаем наш модуль

local TextEditable = {}

function TextEditable:initialize(options)
    -- === Свойства ввода текста ===
    self.text = options.text or ""
    self.placeholder = options.placeholder or ""
    self.passwordMode = options.passwordMode or false
    self.maxLength = options.maxLength or -1

    -- === Цвета и стиль ===
    self.textColor = options.textColor or {1, 1, 1, 1}
    self.placeholderColor = options.placeholderColor or {0.7, 0.7, 0.7, 1}

    -- === Курсор ===
    self.hasFocus = false
    self.cursorPos = utf8.len(self.text) -- Используем utf8
    self.cursorVisible = true
    self.cursorBlinkTime = 0.5
    self.cursorTimer = 0

    -- === Callbacks ===
    self.onTextChanged = options.onTextChanged
    self.onEnterPressed = options.onEnterPressed

    -- === Фильтры ===
    self.inputFilter = options.inputFilter

    -- Подписываемся на нужные события через InteractiveEvents
    self:addEventListener("textinput", function(text) return self:textinput(text) end)
    self:addEventListener("keypressed", function(e) return self:keypressed(e.key) end)
    self:addEventListener("focusgained", function() self:onFocus() end)
    self:addEventListener("focuslost", function() self:onBlur() end)

    -- Регистрируем методы для базового поведения (если ещё не добавлены)
    if not self.onTouchPressed then
        self:addEventListener("touchpressed", function(e) return self:onTouchPressed(e) end)
    end
end

-- === Обновление состояния при фокусе ===
function TextEditable:onFocus()
    self.hasFocus = true
    self.cursorTimer = 0
    self.cursorVisible = true
end

function TextEditable:onBlur()
    self.hasFocus = false
end

-- === Обработка текстового ввода ===
function TextEditable:textinput(event)
    if not self.hasFocus then return end

    local text
    if type(event) == "string" then
        text = event
    elseif type(event) == "table" and type(event.text) == "string" then
        text = event.text
    else
        return
    end

    if not text or #text == 0 then
        return
    end

    if self.inputFilter and not self.inputFilter(text) then
        return
    end

    if self.maxLength > 0 and utf8.len(self.text) + utf8.len(text) > self.maxLength then
        return
    end

    local before = utf8.sub(self.text, 1, self.cursorPos)
    local after = utf8.sub(self.text, self.cursorPos + 1)
    local newText = before .. text .. after

    self:setText(newText)
    self.cursorPos = self.cursorPos + utf8.len(text)
end

-- === Обработка клавиш (backspace, delete, стрелки и т.д.) ===
function TextEditable:keypressed(key)
    if not self.hasFocus then return end

    if key == "backspace" then
        if self.cursorPos > 0 then
            local before = utf8.sub(self.text, 1, self.cursorPos - 1)
            local after = utf8.sub(self.text, self.cursorPos + 1)
            self:setText(before .. after)
            self.cursorPos = math.max(0, self.cursorPos - 1)
        end
    elseif key == "delete" then
        if self.cursorPos < utf8.len(self.text) then
            local before = utf8.sub(self.text, 1, self.cursorPos)
            local after = utf8.sub(self.text, self.cursorPos + 2)
            self:setText(before .. after)
        end
    elseif key == "left" then
        self.cursorPos = math.max(0, self.cursorPos - 1)
    elseif key == "right" then
        self.cursorPos = math.min(utf8.len(self.text), self.cursorPos + 1)
    elseif key == "home" then
        self.cursorPos = 0
    elseif key == "end" then
        self.cursorPos = utf8.len(self.text)
    elseif key == "return" or key == "kpenter" then
        if self.onEnterPressed then
            self.onEnterPressed(self, self.text)
        end
        return
    else
        return
    end

    self.cursorTimer = 0
    self.cursorVisible = true
end

-- === Нажатие по полю — запрос фокуса ===
function TextEditable:onTouchPressed(event)
    if not self:isInside(event.x, event.y) then return false end

    self:requestFocus()
    love.keyboard.setTextInput(true)

    -- Вычисляем позицию курсора по координатам X
    local font = love.graphics.getFont()
    local paddingLeft = self:getPaddingLeft()
    local textTop = (self.height - font:getHeight()) / 2
    local textBottom = textTop + font:getHeight()

    -- Проверяем, находится ли Y внутри области текста
    if  event.y >= self.y + textTop and 
        event.y <= self.y + textBottom then
        require("src.ui.utils.DebugConsole").log("displayText", utf8.len(self.text))
        local relativeX = event.x - paddingLeft
        self.cursorPos = self:getCursorPositionFromX(relativeX)
    else
        self.cursorPos = 0
    end

    self.cursorTimer = 0
    self.cursorVisible = true

    return true
end

-- === Установка нового текста ===
function TextEditable:setText(text)
    self.text = text or ""
    self.cursorPos = math.min(self.cursorPos, utf8.len(self.text))
    if self.onTextChanged then
        self.onTextChanged(self, self.text)
    end
    return self
end

-- === Получение текущего текста ===
function TextEditable:getText()
    return self.text
end

-- === Обновление курсора ===
function TextEditable:update(dt)
    if self.hasFocus then
        self.cursorTimer = self.cursorTimer + dt
        if self.cursorTimer >= self.cursorBlinkTime then
            self.cursorTimer = self.cursorTimer - self.cursorBlinkTime
            self.cursorVisible = not self.cursorVisible
        end
    end
end

-- === Отрисовка текста и курсора ===
function TextEditable:drawTextContent()
    local font = love.graphics.getFont()
    local displayText = self.text
    if self.passwordMode then
        displayText = string.rep("*", utf8.len(self.text)) -- Используем utf8.len
    end

    local textColor = self.textColor
    local x = self:getPaddingLeft()
    local y = (self.height - font:getHeight()) / 2

    love.graphics.setFont(font)
    love.graphics.setColor(textColor)

    if utf8.len(self.text) == 0 and self.placeholder and self.placeholder ~= "" then
        love.graphics.setColor(self.placeholderColor)
        love.graphics.print(self.placeholder, x, y)
    else
        love.graphics.setColor(textColor)
        love.graphics.print(displayText, x, y)
    end

    -- Рисуем курсор
    if self.hasFocus and self.cursorVisible then
        local cursorX = x
        if utf8.len(displayText) > 0 and self.cursorPos > 0 then
            local part = utf8.sub(displayText, 1, self.cursorPos)
            cursorX = x + font:getWidth(part)
        end
        love.graphics.setColor(textColor)
        love.graphics.rectangle("fill", cursorX, y, 1, font:getHeight())
    end
end

-- === Запрос фокуса ===
function TextEditable:requestFocus()
    local ui = UIManager.getInstance()
    ui:setFocus(self)
    return true
end

function TextEditable:getCursorPositionFromX(clickX)
    clickX = clickX - self.x
    local font = love.graphics.getFont()
    local displayText = self.text
    if self.passwordMode then
        displayText = string.rep("*", utf8.len(self.text))
    end

    local paddingLeft = self:getPaddingLeft()
    local x = paddingLeft
    local cursorPos = 0

    
    -- Если текста нет, то всегда позиция 0
    if utf8.len(displayText) == 0 then
        return 0
    end

    -- Перебираем каждый символ и сравниваем с позицией клика
    for i = 1, utf8.len(displayText) do
        local char = utf8.sub(displayText, i, i)
        local charWidth = font:getWidth(char)

        -- Проверяем, попадает ли клик между предыдущим и текущим символом
        local midPoint = x + charWidth / 2
        if clickX < midPoint and  clickX > (x - charWidth / 2) then
            return cursorPos
        end

        x = x + charWidth
        cursorPos = i
    end

    -- Если клик правее всех символов — ставим в конец
    return cursorPos
end

return TextEditable