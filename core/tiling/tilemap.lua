local cwd = (...):gsub("%.tiling.tilemap$", "")
local TileSet = require(cwd .. ".tiling.tileset")
local class = require(cwd .. ".class")

local TileMap = class()

function TileMap:init(chunkSize)
  self.map = {}
  self.tileSets = {}

  for x=1, chunkSize do
    table.insert(self.map, {})
    for _=1, chunkSize do
      table.insert(self.map[x], 0)
    end
  end
end

function TileMap:addTileSet(tileSet, name)
  self.tileSets[name] = tileSet
end

function TileMap:getCell(x, y)
  if not self.map[x] or not self.map[x][y] then
    return 0
  end
  return self.map[x][y]
end

function TileMap:_updateAutotileAt(x, y)
  local tileSet = TileSet.getGlobalTile(self.map[x][y]).tileSet
  local u  = self:getCell(x, y - 1) ~= 0
  local r  = self:getCell(x + 1, y) ~= 0
  local d  = self:getCell(x, y + 1) ~= 0
  local l  = self:getCell(x - 1, y) ~= 0
  local tl = self:getCell(x - 1, y - 1) ~= 0
  local tr = self:getCell(x + 1, y - 1) ~= 0
  local br = self:getCell(x + 1, y + 1) ~= 0
  local bl = self:getCell(x - 1, y + 1) ~= 0

  local autotile = tileSet:getAutotile(u, r, d, l, tl, tr, br, bl) or 0
  self.map[x][y] = autotile
  tileSet:addTile(autotile, x, y)
end

function TileMap:updateAutotile(x, y)
  self:_updateAutotileAt(x, y)
  self:_updateAutotileAt(x - 1, y)
  self:_updateAutotileAt(x - 1, y - 1)
  self:_updateAutotileAt(x, y - 1)
end

function TileMap:_setCellAt(x, y, tileSet)
  local tile = tileSet:getDefaultTile()
  self.map[x][y] = tile
end

function TileMap:setCell(x, y, tileSetName)
  local tileSet = self.tileSets[tileSetName]
  self:_setCellAt(x, y, tileSet)
  self:_setCellAt(x - 1, y, tileSet)
  self:_setCellAt(x - 1, y - 1, tileSet)
  self:_setCellAt(x, y - 1, tileSet)
end

function TileMap:draw(x, y)
  for _, tileSet in pairs(self.tileSets) do
    tileSet:draw()
  end
end

return TileMap
