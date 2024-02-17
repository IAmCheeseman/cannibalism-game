local cwd = (...):gsub("%.tiling.tilemap$", "")
local TileSet = require(cwd .. ".tiling.tileset")
local class = require(cwd .. ".class")

local TileMap = class()

function TileMap:init(chunkSize)
  self.tileSets = {}
  self.chunkSize = chunkSize
  self.layers = {}
end

function TileMap:addTileSet(tileSet, name)
  self.tileSets[name] = tileSet

  for _, layerName in ipairs(self.layers) do
    local layer = self.layers[layerName]
    layer.batches[tileSet] = love.graphics.newSpriteBatch(tileSet.image)
  end
end

function TileMap:_makeLayerBatches()
  local batches = {}
  for _, tileSet in pairs(self.tileSets) do
    batches[tileSet] = love.graphics.newSpriteBatch(tileSet.image)
  end
  return batches
end

function TileMap:addLayer(name, position)
  if position < 0 then
    position = #self.layers - position + 1
  end
  table.insert(self.layers, position, name)
  local layer = {}
  for x=1, self.chunkSize do
    table.insert(layer, {})
    for _=1, self.chunkSize do
      table.insert(layer[x], 0)
    end
  end
  layer.batches = self:_makeLayerBatches()
  self.layers[name] = layer
end

function TileMap:hasLayer(layer)
  return self.layers[layer] ~= nil
end

function TileMap:_ensureLayerExists(layer)
  if not self:hasLayer(layer) then
    error("Layer '" .. tostring(layer) .. "' does not exist.")
  end
end

function TileMap:getCell(x, y, layerName)
  self:_ensureLayerExists(layerName)
  local layer = self.layers[layerName]
  if not layer[x] or not layer[x][y] then
    return 0
  end
  return layer[x][y]
end

function TileMap:_updateAutotileAt(x, y, layerName)
  local layer = self.layers[layerName]

  local tileSet = TileSet.getGlobalTile(layer[x][y]).tileSet
  local u  = self:getCell(x, y - 1, layerName) ~= 0
  local r  = self:getCell(x + 1, y, layerName) ~= 0
  local d  = self:getCell(x, y + 1, layerName) ~= 0
  local l  = self:getCell(x - 1, y, layerName) ~= 0
  local tl = self:getCell(x - 1, y - 1, layerName) ~= 0
  local tr = self:getCell(x + 1, y - 1, layerName) ~= 0
  local br = self:getCell(x + 1, y + 1, layerName) ~= 0
  local bl = self:getCell(x - 1, y + 1, layerName) ~= 0

  local autotile = tileSet:getAutotile(u, r, d, l, tl, tr, br, bl) or 0
  layer[x][y] = autotile
  layer.batches[tileSet]:add(
    tileSet.tiles[autotile].quad,
    x * tileSet.tileWidth, y * tileSet.tileHeight)
end

function TileMap:updateAutotile(x, y, layerName)
  if type(layerName) == "string" then -- Update specific layer
    self:_ensureLayerExists(layerName)
    self:_updateAutotileAt(x, y, layerName)
    self:_updateAutotileAt(x - 1, y, layerName)
    self:_updateAutotileAt(x - 1, y - 1, layerName)
    self:_updateAutotileAt(x, y - 1, layerName)
  elseif type(layerName) == "table" then -- Update specific layers
    for _, layer in ipairs(layerName) do
      self:_updateAutotileAt(x, y, layer)
      self:_updateAutotileAt(x - 1, y, layer)
      self:_updateAutotileAt(x - 1, y - 1, layer)
      self:_updateAutotileAt(x, y - 1, layer)
    end
  else -- Update all layers at x, y
    for layer, _ in pairs(self.layers) do
      self:_updateAutotileAt(x, y, layer)
      self:_updateAutotileAt(x - 1, y, layer)
      self:_updateAutotileAt(x - 1, y - 1, layer)
      self:_updateAutotileAt(x, y - 1, layer)
    end
  end
end

function TileMap:_setCellAt(x, y, tile, layer)
  layer[x][y] = tile
end

function TileMap:setCell(x, y, tileSetName, layerName)
  layerName = layerName or tileSetName
  self:_ensureLayerExists(layerName)
  local layer = self.layers[layerName]
  local tileSet = self.tileSets[tileSetName]
  local tile = tileSet:getDefaultTile()

  self:_setCellAt(x, y, tile, layer)
  self:_setCellAt(x - 1, y, tile, layer)
  self:_setCellAt(x - 1, y - 1, tile, layer)
  self:_setCellAt(x, y - 1, tile, layer)
end

function TileMap:draw(x, y)
  for _, layerName in ipairs(self.layers) do
    local layer = self.layers[layerName]
    for _, batch in pairs(layer.batches) do
      love.graphics.draw(batch, x, y)
    end
  end
end

return TileMap
