local cwd = (...):gsub("%.objs$", "")
local class = require(cwd .. ".class")

local objs = {}

local GameObj = class()
objs.GameObj = GameObj

function GameObj:__newindex(k, v)
  if type(v) == "table" and v.update and not v:isTypeOf(GameObj) then
    table.insert(self.children, v)
    self.children[v] = true
  end
  rawset(self, k, v)
end

function GameObj:init()
  self.zIndex = 0
  self.children = {}
end

function GameObj:updateChildren()
  for _, child in ipairs(self.children) do
    child:update()
  end
end

local WorldObj = class(GameObj)
objs.WorldObj = WorldObj

function WorldObj:init()
  self:base("init")

  self.x = 0
  self.y = 0
end

return objs
