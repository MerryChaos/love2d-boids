local Colors = {}

function rgbToHsv(r, g, b)
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v = max, max - min, max
    if max == min then
        h = 0
    elseif max == r then
        h = (g - b) / (max - min)
        if g < b then h = h + 6 end
    elseif max == g then
        h = (b - r) / (max - min) + 2
    elseif max == b then
        h = (r - g) / (max - min) + 4
    end
    h = h / 6
    return h, s, v
end

function hsvToRgb(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if     i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    return r, g, b
end

function rgbToOklab(r, g, b)
    -- Convert to LMS with D65 illuminant
    local l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
    local m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
    local s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b
    
    -- Non-linearly compress LMS to Oklab
    local lO = math.cbrt(l)
    local mO = math.cbrt(m)
    local sO = math.cbrt(s)
    
    -- Convert to Oklab
    local L = 0.2104542553 * lO + 0.7936177850 * mO - 0.0040720468 * sO
    local a = 1.9779984951 * lO - 2.4285922050 * mO + 0.4505937099 * sO
    local b = 0.0259040371 * lO + 0.7827717662 * mO - 0.8086757660 * sO
    
    return L, a, b
end

function oklabToRgb(L, a, b)
    -- Convert from Oklab to linear LMS
    local lO = L + 0.3963377774 * a + 0.2158037573 * b
    local mO = L - 0.1055613458 * a - 0.0638541728 * b
    local sO = L - 0.0894841775 * a - 1.2914855480 * b
    
    local l = lO ^ 3
    local m = mO ^ 3
    local s = sO ^ 3
    
    -- Convert to linear sRGB with D65 illuminant
    local r =  4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
    local g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
    local b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
    
    -- Desaturate and rescale to keep [r,g,b] between 0 and 1 for all L,a,b
    local scale = math.max(r, g, b)
    if scale > 1 then
        r = r/scale
        g = g/scale
        b = b/scale
    end
    
    -- Ensure the values are clamped to [0, 1]
    r = math.max(0, math.min(1, r))
    g = math.max(0, math.min(1, g))
    b = math.max(0, math.min(1, b))
    
    return r, g, b
end

function hsvToOklab(h, s, v)
    local r, g, b = hsvToRgb(h, s, v)
    return rgbToOklab(r, g, b)
end

function oklabToHsv(L, a, b)
    local r, g, b = oklabToRgb(L, a, b)
    return rgbToHsv(r, g, b)
end

function oklabToOklch(L, a, b)
    local C = math.sqrt(a^2 + b^2)
    local h = math.atan2(b, a)
    return L, C, h
end

function oklchToOklab(L, C, h)
    local a = C * math.cos(h)
    local b = C * math.sin(h)
    return L, a, b
end

function oklchToRgb(L, C, h)
    local L, a, b = oklchToOklab(L, C, h)
    local r, g, b = oklabToRgb(L, a, b)
    
    return r, g, b
end

function averageColor(colors)
    local avg = {0, 0, 0}
    for _, color in ipairs(colors) do
        for i = 1, 3 do
            avg[i] = avg[i] + color[i]
        end
    end
    for i = 1, 3 do
        avg[i] = avg[i] / #colors
    end
    return avg
end

function adjustBrightness(color, factor)
    return {color[1] * factor, color[2] * factor, color[3] * factor}
end

function getMonochromaticColors(L, C, h, num)
    local colors = {}
    -- Adjust lightness and chroma to generate variants
    for i = 1, num do
        local newL = L * (0.8 + 0.6 * (i - 1) / (num - 1))  -- Example lightness adjustment
        local newC = C * (0.6 + 0.8 * (i - 1) / (num - 1))  -- Example chroma adjustment
        table.insert(colors, {oklchToRgb(newL, newC, h)})
    end
    return colors
end

function getHueShiftColors(L, C, h, num, shiftAmount)
    local colors = {}
    for i = 1, num do
        local newH = h + shiftAmount * (i - 1)  -- Shifting the hue
        table.insert(colors, {oklchToRgb(L, C, newH)})
    end
    return colors
end

function Colors.getRandomPalette(numMono, numShifted)
    local L = 0.8
    local C = 0.5
    local hM = math.random() * math.pi * 2
    local hS = math.random() * math.pi * 2
    
    local monoColors = getMonochromaticColors(L, C, hM, numMono)
    local shiftedColors = getHueShiftColors(L, C, hS, numShifted, math.pi/6)
    
    local colors = {}
    for _, color in ipairs(monoColors) do
        table.insert(colors, color)
    end
    for _, color in ipairs(shiftedColors) do
        table.insert(colors, color)
    end

    local backgroundColor = Colors.getComplementaryBackground(hS, L, C)

    return colors, backgroundColor
end

function Colors.getComplementaryBackground(h, L, C)
    local bgH = (h + math.pi) % (2 * math.pi) -- Get complementary hue
    local bgL = L * 0.5  -- You might wish to alter this based on testing
    local bgC = C * 0.2  -- Reducing chroma for a softer color
    
    -- Convert to RGB for rendering
    local bgR, bgG, bgB = oklchToRgb(bgL, bgC, bgH)
    
    return {bgR, bgG, bgB}
end

return Colors