local Visibility = {}

function Visibility:initialize(options)
    self.visible = options and options.visible or true
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