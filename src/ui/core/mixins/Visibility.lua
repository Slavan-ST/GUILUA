local Visibility = {}

function Visibility:initialize()
    self.visible = true
end

function Visibility:show()
    self.visible = true
    return self
end

function Visibility:hide()
    self.visible = false
    return self
end

return Visibility