-- src/ui/core/ThemeManager.lua

local ThemeManager = {}

-- Таблица для хранения тем
ThemeManager.themes = {
    default = {
        scrollbar_size = 10,
        scrollbar_margin = 2,
        scrollbar_color = {0.1, 0.5, 0.5, 0.5},

        background_color = {0.9, 0.9, 0.9, 1},
        bounding_box_color = {0.7, 0.6, 0.4, 1},

        touch_scroll_multiplier = 15,
        friction = 0.92,
        max_velocity = 1000,
    },
    dark = {
        scrollbar_size = 8,
        scrollbar_margin = 3,
        scrollbar_color = {0.8, 0.3, 0.3, 0.6},

        background_color = {0.2, 0.2, 0.2, 1},
        bounding_box_color = {0.5, 0.5, 0.5, 1},

        touch_scroll_multiplier = 18,
        friction = 0.95,
        max_velocity = 1200,
    }
}

-- Текущая активная тема
ThemeManager.currentTheme = "default"

-- Получить значение из текущей темы с fallback к дефолту
function ThemeManager.get(key, fallback)
    local currentTheme = ThemeManager.themes[ThemeManager.currentTheme]
    if currentTheme and currentTheme[key] ~= nil then
        return currentTheme[key]
    end
    return ThemeManager.themes.default[key] or fallback
end

-- Установить текущую тему
function ThemeManager.setTheme(name)
    if ThemeManager.themes[name] then
        ThemeManager.currentTheme = name
    else
        error("Unknown theme: " .. tostring(name))
    end
end



return ThemeManager