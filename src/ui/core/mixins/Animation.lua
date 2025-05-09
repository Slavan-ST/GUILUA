-- src/ui/core/mixins/Animation.lua
local Animation = {}

function Animation:initialize(options)
    -- Инициализация анимаций
    self.animations = {}
    self.animationIdCounter = 0
end

-- Запуск анимации
function Animation:animate(animationType, params, onComplete)
    self.animationIdCounter = self.animationIdCounter + 1
    local animationId = self.animationIdCounter

    
    local animation = {
        id = animationId,
        type = animationType,
        startTime = love.timer.getTime(),
        duration = params.duration or 0.3,
        from = params.from,
        to = params.to,
        easing = params.easing or "linear",
        onComplete = onComplete
    }

    table.insert(self.animations, animation)
    return animationId
end

-- Остановка анимации по ID
function Animation:stopAnimation(animationId)
    for i = #self.animations, 1, -1 do
        if self.animations[i].id == animationId then
            table.remove(self.animations, i)
            return true
        end
    end
    return false
end

-- Обновление анимаций
function Animation:updateAnimations(dt)
    local currentTime = love.timer.getTime()
    local completedAnimations = {}

    for i = #self.animations, 1, -1 do
        local anim = self.animations[i]
        local elapsedTime = currentTime - anim.startTime
        local progress = math.min(elapsedTime / anim.duration, 1)
        local easedProgress = self:applyEasing(anim.easing, progress)

        self:applyAnimationProperties(anim, easedProgress)
        
        
        if progress >= 1 then
            table.insert(completedAnimations, anim)
            table.remove(self.animations, i)
        end
    end

    for _, anim in ipairs(completedAnimations) do
        if anim.onComplete then anim.onComplete() end
    end
end

-- Easing-функции
function Animation:applyEasing(type, t)
    if type == "easeIn" then return t * t
    elseif type == "easeOut" then return 1 - (1 - t)^2
    elseif type == "easeInOut" then return t < 0.5 and 2 * t^2 or 1 - (-2 * t + 2)^2 / 2
    else return t end
end

-- Применение изменений к свойствам
function Animation:applyAnimationProperties(anim, progress)
    local value = self:lerp(anim.from, anim.to, progress)
    
    if anim.type == "scale" then
        self.scaleX = value
        self.scaleY = value
    elseif anim.type == "scaleX" then
        self.scaleX = value
    elseif anim.type == "scaleY" then
        self.scaleY = value
    elseif anim.type == "opacity" then
        self.alpha = value
    elseif anim.type == "color" then
        self:setStyle({ background_color = value })
    elseif anim.type == "position" then
        self.x = value.x
        self.y = value.y
    end
end

-- Линейная интерполяция
function Animation:lerp(from, to, progress)
    if type(from) == "number" and type(to) == "number" then
        return from + (to - from) * progress
    elseif type(from) == "table" and type(to) == "table" then
        local result = {}
        for i = 1, #from do
            result[i] = from[i] + (to[i] - from[i]) * progress
        end
        return result
    end
    return to
end

return Animation