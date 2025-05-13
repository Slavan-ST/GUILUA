local Hierarchy = {}

function Hierarchy:initialize(options)
    self.parent = options and options.parent or nil
    self.children = options and options.contentWidth or {}
end

function Hierarchy:addChild(child)
    if not child then
        return 
    end
    if child.parent then
        child.parent:removeChild(child)
    end
    child.parent = self
    
    table.insert(self.children, child)
    self:sortChildren()
end

function Hierarchy:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            c.parent = nil
            return
        end
    end
end

function Hierarchy:sortChildren()
    table.sort(self.children, function(a, b)
        return (a.zIndex or 0) < (b.zIndex or 0)
    end)
    self._childrenSorted = true
end

function Hierarchy:getRoot()
    local node = self
    while node.parent do
        node = node.parent
    end
    return node
end

function Hierarchy:toGlobal(x, y)
    if not self.parent then return self.x, self.y end
    local node = self
    while node.parent do
        x = x + node.parent.x
        y = y + node.parent.y
        node = node.parent
    end
    return x, y
end

return Hierarchy