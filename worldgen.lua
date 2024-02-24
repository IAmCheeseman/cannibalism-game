local worldGen = {}

local islands = {}

local world = {}
local seed = -1

function worldGen.addIsland(name, opts)
  local island = {}

  island.name = name

  island.minWidth = opts.minWidth or 50
  island.minHeight = opts.minHeight or island.minWidth
  island.maxWidth = opts.maxWidth or 100
  island.maxHeight = opts.maxHeight or island.maxWidth

  island.seed = opts.setSeed or (seed + #islands * 100)

  island.biomes = {}

  islands[name] = island
  table.insert(islands, island)
end

function worldGen.addIslandBiome(islandName, noiseFn, generationFn)
  local island = islands[islandName]
  table.insert(island.biomes, {
    noiseFn = noiseFn,
    generationFn = generationFn,
  })
end

function worldGen.initializeWorld(width, height, setSeed)
  world.width = width
  world.height = height

  world.map = {}
  for x=1, world.width do
    table.insert(world.map, {})
    for _=1, world.height do
      table.insert(world.map[x], 0)
    end
  end

  seed = setSeed or love.math.random(999999)
end

return worldGen
