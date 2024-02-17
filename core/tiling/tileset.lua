local cwd = (...):gsub("%.tiling.tileset$", "")
local class = require(cwd .. ".class")

local TileSet = class()

local globalTileIds = {}

function TileSet:init(path, tileWidth, tileHeight)
  self.tiles = {}

  self.tileWidth = tileWidth
  self.tileHeight = tileHeight

  self.offsetX = 0
  self.offsetY = 0

  self.image = love.graphics.newImage(path)

  local imageWidth, imageHeight = self.image:getDimensions()
  local xTiles, yTiles = imageWidth / tileWidth, imageHeight / tileHeight
  for bitMap=1, xTiles * yTiles do
    local x, y = (bitMap - 1) % xTiles, math.floor((bitMap - 1) / xTiles)

    table.insert(globalTileIds, {bitMap=bitMap, tileSet=self})
    self.tiles[bitMap] = {
      quad = love.graphics.newQuad(
        x * tileWidth, y * tileHeight,
        tileWidth, tileHeight,
        imageWidth, imageHeight),
      globalTileId = #globalTileIds
    }

    self.defaultTile = bitMap
  end
end

function TileSet:reset()
  self.batch:clear()
end

function TileSet:addTile(index, x, y)
  if not self.tiles[index] then
    error("Tile index '" .. tostring(index) .. "' does not exist")
  end
  self.batch:add(self.tiles[index].quad, x * self.tileWidth, y * self.tileHeight)
end

function TileSet:draw()
  love.graphics.draw(self.batch, self.offsetX, self.offsetY)
end

function TileSet:getAutotile(u, r, d, l, tl, tr, br, bl)
  local tile = 0
  if tl and u and l then tile = tile + 1 end
  if tr and u and r then tile = tile + 2 end
  if br and d and r then tile = tile + 4 end
  if bl and d and l then tile = tile + 8 end

  if tile == 0 then return nil end
  return self.tiles[tile].globalTileId, tile
end

function TileSet:getDefaultTile()
  return self.tiles[self.defaultTile].globalTileId
end

function TileSet.getGlobalTile(id)
  return globalTileIds[id]
end

return TileSet
