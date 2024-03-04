love.graphics.setDefaultFilter("nearest", "nearest")

core = require("core")
core.defineLoveEvents()
class = core.class
GameObj = core.GameObj
WorldObj = core.WorldObj

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

physicsWorld = core.physics.PhysicsWorld(128, 512 * 2)
world = core.World(physicsWorld)

local worldGen = require("worldgen")

local Player = require("player")
local Cursor = require("cursor")
local Tree = require("tree")

local grassTs = core.TileSet("assets/grass.png", 16, 16)
local sandTs = core.TileSet("assets/sand.png", 16, 16)
local deepGrassTs = core.TileSet("assets/darkgrass.png", 16, 16)

local deepGrassLayer = core.TileLayer(512, 512)
deepGrassLayer:addTileSet(deepGrassTs)
deepGrassLayer.zIndex = -102
local grassLayer = core.TileLayer(512, 512)
grassLayer:addTileSet(grassTs)
grassLayer.zIndex = -101
local sandLayer = core.TileLayer(512, 512)
sandLayer:addTileSet(sandTs)
sandLayer.zIndex = -100

world:add(grassLayer)
world:add(deepGrassLayer)
world:add(sandLayer)

worldGen.addIsland("grassland", {
  x = 2, y = 2,
  size = 256,

  grassTile = "grass",
  grassCallback = function(x, y)
    grassLayer:setCell(x, y, grassTs)
    love.graphics.setColor(0, 1, 0)
    love.graphics.points(x, y)
  end,
  sandTile = "sand",
  sandCallback = function(x, y)
    sandLayer:setCell(x, y, sandTs)
    love.graphics.setColor(1, 1, 0)
    love.graphics.points(x, y)
  end,
  altBiomeTile = "deepGrass",
  altBiomeCallback = function(x, y)
    deepGrassLayer:setCell(x, y, deepGrassTs)
    love.graphics.setColor(0, 0.5, 0)
    love.graphics.points(x, y)

    if love.math.random() < 0.33 then
      local tree = Tree(
        x * 16 + love.math.random() * 8,
        y * 16 + love.math.random() * 8)
      world:add(tree)
    end
  end,

  -- tileCallback = function(x, y)
  --   deepGrassLayer:autotile(x, y)
  --   grassLayer:autotile(x, y)
  --   sandLayer:autotile(x, y)
  -- end,
})

local map = love.graphics.newCanvas(512, 512)

love.graphics.setCanvas(map)

worldGen.initializeWorld(world, 512, 512)
local generated = worldGen.generate()

for x=1, generated.width do
  for y=1, generated.height do
    if generated.map[x][y] ~= 0 then
      deepGrassLayer:autotile(x, y)
      grassLayer:autotile(x, y)
      sandLayer:autotile(x, y)
    end
  end
end

love.graphics.setCanvas()

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
  player.x = 64 * 16
  player.y = 64 * 16

  core.physics.PhysicsWorld.drawAround = player.body

  world:add(player)
  world:add(Cursor())
end

function love.update(dt)
  time = time + dt
  local b = core.math.map((math.sin(time / 12) + 1) / 2, 0, 0.9)
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
    world:draw()
  end)

  core.viewport.drawTo("gui", function()
    core.events.gui:call()
    core.events.guiAboveLui:call()

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
      tostring(core.math.snapped(1 / love.timer.getFPS() * 1000, 0.01)) .. "/16 ms",
      0, 0)

    local cx, cy = core.viewport.getCameraPos("default")
    local w, h = core.viewport.getSize("default")
    local wh = h
    cx, cy = (cx - w * 1.5) / 16, (cy - h * 1.5) / 16
    w, h = w / 4, h / 4
    local quad = love.graphics.newQuad(cx, cy, w, h, map:getDimensions())
    love.graphics.draw(map, quad, 0, wh - h)
    love.graphics.setColor(1, 0, 0)
    love.graphics.points(player.x / 16 - cx, wh - (player.y / 16 - cy))
  end)

  love.graphics.setColor(1, 1, 1, 1)
  core.lighting.drawToViewport("default")
  core.viewport.draw("gui")
end
