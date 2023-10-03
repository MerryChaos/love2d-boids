Boid = Object.extend(Object)

function Boid:new(color)
    local width, height = love.graphics.getDimensions()
    self.pos = Vector(math.random(0, width), math.random(0, height))
    -- self.size = math.random(5, 25)
    self.size = sliders.minSize.value + math.random() * sliders.sizeScale.value
    self.color = color or { math.random(), math.random(), math.random() }
    self.maxSpeed = 100
    self.acceleration = Vector()
    self.velocity = Vector(math.random() * 2 - 1, math.random() * 2 - 1):normalize()

    self.perceptionRadius = 40 + self:radius()
    self.seperateDistance = self.perceptionRadius

    self.sCoef = 1.5
    self.aCoef = 1.5
    self.cCoef = 1.0
    
    -- self.sCoef = math.random()
    -- self.aCoef = math.random()
    -- self.cCoef = math.random()

    -- self.sCoef = self.color[1]
    -- self.aCoef = self.color[2]
    -- self.cCoef = self.color[3]
end

function Boid:setCoefs(s, a, c)
    self.sCoef = s
    self.aCoef = a
    self.cCoef = c
end

function Boid:__seperate(boids)
    local v = Vector()

    for i = 1, #boids do
        if Vector.dist(self.pos, boids[i].pos) < self.seperateDistance then
            v = v - (boids[i].pos - self.pos)
        end
    end

    if #boids ~= 0 then
        v = v / #boids
        v = v:normalize() * self.maxSpeed
        -- self.acceleration = self.acceleration + v * self.sCoef
    end
    return v
end

function Boid:__align(boids)
    local v = Vector()

    for i = 1, #boids do
        v = v + boids[i].velocity
    end

    if #boids ~= 0 then
        v = v / #boids
        v = v - self.velocity
        v = v:normalize() * self.maxSpeed
        -- self.acceleration = self.acceleration + v * self.aCoef
    end
    return v
end

function Boid:__cohere(boids)
    local v = Vector()

    for i = 1, #boids do
        v = v + boids[i].pos
    end

    if #boids ~= 0 then
        v = v / #boids
        v = v - self.pos
        v = v:normalize() * self.maxSpeed
        -- self.acceleration = self.acceleration + v * self.cCoef
    end
    return v
end

function Boid:update(dt, boids)
    local pBoids = self:perceptedBoids(boids)
    
    local sepVec = self:__seperate(pBoids) * sliders.separation.value
    local aliVec = self:__align(pBoids) * sliders.alignment.value
    local cohVec = self:__cohere(pBoids) * sliders.cohesion.value
    -- local sepVec = self:__seperate(pBoids) * self.sCoef
    -- local aliVec = self:__align(pBoids) * self.aCoef
    -- local cohVec = self:__cohere(pBoids) * self.cCoef
    
    -- Apply calculated forces to the acceleration
    self.acceleration = self.acceleration + sepVec + aliVec + cohVec

    -- Update velocity considering acceleration
    local newVelocity = self.velocity + self.acceleration * dt
    if newVelocity:mag() > self.maxSpeed then
        newVelocity = newVelocity:normalize() * self.maxSpeed
    end
    
    -- Linear interpolation (lerping) for the velocity
    local t = 0.1
    self.velocity = self.velocity + (newVelocity - self.velocity) * t
    
    -- Update position
    self.pos = self.pos + self.velocity * dt
    
    -- Check boundary and wrap if needed
    self:__wrap()
end

function Boid:__wrap()
    if self.pos.x > love.graphics.getWidth() + self:radius() then
        self.pos.x = -self:radius()
    elseif self.pos.x < -self:radius() then
        self.pos.x = love.graphics.getWidth() + self:radius()
    end
    if self.pos.y > love.graphics.getHeight() + self:radius() then
        self.pos.y = -self:radius()
    elseif self.pos.y < -self:radius() then
        self.pos.y = love.graphics.getHeight() + self:radius()
    end
end

function Boid:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.pos.x, self.pos.y, self.size, self.size)
end

function Boid:radius()
    return self.size / 2
end

function Boid:perceptedBoids(boids)
    local perceptedBoids = {}
    for i = 1, #boids do
        if boids[i] == self then goto continue end

        local d = Vector.dist(self.pos, boids[i].pos)
        if d <= self.perceptionRadius then
            table.insert(perceptedBoids, boids[i])
        end

        ::continue::
    end
    return perceptedBoids
end

function Boid:centerOfMass(boids)
    local v = Vector(0, 0)
    local total = 0
    for i = 1, #boids do
        v = v + boids[i].pos
        total = total + 1
    end

    if total ~= 0 then
        return v / total
    end

    return self.pos
end
