
local ThemeManager = require("src.ui.core.ThemeManager")

local Stylable = {}

function Stylable:initialize()
    -- Стилевые свойства, которые могут быть переопределены через options или взяты из темы
    self.style = {
        background_color = nil,
        border_color = nil,
        border_width = nil,
        padding = nil,
        margin = nil,
        font = nil,
        font_size = nil,
        corner_radius = nil,
    }

    -- Текущая тема — может изменяться глобально
    self.currentTheme = ThemeManager.currentTheme
end

-- Обновление стиля из опций
-- Обновление стиля из опций
function Stylable:setStyle(options)
    if not options then return end
    for k, v in pairs(options) do
        self.style[k] = v  -- Просто устанавливаем все ключи из options
    end
end

-- Получение значения стиля с fallback к текущей теме
function Stylable:getStyle(key)
    local value = self.style[key]
    if value ~= nil then
        return value
    end

    return ThemeManager.get(key)
end

-- Установка цвета фона
function Stylable:setBackgroundColor(color)
    self.style.background_color = color
end

-- Установка цвета рамки
function Stylable:setBorderColor(color)
    self.style.border_color = color
end

-- Установка толщины рамки
function Stylable:setBorderWidth(width)
    self.style.border_width = width
end

-- Установка внутреннего отступа
function Stylable:setPadding(padding)
    self.style.padding = padding
end

-- Установка внешнего отступа
function Stylable:setMargin(margin)
    self.style.margin = margin
end

return Stylable