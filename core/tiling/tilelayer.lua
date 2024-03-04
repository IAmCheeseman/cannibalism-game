local cwd = (...):gsub("%.tiling.tilelayer$", "")
local TileSet = require(cwd .. ".tiling.tileset")
local class = require(cwd .. ".class")
local objs = require(cwd .. ".objs")

local TileLayer = class(objs.WorldObj)

function TileLayer:init(width, height)
  self:base("init")

  self.tileSetIds = {}
  self.nextTileSetId = 1
  self.batches = {}
  self.width = width
  self.height = height

  self.map = {}
  for x=1, width do
    table.insert(self.map, {})
    for _=1, height do
      table.insert(self.map[x], 0)
    end
  end
end

function TileLayer:_ensureTileSetAdded(tileSet)
  if not self.tileSetIds[tileSet] then
    error("Tile set passed was not added to this layer.")
  end
end

function TileLayer:addTileSet(tileSet)
  self.tileSetIds[tileSet] = self.nextTileSetId
  self.batches[tileSet] = love.graphics.newSpriteBatch(tileSet.image)

  self.nextTileSetId = self.nextTileSetId + 1
end

-- Does NOT update the graphical appearance of the layer.
function TileLayer:setCell(x, y, tileSet)
  self:_ensureTileSetAdded(tileSet)
  if x - 1 < 1 or x > #self.map
  or y - 1 < 1 or y > #self.map[x] then
    error("x and/or y is out of bounds.")
  end

  local tile = tileSet:getDefaultTile()

  self.map[x][y] = tile
  self.map[x - 1][y] = tile
  self.map[x - 1][y - 1] = tile
  self.map[x][y - 1] = tile
end

function TileLayer:getCell(x, y)
  if x - 1 < 1 or x > #self.map
  or y - 1 < 1 or y > #self.map[x] then
    error("x and/or y is out of bounds.")
  end
  return self.map[x][y]
end

function TileLayer:_autotileCell(x, y)
  local tileData = TileSet.getGlobalTile(self.map[x][y])
  if not tileData then
    return
  end

  local tileSet = tileData.tileSet

  local u  = self:getCell(x, y - 1) ~= 0
  local r  = self:getCell(x + 1, y) ~= 0
  local d  = self:getCell(x, y + 1) ~= 0
  local l  = self:getCell(x - 1, y) ~= 0
  local tl = self:getCell(x - 1, y - 1) ~= 0
  local tr = self:getCell(x + 1, y - 1) ~= 0
  local br = self:getCell(x + 1, y + 1) ~= 0
  local bl = self:getCell(x - 1, y + 1) ~= 0

  local globalTileId, localTileId = tileSet:getAutotile(u, r, d, l, tl, tr, br, bl)
  if not globalTileId then
    globalTileId, localTileId = 0, 1
  end

  self.map[x][y] = globalTileId
  self.batches[tileSet]:add(
    tileSet.tiles[localTileId].quad,
    x * tileSet.tileWidth, y * tileSet.tileHeight)
end

function TileLayer:autotile(x, y)
  if x - 1 < 1 or x > #self.map
  or y - 1 < 1 or y > #self.map[x] then
    error("x and/or y is out of bounds.")
  end

  self:_autotileCell(x, y)
  self:_autotileCell(x - 1, y)
  self:_autotileCell(x - 1, y - 1)
  self:_autotileCell(x, y - 1)
end

function TileLayer:draw()
  for _, batch in pairs(self.batches) do
    love.graphics.draw(batch, self.x, self.y)
  end
end

return TileLayer
