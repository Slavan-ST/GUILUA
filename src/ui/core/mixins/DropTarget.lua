local DropTarget = {}

function DropTarget:initialize()
    self.dropEnabled = true
end

function DropTarget:enableDrop()
    self.dropEnabled = true
    return self
end

function DropTarget:disableDrop()
    self.dropEnabled = false
    return self
end

-- Вызывается при drop'е другого элемента на нас
function DropTarget:onDrop(draggedElement, event)
    if not self.dropEnabled then return end
    require("src.ui.utils.DebugConsole").log("drop")
    self:dispatchEvent({ type = "drop", element = draggedElement })
end

return DropTarget