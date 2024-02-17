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
core.viewport.setBgColor("default", 0, 0.25, 0.25, 1)
core.viewport.setBgColor("gui", 0, 0, 0, 0)

core.events.gui = core.Event()

physicsWorld = core.physics.PhysicsWorld(128, 128)
world = core.World(physicsWorld)

local Player = require("player")
local Book = require("book")

local tileSet = require("core.tiling.tileset")("assets/grass.png", 16, 16)
local tileMap = require("core.tiling.tilemap")(128)

tileMap:addLayer("grass", -1)

tileMap:addTileSet(tileSet, "grass")

local positions = {}
local w = 100
for _=1, w*w/2 do
  local x = love.math.random(2, w)
  local y = love.math.random(2, w)
  table.insert(positions, x)
  table.insert(positions, y)
  tileMap:setCell(x, y, "grass")
end

for i=1, #positions, 2 do
  local x, y = positions[i], positions[i + 1]
  tileMap:updateAutotile(x, y, "grass")
end
layer = "stone"

function love.load()
  world:add(Player())
  world:add(Book())
end

function love.update()
  world:update()
end

function love.draw()
  core.viewport.drawTo("default", function()
    tileMap:draw()
    world:draw()
  end)

  core.viewport.drawTo("gui", function()
    core.events.gui:call()
    luiScene:render()
    love.graphics.print(love.timer.getFPS(), 0, 0)
  end)

  love.graphics.setColor(1, 1, 1, 1)
  core.viewport.draw("default")
  core.viewport.draw("gui")
end
