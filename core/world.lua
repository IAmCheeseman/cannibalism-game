local cwd = (...):gsub("%.world$", "")
local class = require(cwd .. ".class")
local tablef = require(cwd .. ".tablef")
local Event = require(cwd .. ".event")

local World = class()

function World:init(physicsWorld)
  self.physicsWorld = physicsWorld

  self.objs = {}
  self.types = {}
  self.objData = {}
  self.addQueue = {}
  self.removeQueue = {}

  self.paused = false

  self.objectAdded = Event()
  self.objectRemoved = Event()
  self.updateEvent = Event()
  self.drawEvent = Event()
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

    if obj.added then
      obj:added(self)
    end

    self.objectAdded:call(obj)
  end
  self.addQueue = {}

  for _, obj in ipairs(self.removeQueue) do
    if self.objData[obj] then
      if obj.removed then
        obj:removed(self)
      end

      self.objectRemoved:call(obj)

      local index = self.objData[obj].index
      local typeIndex = self.objData[obj].typeIndex
      self.objData[obj] = nil

      tablef.swapRemove(self.objs, index)
      local swapped = self.objs[index]
      if swapped then
        self.objData[swapped].index = index
      end

      local mt = getmetatable(obj)
      local ofType = self.types[mt.__id]
      tablef.swapRemove(ofType, typeIndex)
      swapped = ofType[typeIndex]
      if swapped then
        self.objData[swapped].typeIndex = typeIndex
      end
    end
  end
  self.removeQueue = {}
end

function World:iterateType(type)
  local i = 0
  return function()
    i = i + 1
    if not self.types[type.__id] then
      return nil
    end

    return self.types[type.__id][i]
  end
end

function World:typeCount(type)
  return #self.types[type.__id] - 1
end

function World:update()
  if not self.paused then
    self.physicsWorld:update()
  end

  self:_flushQueues()

  local dt = love.timer.getDelta()
  self.updateEvent:call(dt)
  for _, obj in ipairs(self.objs) do
    local objPaused = self.paused and obj.pauses
    if obj.update and not objPaused then
      obj:update(dt)
    end
  end
end

function World:draw()
  table.sort(self.objs, function(a, b)
    return a.zIndex > b.zIndex
  end)

  for i, obj in ipairs(self.objs) do
    self.objData[obj].index = i
    if obj.draw then
      obj:draw()
    end
  end
  self.drawEvent:call()

  self.physicsWorld:draw()
end

function World:add(obj)
  table.insert(self.addQueue, obj)
end

function World:remove(obj)
  table.insert(self.removeQueue, obj)
end

function World:clear()
  for _, obj in ipairs(self.objs) do
    self:remove(obj)
  end

  collectgarbage()
  collectgarbage()
end

return World
