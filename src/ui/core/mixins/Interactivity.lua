local Interactivity = {}

function Interactivity:initialize()
    self.enabled = true
end

function Interactivity:enable()
    self.enabled = true
    return self
end

function Interactivity:disable()
    self.enabled = false
    return self
end

return Interactivity