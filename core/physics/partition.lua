local cwd = (...):gsub("%.physics.partition$", "")
local class = require(cwd .. ".class")
local tablef = require(cwd .. ".tablef")

local SpatialPartition = class()

local function hashVector(x, y)
  x = math.abs(x)
  y = math.abs(y)
  return x + y + ((x + 1) / 2)^2
end

function SpatialPartition:init(size, partitionCount)
  partitionCount = partitionCount or 32

  self.size = size or 64
  self.partitions = {}
  self.bodies = {}

  for _=1, partitionCount do
    table.insert(self.partitions, {})
  end
end

function SpatialPartition:getNeighbors(body)
  local ax, ay = body:getPosition()

  local neighbors = {}
  local added = {}

  local width   = self.size / 2 --body.shape.width
  local height  = self.size / 2 --body.shape.height

  local ox, oy = -1, -1
  for _=1, 9 do
    local index = self:findPartitionFor(ax + ox * width, ay + oy * height)
    if not added[index] then
      table.insert(neighbors, self.partitions[index])
    end
    added[index] = true

    ox = ox + 1
    if ox == 2 then
      ox = -1
      oy = oy + 1
    end
  end

  return neighbors
end

function SpatialPartition:findPartitionFor(bx, by)
  local x, y = math.floor(bx / self.size), math.floor(by / self.size)
  local hash = hashVector(x, y)
  return math.floor(hash % #self.partitions) + 1
end

function SpatialPartition:updateBody(body)
  local bodyIndex = self.bodies[body]
  local partition = self:findPartitionFor(body:getPosition())
  if partition == bodyIndex.partition then
    return
  end

  tablef.swapRemove(self.partitions[bodyIndex.partition], bodyIndex.index)
  local newBody = self.partitions[bodyIndex.partition][bodyIndex.index]
  if self.bodies[newBody] then
    self.bodies[newBody].index = bodyIndex.index
  end

  table.insert(self.partitions[partition], body)
  bodyIndex.partition = partition
  bodyIndex.index = #self.partitions[partition]
end

function SpatialPartition:addBody(body)
  local maxSize = self.size
  if body.shape.width > maxSize or body.shape.height > maxSize then
    error("Body's shape is too big! Max width/height is " .. maxSize)
  end
  local p = self:findPartitionFor(body:getPosition())
  table.insert(self.partitions[p], body)
  self.bodies[body] = {
    partition = p,
    index = #self.partitions[p]
  }
end

function SpatialPartition:removeBody(body)
  local bodyData  = self.bodies[body]
  local partition = self.partitions[bodyData.partition]
  local index = bodyData.index
  tablef.swapRemove(partition, index)
  local swapped = partition[index]
  if swapped then
    self.bodies[swapped].index = index
  end

  self.bodies[body] = nil
end

return SpatialPartition
