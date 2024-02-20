local cwd = (...):gsub("%.point$", "")
local class = require(cwd .. ".class")
local objs = require(cwd .. ".objs")

local Point = class(objs.WorldObj)

function Point:init(x, y)
  self.x = x
  self.y = y
end

return Point
