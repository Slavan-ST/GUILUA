-- src/ui/core/mixins/Spacing.lua

local Spacing = {}

function Spacing:initialize(options)
    self.paddingLeft   = options and options.paddingLeft or 0
    self.paddingRight  = options and options.paddingRight or 0
    self.paddingTop    = options and options.paddingTop or 0
    self.paddingBottom = options and options.paddingBottom or 0

    self.marginLeft   = options and options.marginLeft or 0
    self.marginRight  = options and options.marginRight or 0
    self.marginTop    = options and options.marginTop or 0
    self.marginBottom = options and options.marginBottom or 0
end

-- === Padding геттеры ===
function Spacing:getPaddingLeft()   return self.paddingLeft or 0 end
function Spacing:getPaddingRight()  return self.paddingRight or 0 end
function Spacing:getPaddingTop()    return self.paddingTop or 0 end
function Spacing:getPaddingBottom() return self.paddingBottom or 0 end

function Spacing:getPaddingX()
    return self:getPaddingLeft() + self:getPaddingRight()
end

function Spacing:getPaddingY()
    return self:getPaddingTop() + self:getPaddingBottom()
end

-- === Margin геттеры ===
function Spacing:getMarginLeft()   return self.marginLeft or 0 end
function Spacing:getMarginRight()  return self.marginRight or 0 end
function Spacing:getMarginTop()    return self.marginTop or 0 end
function Spacing:getMarginBottom() return self.marginBottom or 0 end

function Spacing:getMarginX()
    return self:getMarginLeft() + self:getMarginRight()
end

function Spacing:getMarginY()
    return self:getMarginTop() + self:getMarginBottom()
end

-- === setPadding и setMargin (оставляем их для удобства настройки) ===
function Spacing:setPadding(left, right, top, bottom)
    self.paddingLeft = left or self.paddingLeft
    self.paddingRight = right or self.paddingRight
    self.paddingTop = top or self.paddingTop
    self.paddingBottom = bottom or self.paddingBottom
end

function Spacing:setMargin(left, right, top, bottom)
    self.marginLeft = left or self.marginLeft
    self.marginRight = right or self.marginRight
    self.marginTop = top or self.marginTop
    self.marginBottom = bottom or self.marginBottom
end

return Spacing