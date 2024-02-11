local cwd = (...):gsub("%.world$", "")
local class = require(cwd .. ".class")
local tablef = require(cwd .. ".tablef")

local World = class()

function World:init(physicsWorld)
  self.physicsWorld = physicsWorld

  self.objs = {}
  self.types = {}
  self.objData = {}
  self.addQueue = {}
  self.removeQueue = {}
end

function World:_flushQueues()
  for _, obj in ipairs(self.addQueue) do
    table.insert(self.objs, obj)
    local mt = getmetatable(obj)
    if not self.types[mt.__id] then
      self.types[mt.__id] = {}
    end
    table.insert(self.types[mt.__id], obj)

    self.objData[obj] = {
      index = #self.objs,
      typeIndex = #self.types[mt.__id]
    }
  end
  self.addQueue = {}

  for _, obj in ipairs(self.removeQueue) do
    local index = self.objData[obj].index
    local typeIndex = self.objData[obj].typeIndex
    tablef.swapRemove(self.objs, index)

    self.objData[obj] = nil
    local swapped = self.objs[index]
    if swapped then
      self.objData[swapped].index = index
    end

    local mt = getmetatable(obj)
    tablef.swapRemove(self.types[mt.__id], typeIndex)
    swapped = self.types[mt.__id][typeIndex]
    if swapped then
      self.objData[swapped].typeIndex = typeIndex
    end
  end
  self.removeQueue = {}
end

function World:iterateType(type)
  return ipairs(self.types[type.__id])
end

function World:update()
  self:_flushQueues()

  local dt = love.timer.getDelta()
  for _, obj in ipairs(self.objs) do
    if obj.update then
      obj:update(dt)
    end
  end
end

function World:draw()
  table.sort(self.objs, function(a, b)
    return a.zIndex < b.zIndex
  end)
  for i, obj in ipairs(self.objs) do
    obj.zIndex = i
    if obj.draw then
      obj:draw()
    end
  end

  self.physicsWorld:draw()
end

function World:add(obj)
  table.insert(self.addQueue, obj)
end

function World:remove(obj)
  table.insert(self.removeQueue, obj)
end

return World
