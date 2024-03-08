local worldGen = {}

local islands = {}

local world = {}
local seed = -1

function worldGen.addIsland(name, opts)
  local island = {}

  island.name = name

  island.x = opts.x
  island.y = opts.y
  island.width = opts.width or opts.size
  island.height = opts.height or island.width

  island.grassTile = opts.grassTile
  island.grassLayer = opts.grassLayer or opts.grassTile
  island.sandTile = opts.sandTile
  island.sandLayer = opts.sandLayer or opts.sandTile
  island.altBiomeTile = opts.altBiomeTile
  island.altBiomeLayer = opts.altBiomeLayer or opts.altBiomeTile

  island.grassCallback = opts.grassCallback
  island.sandCallback = opts.sandCallback
  island.altBiomeCallback = opts.altBiomeCallback

  island.seed = opts.setSeed or (seed + #islands * 100)

  island.biomes = {}

  islands[name] = island
  table.insert(islands, island)
end

function worldGen.reset()
  world = {}
  islands = {}
end

function worldGen.addIslandBiome(islandName, noiseFn, generationFn)
  local island = islands[islandName]
  table.insert(island.biomes, {
    noiseFn = noiseFn,
    generationFn = generationFn,
  })
end

function worldGen.initializeWorld(objWorld, width, height, setSeed)
  world.width = width
  world.height = height
  world.objWorld = objWorld

  world.map = {}
  for x=1, world.width do
    table.insert(world.map, {})
    for _=1, world.height do
      table.insert(world.map[x], 0)
    end
  end

  seed = setSeed or love.math.random(999999)
end

local lakeCount = 0

local function setCircle(t, x, y, radius)
  for cx=-radius, radius do
    for cy=-radius, radius do
      local dx, dy = x + cx, y + cy
      local dist = core.math.distanceBetween(dx, dy, x, y)
      local angle = core.math.angle(cx, cy)
      local n = core.math.noise(angle * 20, 0, 0.75, 0.05, 8, 0.5, 2, seed + lakeCount * 50)
      local minDist = radius - n * 16
      if dist < minDist
      and dx > 1 and dy > 1
      and dx < #world.map and dy < #world.map[dx]
      and world.map[dx][dy] ~= 0 then
        world.map[dx][dy] = t or 0
      end
    end
  end
end

local function generateIsland(island)
  for x=1, island.width do
    for y=1, island.height do
      local dx, dy = x + island.x, y + island.y
      local px, py = x / island.width, y / island.height
      local n = core.math.noise(x, y, 0.4, 0.025, 8, 0.75, 7, seed)
      local strength = math.sin(math.pi * px) * math.sin(math.pi * py)
      n = n * strength

      if n > 0.15 then
        world.map[dx][dy] = island.sandTile
        love.graphics.setColor(1, 1, 0)
      else
        love.graphics.setColor(0, 0, 1 * n * 4)
      end
      if n > 0.3 then
        local bn = core.math.noise(x, y, 0.45, 0.03, 5, 0.55, 2, seed + 100)
        if bn < 0.5 then
          world.map[dx][dy] = island.grassTile
        love.graphics.setColor(0, 1, 0)
        else
          world.map[dx][dy] = island.altBiomeTile
        love.graphics.setColor(0, 0.5, 0)
        end
      end
      love.graphics.points(x, y)
    end
  end

  for _=1, 20 do
    local x = love.math.random(island.x, island.x + island.width)
    local y = love.math.random(island.y, island.y + island.height)
    local radius = love.math.random(3, 6)
    setCircle(island.sandTile, x, y, radius)
    setCircle(nil, x, y, math.floor(radius * 0.9))

    lakeCount = lakeCount + 1
  end

  for x=island.x, island.width do
    for y=island.y, island.height do
      local tile = world.map[x][y]

      if tile == island.grassTile then
        core.try(island.grassCallback, x, y)
      elseif tile == island.altBiomeTile then
        core.try(island.altBiomeCallback, x, y)
      elseif tile == island.sandTile then
        core.try(island.sandCallback, x, y)
      end

      core.try(island.tileCallback, x, y)
    end
  end
end

function worldGen.generate()
  local start = os.clock()
  for _, island in ipairs(islands) do
    generateIsland(island)
  end
  print("World gen took " .. tostring((os.clock() - start) * 1000) .. " ms")
  return world
end

return worldGen
