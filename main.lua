function love.load()
    math.randomseed(os.time())
    Object = require "src/classic"
    Vector = require "src/vector"
    Colors = require "src/colors"
    require "src/boid"

    love.window.setFullscreen(true, "desktop")

    ISPAUSED = false
    OFFSET = 150

    -- Create global variables to store slider data.
    sliders = {
        numBoids = {value = 500, min = 1, max = 1000, text = "Boid Amount: ", w = 200, x = 150, y = 20, dragging = false, isLocked = false, isInt = true},
        separation = {value = 0.5, min = 0, max = 1, text = "Separation: ", w = 200, x = 150, y = 50, dragging = false, isLocked = false},
        alignment = {value = 0.5, min = 0, max = 1, text = "Alignment: ", w = 200, x = 150, y = 70, dragging = false, isLocked = false},
        cohesion = {value = 0.5, min = 0, max = 1, text = "Cohesion: ", w = 200, x = 150, y = 90, dragging = false, isLocked = false},
        minSize = {value = 5, min = 0.1, max = 50, text = "Min Size: ", w = 200, x = 150, y = 170, dragging = false, isLocked = false},
        sizeScale = {value = 20, min = 0, max = 100, text = "Size Scale: ", w = 200, x = 150, y = 190, dragging = false, isLocked = false},
        monoColors = {value = 2, min = 0, max = 10, text = "Mono Colors: ", w = 200, x = 150, y = 120, dragging = false, isLocked = false, isInt = true},
        shiftColors = {value = 5, min = 0, max = 12, text = "Shift Colors: ", w = 200, x = 150, y = 140, dragging = false, isLocked = false, isInt = true},
    }
   
    randomizeSliders()
    init()
end

function init()
    PALETTE, BACKGROUND_COLOR = Colors.getRandomPalette(sliders.monoColors.value, sliders.shiftColors.value)
    n = sliders.numBoids.value -- number of boids
    BOIDS = {}
    for _ = 1, n do
        local color = PALETTE[math.random(#PALETTE)]
        table.insert(BOIDS, Boid(color))
    end
end

function randomizeSliders()
    for key, slider in pairs(sliders) do
        if not slider.isLocked then  -- only randomize if not locked
            slider.value = math.random() * (slider.max - slider.min) + slider.min
            if slider.isInt then
                slider.value = math.floor(slider.value + 0.5)  -- round to nearest integer
            end
        end
    end 
end

function love.draw()
    -- background
    love.graphics.clear(unpack(BACKGROUND_COLOR))

    -- boids
    for i = 1, #BOIDS do
        BOIDS[i]:draw()
    end
    -- love.graphics.setColor(1, 1, 1, .1)
    -- love.graphics.circle("fill", BOIDS[1].pos.x, BOIDS[1].pos.y, BOIDS[1].perceptionRadius * 2, BOIDS[1].perceptionRadius * 2)
    
    -- sliders
    local mouseX, mouseY = love.mouse.getPosition()
    local opacity = computeOpacity(mouseX, mouseY, 400, 550)

    love.graphics.setColor(0, 0, 0, 0.5 * opacity)
    love.graphics.rectangle("fill", 0, 0, 380, 220)
    for key, slider in pairs(sliders) do
        love.graphics.setColor(1, 1, 1, opacity)
        love.graphics.print(slider.text .. string.format(slider.isInt and "%d" or "%.2f", slider.value), 10, slider.y)
        love.graphics.rectangle("line", slider.x, slider.y, slider.w, 10)
        local knobX = slider.x + (slider.value - slider.min) / (slider.max - slider.min) * slider.w
        love.graphics.rectangle("fill", knobX, slider.y, 10, 10)
        
        if slider.isLocked then
            -- draw locked icon (you might use an image or a simple rectangle as a placeholder)
            love.graphics.setColor(1, 0, 0, opacity)  -- red color for locked
        else
            -- draw unlocked icon
            love.graphics.setColor(0, 1, 0, opacity)  -- green color for unlocked
        end
        
        love.graphics.rectangle("fill", slider.x + slider.w + 10, slider.y, 10, 10)  -- example rectangle as a lock indicator
    end
end

function love.update(dt)
    if ISPAUSED then return end

    for i = 1, #BOIDS do
        BOIDS[i]:update(dt, BOIDS)
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
    end

    if key == "return" then
        init()
    end

    if key == "delete" then
        randomizeSliders()  
        init()
    end

    if key == "space" then
        ISPAUSED = not ISPAUSED
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        for _, slider in pairs(sliders) do
            local knobX = slider.x + (slider.value - slider.min) / (slider.max - slider.min) * slider.w
            if x > knobX and x < knobX + 10 and y > slider.y and y < slider.y + 10 then
                slider.dragging = not slider.isLocked
            end

            if x >= slider.x + slider.w + 10 and x <= slider.x + slider.w + 20 and 
               y >= slider.y and y <= slider.y + 10 then
                slider.isLocked = not slider.isLocked  -- toggle lock state
            end
        end
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    for _, slider in pairs(sliders) do
        if slider.dragging then
            slider.value = ((x - slider.x) / slider.w) * (slider.max - slider.min) + slider.min
            if slider.isInt then
                slider.value = math.floor(slider.value + 0.5)
            end
            slider.value = math.max(math.min(slider.value, slider.max), slider.min)
        end
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        for _, slider in pairs(sliders) do
            slider.dragging = false -- Stop dragging.
        end
    end
end

function computeOpacity(mouseX, mouseY, beginFadeDistance, endFadeDistance)
    local distanceToCorner = math.sqrt(mouseX^2 + mouseY^2)

    if distanceToCorner >= endFadeDistance then
        return 0
    elseif distanceToCorner <= beginFadeDistance then
        return 1
    else
        return (distanceToCorner - endFadeDistance) / (beginFadeDistance - endFadeDistance)
    end
end
