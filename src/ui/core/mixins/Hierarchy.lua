local Hierarchy = {}

function Hierarchy:initialize()
    self.parent = nil
    self.children = {}
end

function Hierarchy:addChild(child)
    if not child then
        require("src.ui.utils.DebugConsole").log("Child cannot be nil")
        return 
    end
    if child.parent then
        child.parent:removeChild(child)
    end
    child.parent = self
    child.x = self.padding or 0
    child.y = (self.contentHeight or 0) + (self.padding or 0)
    table.insert(self.children, child)
    if self.updateContentSize then self:updateContentSize() end
    if self.sortChildren then self:sortChildren() end
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

return Hierarchy