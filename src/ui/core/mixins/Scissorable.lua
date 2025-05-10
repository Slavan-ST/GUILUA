-- src/ui/core/mixins/Scissorable.lua
local Scissorable = {}

function Scissorable:initialize(options)
    self.scissorEnabled = options and options.scissor or false
    self._previousScissor = nil -- Для хранения старого scissor
end

function Scissorable:enableScissor(enable)
    self.scissorEnabled = enable ~= false
end

function Scissorable:applyScissor()
    if self.scissorEnabled then
        -- Сохраняем текущую область обрезки
        local x, y, w, h = love.graphics.getScissor()
        self._previousScissor = x and {x, y, w, h} or nil
        
        -- Устанавливаем новый scissor
        love.graphics.setScissor(
            self.x + self:getMarginLeft(),
            self.y + self:getMarginTop(),
            self.width - self:getMarginX(),
            self.height - self:getMarginY()
        )
    end
end

function Scissorable:clearScissor()
    if self.scissorEnabled then
    -- Восстанавливаем предыдущую область обрезки
    if self._previousScissor and #self._previousScissor == 4 then
        love.graphics.setScissor(
            self._previousScissor[1],
            self._previousScissor[2],
            self._previousScissor[3],
            self._previousScissor[4]
        )
    else
        love.graphics.setScissor() -- Отключаем scissor
    end
    self._previousScissor = nil
end
end
return Scissorable