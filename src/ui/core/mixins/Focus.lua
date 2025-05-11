local Focus = {}
local  UIManager = require("src.ui.core.UIManager")
local ui = UIManager.getInstance()


function Focus:initialize(options)
    self.hasFocus = false

    -- Привязываем обработчики событий, если они нужны
    if options and options.focusHandlers then
        self:on("focusgained", options.focusHandlers.onFocusGained)
        self:on("focuslost",  options.focusHandlers.onFocusLost)
    end
end

-- Устанавливает фокус на этот элемент
function Focus:focus()
    
    if self.interactive ~= false then
        ui:setFocus(self)
    end
    return self
end

-- Проверяет, находится ли элемент в фокусе
function Focus:isFocused()
    return self.hasFocus == true
end

return Focus