local DropTarget = {}

function DropTarget:initialize()
    self.dropEnabled = true
    
    if self.options.drop then
      self:addEventListener("drop", function(e) return self.options.drop(e) end)
    end
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
    
    self:dispatchEvent({ type = "drop", x = self.x, y = self.y  })
end

return DropTarget