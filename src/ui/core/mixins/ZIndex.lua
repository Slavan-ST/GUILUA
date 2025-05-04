local ZIndex = {}

function ZIndex:initialize()
    self.zIndex = 0
end

function ZIndex:setZIndex(value)
    self.zIndex = value or 0
    if self.parent then
        self.parent:sortChildren()
    end
    return self
end

return ZIndex