local cwd = (...):gsub("%.objs$", "")
local class = require(cwd .. ".class")

local objs = {}

local GameObj = class()
objs.GameObj = GameObj

function GameObj:init()
  self.zIndex = 0
end

local WorldObj = class(GameObj)
objs.WorldObj = WorldObj

function WorldObj:init()
  self:base("init")

  self.x = 0
  self.y = 0
end

return objs
