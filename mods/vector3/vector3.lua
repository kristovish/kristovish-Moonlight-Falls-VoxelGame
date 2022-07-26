local mod = {}
local vector3 = {}
vector3.__index = vector3

-- locals

local floor = math.floor
local pi = math.pi
local mrandom = math.random
local sqrt = math.sqrt

local S = minetest and minetest.get_translator('vector3') or
              function(str) return str end

-- local funcs

local function round(num, dec)
    local mult = 10 ^ (dec or 0)
    return floor(num * mult + 0.5) / mult
end

local function isnumber(n) return type(n) == 'number' end

local function isnilornumber(n) return n == nil or type(n) == 'number' end

local function allnillornumber(...)
    local args = {...}
    for _, n in ipairs(args) do if not isnilornumber(n) then return false end end
    return true
end

-- local function isvector(v) return getmetatable(v) == vector3 end
local function isvector(v)
    return type(v) == 'table' and isnumber(v.x) and isnumber(v.y) and
               isnumber(v.z)
end
local function allvector(...)
    local args = {...}
    for _, v in ipairs(args) do if not isvector(v) then return false end end
    return true
end

local function circle_sampling(r1, r2)
    local tr1 = type(r1)
    local tr2 = type(r2)
    if tr1 == 'nil' then
        if tr2 == 'nil' then
            while true do
                local x = mrandom() * 2 - 1
                local z = mrandom() * 2 - 1
                if x * x + z * z < 1 then return x, z end
            end
        elseif tr2 == 'number' then
            local tmp1 = 2 * r2
            local tmp2 = r2 * r2
            while true do
                local x = mrandom() * tmp1 - r2
                local z = mrandom() * tmp1 - r2
                if x * x + z * z < tmp2 then return x, z end
            end
        end
    elseif tr1 == 'number' then
        if tr2 == 'nil' then
            local tmp1 = 2 * r1
            local tmp2 = r1 * r1
            while true do
                local x = mrandom() * tmp1 - r1
                local z = mrandom() * tmp1 - r1
                if x * x + z * z < tmp2 then return x, z end
            end
        elseif tr2 == 'number' then
            if r1 ~= r2 then
                local tmp1 = 2 * r2
                local tmp2 = r1 * r1
                local tmp3 = r2 * r2
                while true do
                    local x = mrandom() * tmp1 - r2
                    local z = mrandom() * tmp1 - r2
                    local d = x * x + z * z
                    if d >= tmp2 and d < tmp3 then
                        return x, z
                    end
                end
            else
                while true do
                    local x = mrandom() * 2 - 1
                    local z = mrandom() * 2 - 1
                    if x + z ~= 0 then
                        f = r1 / sqrt(x * x + z * z)
                        return x * f, z * f
                    end
                end
            end
        end
    end
end

local function sphere_sampling(r1, r2)
    local tr1 = type(r1)
    local tr2 = type(r2)
    if tr1 == 'nil' then
        if tr2 == 'nil' then
            while true do
                local x = mrandom() * 2 - 1
                local y = mrandom() * 2 - 1
                local z = mrandom() * 2 - 1
                if x * x + y * y + z * z < 1 then return x, y, z end
            end
        elseif tr2 == 'number' then
            local tmp1 = 2 * r2
            local tmp2 = r2 * r2
            while true do
                local x = mrandom() * tmp1 - r2
                local y = mrandom() * tmp1 - r2
                local z = mrandom() * tmp1 - r2
                if x * x + y * y + z * z < tmp2 then
                    return x, y, z
                end
            end
        end
    elseif tr1 == 'number' then
        if tr2 == 'nil' then
            local tmp1 = 2 * r1
            local tmp2 = r1 * r1
            while true do
                local x = mrandom() * tmp1 - r1
                local y = mrandom() * tmp1 - r1
                local z = mrandom() * tmp1 - r1
                if x * x + y * y + z * z < tmp2 then
                    return x, y, z
                end
            end
        elseif tr2 == 'number' then
            if r1 ~= r2 then
                local tmp1 = 2 * r2
                local tmp2 = r1 * r1
                local tmp3 = r2 * r2
                while true do
                    local x = mrandom() * tmp1 - r2
                    local y = mrandom() * tmp1 - r2
                    local z = mrandom() * tmp1 - r2
                    local d2 = x * x + y * y + z * z
                    if d2 >= tmp2 and d2 < tmp3 then
                        return x, y, z
                    end
                end
            else
                while true do
                    local x = mrandom() * 2 - 1
                    local y = mrandom() * 2 - 1
                    local z = mrandom() * 2 - 1
                    if x + y + z ~= 0 then
                        local f = r1 / sqrt(x * x + y * y + z * z)
                        return x * f, y * f, z * f
                    end
                end
            end
        end
    end
end

local function sin(x)
    if x % math.pi == 0 then
        return 0
    else
        return math.sin(x)
    end
end

local function cos(x)
    if x % math.pi == math.pi / 2 then
        return 0
    else
        return math.cos(x)
    end
end

local function new(x, y, z)

    local v = {}

    if isvector(x) then
        v.x = x.x
        v.y = x.y
        v.z = x.z
    elseif allnillornumber(x, y, z) then
        v.x = x or 0
        v.y = y or 0
        v.z = z or 0
    else
        error(S('format error'))
    end

    return setmetatable(v, vector3)

end

local function fromSpherical(r, theta, phi)

    if allnillornumber(r, theta, phi) then
        --[[
            due to minetest system coordinate we need toadd pi/2 to phi
        ]] --
        local r = r or 1
        local theta = theta or pi / 2
        local phi = phi and (phi + pi / 2) or pi / 2

        local x = r * sin(phi) * sin(theta)
        local y = r * cos(theta)
        local z = -r * cos(phi) * sin(theta)

        return new(x, y, z)
    end

end

local function fromCylindrical(r, phi, y)

    if allnillornumber(r, phi, y) then
        --[[
            due to minetest system coordinate we need toadd pi/2 to phi
        ]] --
        local r = r or 1
        local phi = phi and (phi + pi / 2) or pi / 2

        local x = r * sin(phi)
        local y = y or 1
        local z = -r * cos(phi)

        return new(x, y, z)
    end

end

local function fromPolar(r, phi)

    if allnillornumber(r, phi) then
        --[[
            due to minetest system coordinate we need toadd pi/2 to phi
        ]] --
        local r = r or 1
        local phi = phi and (phi + pi / 2) or pi / 2

        local x = r * sin(phi)
        local y = 0
        local z = -r * cos(phi)

        return new(x, y, z)
    end

end

local function srandom(a, b)
    x, y, z = sphere_sampling(a, b)
    return new(x, y, z)

end

local function crandom(a, b, c, d)

    local ta = type(a)
    local tb = type(b)
    local tc = type(c)
    local td = type(d)

    x, z = circle_sampling(a, b)

    local y
    if tc == 'nil' then
        if td == 'nil' then
            y = mrandom()
        elseif td == 'number' then
            y = mrandom() * d
        end
    elseif tc == 'number' then
        if td == 'nil' then
            y = mrandom() * c
        elseif td == 'number' then
            y = mrandom() * (d - c) + c
        end
    end

    return new(x, y, z)

end

local function prandom(a, b)
    x, z = circle_sampling(a, b)
    return new(x, 0, z)
end

-- funcs

function vector3:clone() return new(self.x, self.y, self.z) end

function vector3:length()
    return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

function vector3:norm()

    local l = self:length()
    if l == 0 then
        return new()
    else
        return self / l
    end

end

function vector3:floor() return new(floor(self.x), floor(self.y), floor(self.z)) end

function vector3:round(dec)
    return new(round(self.x, dec), round(self.y, dec), round(self.z, dec))
end

function vector3:apply(f)
    local x, y, z = f(self.x), f(self.y), f(self.z)
    if allnillornumber(x, y, z) then
        return new(x, y, z)
    else
        error(S('format error'))
    end
end

function vector3:set(x, y, z)
    if allnillornumber(x, y, z) then
        return new(x and x or self.x, y and y or self.y, z and z or self.z)
    else
        error(S('format error'))
    end
end

function vector3:offset(a, b, c)
    if allnillornumber(a, b, c) then
        return new(self.x + (a or 0), self.y + (b or 0), self.z + (c or 0))
    else
        error(S('format error'))
    end
end

function vector3:dot(b) return self.x * b.x + self.y * b.y + self.z * b.z end

function vector3:cross(b)
    return new(self.y * b.z - self.z * b.y, self.z * b.x - self.x * b.z,
               self.x * b.y - self.y * b.x)
end

function vector3:rotate_around(axis, angle)
    axis = axis:norm()
    return cos(angle) * self + (1 - cos(angle)) * (self:dot(axis)) * axis +
               sin(angle) * (self:cross(axis))
end

function vector3:dist(b)

    if isvector(b) then
        return sqrt((self.x - b.x) * (self.x - b.x) + (self.y - b.y) *
                        (self.y - b.y) + (self.z - b.z) * (self.z - b.z))
    else
        error(S('format error'))
    end
end

function vector3:scale(mag)
    if isnumber(mag) then
        local l = self:length()
        if l == 0 then
            return new()
        else
            return self * (mag / l)
        end
    else
        error(S('format error'))
    end
end

function vector3:limit(max)
    if isnumber(max) then
        local l = self:length()
        if l > max then
            return self:scale(max)
        else
            return self:clone()
        end
    else
        error(S('format error'))
    end
end

function vector3:unpack() return self.x, self.y, self.z end

-- meta

function vector3:__tostring()
    return string.format('(%.3g, %.3g, %.3g)', self.x, self.y, self.z)
end

function vector3.__concat(a, b)
    local s1 = isvector(a) and a:__tostring() or tostring(a)
    local s2 = isvector(b) and b:__tostring() or tostring(b)
    return s1 .. s2

end

function vector3:__unm() return new(-self.x, -self.y, -self.z) end

function vector3.__eq(a, b)
    if allvector(a, b) then
        return a.x == b.x and a.y == b.y and a.z == b.z
    else
        error(S('format error'))
    end
end

function vector3.__add(a, b)

    if isvector(a) then
        if isvector(b) then
            return new(a.x + b.x, a.y + b.y, a.z + b.z)
        elseif isnumber(b) then
            return new(a.x + b, a.y + b, a.z + b)
        end
    elseif isnumber(a) and isvector(b) then
        return new(a + b.x, a + b.y, a + b.z)
    else
        error(S('format error'))
    end

end

function vector3.__sub(a, b)

    if isvector(a) then
        if isvector(b) then
            return new(a.x - b.x, a.y - b.y, a.z - b.z)
        elseif isnumber(b) then
            return new(a.x - b, a.y - b, a.z - b)
        end
    elseif isnumber(a) and isvector(b) then
        return new(a - b.x, a - b.y, a - b.z)
    else
        error(S('format error'))
    end

end

function vector3.__mul(a, b)

    if isvector(a) then
        if isvector(b) then
            return new(a.x * b.x, a.y * b.y, a.z * b.z)
        elseif isnumber(b) then
            return new(a.x * b, a.y * b, a.z * b)
        end
    elseif isnumber(a) and isvector(b) then
        return new(a * b.x, a * b.y, a * b.z)
    else
        error(S('format error'))
    end

end

function vector3.__div(a, b)

    if isvector(a) then
        if isvector(b) then
            return new(a.x / b.x, a.y / b.y, a.z / b.z)
        elseif isnumber(b) then
            return new(a.x / b, a.y / b, a.z / b)
        end
    elseif isnumber(a) and isvector(b) then
        return new(a / b.x, a / b.y, a / b.z)
    else
        error(S('format error'))
    end

end

-- export

mod.fromSpherical = fromSpherical
mod.fromCylindrical = fromCylindrical
mod.fromPolar = fromPolar
mod.srandom = srandom
mod.crandom = crandom
mod.prandom = prandom
mod.zero = new(0, 0, 0)
mod.one = new(1, 1, 1)
mod.x = new(1, 0, 0)
mod.y = new(0, 1, 0)
mod.z = new(0, 0, 1)
mod.xy = new(1, 1, 0)
mod.yz = new(0, 1, 1)
mod.xz = new(1, 0, 1)
mod.nx = -new(1, 0, 0)
mod.ny = -new(0, 1, 0)
mod.nz = -new(0, 0, 1)
mod.nxy = -new(1, 1, 0)
mod.nyz = -new(0, 1, 1)
mod.nxz = -new(1, 0, 1)

return setmetatable(mod, {__call = function(_, ...) return new(...) end})
