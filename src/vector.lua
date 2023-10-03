local Vector = {}
Vector.__index = Vector

setmetatable(Vector, {
    __call = function(cls, ...)
        return cls:new(...)
    end,
})

function Vector:new(x, y)
    return setmetatable({ x = x or 0, y = y or 0 }, Vector)
end

local function isvector(t)
    return getmetatable(t) == Vector
end

function Vector.__add(a, b)
    assert(isvector(a) and isvector(b), "add: wrong argument type: (expected <Vector>)")
    return Vector(a.x + b.x, a.y + b.y)
end

function Vector.__sub(a, b)
    assert(isvector(b), "sub: wrong argument type: (expected <Vector>)")
    return Vector(a.x - b.x, a.y - b.y)
end

function Vector.__mul(a, b)
    if type(a) == 'number' then
        assert(isvector(b), "mul: wrong argument type: (expected <number> and <Vector>)")
        return Vector(a * b.x, a * b.y)
    elseif type(b) == 'number' then
        assert(isvector(a), "mul: wrong argument type: (expected <Vector> and <number>)")
        return Vector(a.x * b, a.y * b)
    else
        assert(isvector(a) and isvector(b), "mul: wrong argument type: (expected <Vector> and <Vector>)")
        return Vector(a.x * b.x, a.y * b.y)
    end
end

function Vector.__div(a, b)
    assert(isvector(a) and type(b) == 'number', "div: wrong argument type: (expected <Vector> and <number>)")
    return Vector(a.x / b, a.y / b)
end

function Vector.dist(a, b)
    assert(isvector(a) and isvector(b), "dist: wrong argument type: (expected <Vector> and <Vector>)")
    return math.sqrt((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2)
end

function Vector:mag()
    return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

function Vector:setMag(mag)
    if self:mag() == 0 then
        return self
    end
    self:normalize()
    self = self * mag
    return self
end

function Vector:normalize()
    local m = self:mag()
    if m ~= 0 then
        self = self / m
    end
    return self
end

function Vector:__tostring()
    return "(" .. self.x .. ", " .. self.y .. ")"
end

return Vector