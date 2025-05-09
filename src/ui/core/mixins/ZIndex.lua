local ZIndex = {}

function ZIndex:initialize(options)
    self.zIndex = options and options.zIndex or 0
end

function ZIndex:setZIndex(value)
    self.zIndex = value or 0
    return self
end

return ZIndex