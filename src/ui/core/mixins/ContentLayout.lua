

-- ВНИМАНИЕ!! ПРИМЕНЯТЬ ТОЛЬКО К ЭЛЕМЕНТАМ С МИКЧИНОМ ГЕОМЕТРИИ
local ContentLayout = {}

function ContentLayout:initialize(options)
    self.contentWidth = options and options.contentWidth or 0
    self.contentHeight = options and options.contentHeight or 0
    self.padding = options and options.padding or 0
end

function ContentLayout:updateContentSize()
    self.contentWidth = 0
    self.contentHeight = 0
    for _, child in ipairs(self.children) do
        self.contentWidth = math.max(self.contentWidth, child.x + child.width)
        self.contentHeight = math.max(self.contentHeight, child.y + child.height)
    end
end

return ContentLayout