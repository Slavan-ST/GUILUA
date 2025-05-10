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
    self.cursorPos = #self.text
    self.cursorVisible = true
    self.cursorBlinkTime = 0.5
    self.cursorTimer = 0

    -- === Callbacks ===
    self.onTextChanged = options.onTextChanged
    self.onEnterPressed = options.onEnterPressed

    -- === Фильтры ===
    self.inputFilter = options.inputFilter -- function(char) return true/false end

    -- === Регистрация обработчиков событий ===
    self:addEventListener("touchpressed", function(e) return self:onTouchPressed(e) end)
    self:addEventListener("focusgained", function() self:onFocus() end)
    self:addEventListener("focuslost", function() self:onBlur() end)
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
function TextEditable:textinput(text)
    if not self.hasFocus then return end

    -- Применяем фильтр ввода
    if self.inputFilter and not self.inputFilter(text) then
        return
    end

    -- Проверка длины
    if self.maxLength > 0 and #self.text >= self.maxLength then
        return
    end

    -- Вставляем символ в позицию курсора
    local newText = string.sub(self.text, 1, self.cursorPos) .. text .. string.sub(self.text, self.cursorPos + 1)
    self:setText(newText)
    self.cursorPos = self.cursorPos + #text
end

-- === Обработка клавиш (backspace, delete, стрелки и т.д.) ===
function TextEditable:keypressed(key)
    if not self.hasFocus then return end

    if key == "backspace" then
        if self.cursorPos > 0 then
            local newText = string.sub(self.text, 1, self.cursorPos - 1) .. string.sub(self.text, self.cursorPos + 1)
            self:setText(newText)
            self.cursorPos = math.max(0, self.cursorPos - 1)
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

    self.cursorTimer = 0
    self.cursorVisible = true
end

-- === Установка нового текста с вызовом callback ===
function TextEditable:setText(text)
    self.text = text or ""
    self.cursorPos = math.min(self.cursorPos, #self.text)

    if self.onTextChanged then
        self.onTextChanged(self, self.text)
    end
end

-- === Получение текущего текста ===
function TextEditable:getText()
    return self.text
end

-- === Обновление курсора (вызывается в love.update) ===
function TextEditable:update(dt)
    if self.hasFocus then
        self.cursorTimer = self.cursorTimer + dt
        if self.cursorTimer >= self.cursorBlinkTime then
            self.cursorTimer = self.cursorTimer - self.cursorBlinkTime
            self.cursorVisible = not self.cursorVisible
        end
    end
end

-- === Отрисовка текста и курсора (вызывается из drawContent или drawSelf) ===
function TextEditable:drawTextContent()
    local font = love.graphics.getFont()
    local displayText = self.text
    if self.passwordMode then
        displayText = string.rep("*", #self.text)
    end

    local textColor = self.textColor
    local x = self:getPaddingLeft()
    local y = (self.height - font:getHeight()) / 2

    love.graphics.setFont(font)
    love.graphics.setColor(textColor)

    if #self.text == 0 and self.placeholder and self.placeholder ~= "" then
        love.graphics.setColor(self.placeholderColor)
        love.graphics.print(self.placeholder, x, y)
    else
        love.graphics.setColor(textColor)
        love.graphics.print(displayText, x, y)
    end

    -- Рисуем курсор
    if self.hasFocus and self.cursorVisible then
        local cursorX = x
        if #displayText > 0 and self.cursorPos > 0 then
            local part = displayText:sub(1, self.cursorPos)
            cursorX = x + font:getWidth(part)
        end
        love.graphics.setColor(textColor)
        love.graphics.rectangle("fill", cursorX, y, 1, font:getHeight())
    end
end

return TextEditable