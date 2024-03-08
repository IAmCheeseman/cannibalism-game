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
local screenWidth, screenHeight = 256, 144
-- local screenWidth, screenHeight = 320, 180

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

local worldGen = require("worldgen")

local Player = require("player")
local Enemy = require("enemy")
local Cursor = require("cursor")
local Tree = require("tree")

local grassTs = core.TileSet("assets/grass.png", 16, 16)
local sandTs = core.TileSet("assets/sand.png", 16, 16)
local deepGrassTs = core.TileSet("assets/darkgrass.png", 16, 16)

local worldSize = 32

local deepGrassLayer = core.TileLayer(worldSize, worldSize)
deepGrassLayer:addTileSet(deepGrassTs)
deepGrassLayer.zIndex = 1000
local grassLayer = core.TileLayer(worldSize, worldSize)
grassLayer:addTileSet(grassTs)
grassLayer.zIndex = 1001
local sandLayer = core.TileLayer(worldSize, worldSize)
sandLayer:addTileSet(sandTs)
sandLayer.zIndex = 1002

world:add(grassLayer)
world:add(deepGrassLayer)
world:add(sandLayer)

worldGen.addIsland("grassland", {
  x = 2, y = 2,
  size = worldSize - 3,

  grassTile = "grass",
  grassCallback = function(x, y)
    grassLayer:setCell(x, y, grassTs)
    sandLayer:setCell(x, y, sandTs)
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
    grassLayer:setCell(x, y, grassTs)
    sandLayer:setCell(x, y, sandTs)
    love.graphics.setColor(0, 0.5, 0)
    love.graphics.points(x, y)

    if love.math.random() < 0.33 then
      local tree = Tree(
        x * 16 + love.math.random() * 8,
        y * 16 + love.math.random() * 8)
      world:add(tree)
    end
  end,

  emptyCallback = function(x, y)
    physicsWorld:newRectangleBody {
      x = x * 16,
      y = y * 16,
      type = "static",
      category = {"env"},
      mask = {},
      shape = {16, 16}
    }
  end,

  -- fullCallback = function(x, y)
  --   deepGrassLayer:autotile(x, y)
  --   grassLayer:autotile(x, y)
  --   sandLayer:autotile(x, y)
  -- end,
})

local map = love.graphics.newCanvas(worldSize)

love.graphics.setCanvas(map)

worldGen.initializeWorld(world, worldSize, worldSize)
local generated = worldGen.generate()

for x=1, generated.width do
  for y=1, generated.height do
    if generated.map[x][y] ~= 0 then
      deepGrassLayer:autotile(x, y)
      grassLayer:autotile(x, y)
      sandLayer:autotile(x, y)
    else
    end
  end
end

for _=4, 6 do
  local x, y = 1, 1
  while generated.map[x][y] == 0 do
    x = love.math.random(1, generated.width-1)
    y = love.math.random(1, generated.height-1)
  end

  local enemy = Enemy()
  enemy.x = x * 16
  enemy.y = y * 16
  world:add(enemy)
end

love.graphics.setCanvas()

core.events.keypressed:on(function(key, _, _)
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
  player.x = (worldSize / 2) * 16
  player.y = (worldSize / 2) * 16

  world:add(player)
  world:add(Cursor())
end

function love.update(dt)
  physicsWorld:update()

  time = time + dt
  local b = 0.9 --core.math.map((math.sin(time / 12) + 1) / 2, 0, 0.9)
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

    local _, guiHeight = core.viewport.getSize("gui")
    local font = love.graphics.getFont()
    love.graphics.print(
      tostring(core.math.snapped(1 / love.timer.getFPS() * 1000, 0.01)) .. "/16 ms",
      0, guiHeight - font:getHeight())
  end)

  love.graphics.setColor(1, 1, 1, 1)
  core.lighting.drawToViewport("default")
  core.viewport.draw("gui")
end

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
