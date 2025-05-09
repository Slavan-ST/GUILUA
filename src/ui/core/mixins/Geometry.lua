local Geometry = {}

function Geometry:initialize(options)
    self.x = options and options.x or 0
    self.y = options and options.y or 0
    self.width = options and options.width or 0
    self.height = options and options.height or 0
end

function Geometry:isInside(x, y)
    return x >= self.x and y >= self.y and x <= self.x + self.width and y <= self.y + self.height
end


return Geometry