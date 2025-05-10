-- src/ui/core/mixins/Offsetable.lua
local Offsetable = {}

function Offsetable:initialize(options)
    self.offsetX = options and options.offsetX or 0
    self.offsetY = options and options.offsetY or 0
end

function Offsetable:setOffset(x, y)
    self.offsetX = x or self.offsetX
    self.offsetY = y or self.offsetY
end

function Offsetable:getOffsetX() return self.offsetX end
function Offsetable:getOffsetY() return self.offsetY end

return Offsetable