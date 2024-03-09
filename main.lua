love.graphics.setDefaultFilter("nearest", "nearest")

core = require("core")
core.defineLoveEvents()
class = core.class
GameObj = core.GameObj
WorldObj = core.WorldObj

core.physics.addCategory("default")
core.physics.addCategory("env")
core.physics.addCategory("entity")
core.physics.addCategory("enemy")
core.physics.addCategory("player")
core.physics.addCategory("hitbox")
core.physics.addCategory("hurtbox")

-- 16:9
-- local screenWidth, screenHeight = 256, 144
local screenWidth, screenHeight = 320, 180

core.input.addKey("up", "w")
core.input.addKey("left", "a")
core.input.addKey("down", "s")
core.input.addKey("right", "d")
core.input.addKey("toggleBook", "tab")
core.input.addMouse("useWeapon", 1)
core.input.addMouse("useTome", 2)

core.viewport.new("default", screenWidth, screenHeight, true)
core.viewport.new("gui",     screenWidth, screenHeight)
core.viewport.setBgColor("default", 0, 0, 0, 1)
core.viewport.setBgColor("gui", 0, 0, 0, 0)

core.events.gui = core.Event()
core.events.guiAboveLui = core.Event()

physicsWorld = core.physics.PhysicsWorld(0, 0)
world = core.World(physicsWorld)

local ui = require("ui")
local Enemy = require("enemy")
local openForest = require("forest")
local enemyCount = 3

world.objectRemoved:on(function()
  if world:typeCount(Enemy) == 0 then
    world:clear()
    enemyCount = math.ceil(enemyCount * 1.2)
    openForest(enemyCount)
  end
end)

function love.load()
  core.init("Emotional Game", "0.1.0")

  openForest(enemyCount)
end

local timer = 0

function love.update(dt)
  physicsWorld:update()

  timer = timer + dt

  local b = 0.9
  core.lighting.ambientColor.r = b
  core.lighting.ambientColor.g = b
  core.lighting.ambientColor.b = b

  world:update()
end

local function getTimerStr(time)
  local seconds = tostring(math.floor(time % 60))
  if #seconds == 1 then
    seconds = "0" .. seconds
  end
  local minutes = math.floor(time / 60)
  return ("%d:%s"):format(minutes, seconds)
end

function love.draw()
  core.viewport.drawTo("default", function()
    love.graphics.setColor(love.math.colorFromBytes(99, 155, 255))
    local camx, camy = core.viewport.getCameraPos("default")
    love.graphics.rectangle("fill", camx - 1, camy - 1, screenWidth + 2, screenHeight + 2)
    love.graphics.setColor(1, 1, 1)
    world:draw()
  end)

  core.viewport.drawTo("gui", function()
    love.graphics.setFont(ui.font)
    core.events.gui:call()
    core.events.guiAboveLui:call()

    love.graphics.setColor(1, 1, 1)

    local guiWidth, guiHeight = core.viewport.getSize("gui")
    local timerStr = getTimerStr(timer)
    love.graphics.print(timerStr, guiWidth - ui.font:getWidth(timerStr) - 1, 2)

    love.graphics.print(
      tostring(core.math.snapped(1 / love.timer.getFPS() * 1000, 0.01)) .. "/16 ms",
      0, guiHeight - ui.font:getHeight())
  end)

  love.graphics.setColor(1, 1, 1, 1)
  core.lighting.drawToViewport("default")
  core.viewport.draw("gui")
end

core.events.focus:on(function(isFocused)
  if isFocused then
    core.shader.reloadAll()
  end
end)

local fullscreen = false

core.events.keypressed:on(function(key, _, isRepeat)
  if key == "f1" then
    core.physics.draw = not core.physics.draw
  end

  if key == "f11" and not isRepeat then
    fullscreen = not fullscreen
    love.window.setFullscreen(fullscreen, "desktop")
  end

  if key == "escape" and not isRepeat then
    world.paused = not world.paused
  end
end)
