local Geometry = {}

function Geometry:initialize()
    self.x = 0
    self.y = 0
    self.width = 0
    self.height = 0
end

function Geometry:isInside(x, y)
    return x >= self.x and y >= self.y and x <= self.x + self.width and y <= self.y + self.height
end

function Geometry:toGlobal(x, y)
    local node = self
    while node.parent do
        x = x + node.parent.x
        y = y + node.parent.y
        node = node.parent
    end
    return x, y
end

return Geometry