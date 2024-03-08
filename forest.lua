local Tree = require("tree")

local worldGen = require("worldgen")

local grassTs = core.TileSet("assets/grass.png", 16, 16)
local sandTs = core.TileSet("assets/sand.png", 16, 16)
local deepGrassTs = core.TileSet("assets/darkgrass.png", 16, 16)

local worldSize = 32

local deepGrassLayer
local grassLayer
local sandLayer

local collisions = {}

worldGen.addIsland("grassland", {
  x = 2, y = 2,
  size = worldSize - 3,

  grassTile = "grass",
  grassCallback = function(x, y)
    grassLayer:setCell(x, y, grassTs)
    sandLayer:setCell(x, y, sandTs)
  end,
  sandTile = "sand",
  sandCallback = function(x, y)
    sandLayer:setCell(x, y, sandTs)
  end,
  altBiomeTile = "deepGrass",
  altBiomeCallback = function(x, y)
    deepGrassLayer:setCell(x, y, deepGrassTs)
    grassLayer:setCell(x, y, grassTs)
    sandLayer:setCell(x, y, sandTs)

    if love.math.random() < 0.33 then
      local tree = Tree(
        x * 16 + love.math.random() * 8,
        y * 16 + love.math.random() * 8)
      world:add(tree)
    end
  end,

  emptyCallback = function(x, y)
    table.insert(collisions, physicsWorld:newRectangleBody {
      x = x * 16,
      y = y * 16,
      type = "static",
      category = {"env"},
      mask = {},
      shape = {16, 16}
    })
  end,
})

local function open(enemyCount)
  local Player = require("player")
  local Enemy = require("enemy")
  local Cursor = require("cursor")

  for _, collision in ipairs(collisions) do
    collision:destroy()
  end
  collisions = {}

  deepGrassLayer = core.TileLayer(worldSize, worldSize)
  deepGrassLayer:addTileSet(deepGrassTs)
  deepGrassLayer.zIndex = 1000

  grassLayer = core.TileLayer(worldSize, worldSize)
  grassLayer:addTileSet(grassTs)
  grassLayer.zIndex = 1001

  sandLayer = core.TileLayer(worldSize, worldSize)
  sandLayer:addTileSet(sandTs)
  sandLayer.zIndex = 1002

  worldGen.initializeWorld(world, worldSize, worldSize)
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

  for _=1, enemyCount do
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

  local player = Player()
  player.x = (worldSize / 2) * 16
  player.y = (worldSize / 2) * 16

  world:add(player)
  world:add(Cursor())

  world:add(grassLayer)
  world:add(deepGrassLayer)
  world:add(sandLayer)
end

return open
