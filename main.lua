love.graphics.setDefaultFilter("nearest", "nearest")

core = require("core")
core.defineLoveEvents()
class = core.class
WorldObj = core.WorldObj

local LUI = require("lib.LUI")

luiScene = LUI.Scene()

-- 16:9
local screenWidth, screenHeight = 256, 144

core.input.addKey("up", "w")
core.input.addKey("left", "a")
core.input.addKey("down", "s")
core.input.addKey("right", "d")
core.input.addKey("toggleBook", "tab")
core.input.addMouse("useWeapon", 1)
core.input.addMouse("useTome", 2)

core.viewport.new("default", screenWidth, screenHeight)
core.viewport.new("gui",     screenWidth, screenHeight)
core.viewport.setBgColor("default", 0, 0, 0, 1)
core.viewport.setBgColor("gui", 0, 0, 0, 0)

core.events.gui = core.Event()

physicsWorld = core.physics.PhysicsWorld(128, 128)
world = core.World(physicsWorld)

local Player = require("player")
local Book = require("book")

local grassTs = core.TileSet("assets/grass.png", 16, 16)
local sandTs = core.TileSet("assets/sand.png", 16, 16)
local tileMap = core.TileMap(128)

tileMap:addLayer("grass", -1)
tileMap:addTileSet(grassTs, "grass")
tileMap:addLayer("sand", 1)
tileMap:addTileSet(sandTs, "sand")

local positions = {}
local w = 128
for _=1, w*w/2 do
  local x = love.math.random(2, w)
  local y = love.math.random(2, w)
  table.insert(positions, x)
  table.insert(positions, y)
  if love.math.random() < 0.5 then
    tileMap:setCell(x, y, "grass")
  end
  if love.math.random() < 0.5 then
    tileMap:setCell(x, y, "sand")
  end
end

for i=1, #positions, 2 do
  local x, y = positions[i], positions[i + 1]
  tileMap:updateAutotile(x, y, "grass")
  tileMap:updateAutotile(x, y, "sand")
end

core.events.keypressed:on(function(key, _, _)
  if key == "f1" then
    core.physics.PhysicsWorld.drawShapes = not core.physics.PhysicsWorld.drawShapes
  end
end)

core.events.focus:on(function(isFocused)
  if isFocused then
    core.shader.reloadAll()
  end
end)

local player
local time = 0

function love.load()
  core.init("Emotional Game", "0.1.0")

  player = Player()
  world:add(player)
  world:add(Book())
end

function love.update(dt)
  time = time + dt
  local b = (math.sin(time / 12) + 1) / 2 - 0.1
  core.lighting.ambientColor.r = b
  core.lighting.ambientColor.g = b
  core.lighting.ambientColor.b = b

  world:update()
end

function love.draw()
  core.viewport.drawTo("default", function()
    love.graphics.setColor(love.math.colorFromBytes(99, 155, 255))
    local camx, camy = core.viewport.getCameraPos("default")
    love.graphics.rectangle("fill", camx - 1, camy - 1, screenWidth + 2, screenHeight + 2)
    love.graphics.setColor(1, 1, 1)
    tileMap:draw()
    world:draw()
  end)

  core.viewport.drawTo("gui", function()
    core.events.gui:call()
    luiScene:render()
    love.graphics.print(
      tostring(core.math.snapped(1 / love.timer.getFPS() * 1000, 0.01)) .. "/16 ms",
      0, 0)
  end)

  love.graphics.setColor(1, 1, 1, 1)
  core.lighting.drawToViewport("default")
  core.viewport.draw("gui")
end
