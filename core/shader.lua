local cwd = (...):gsub("%.shader$", "")
local class = require(cwd .. ".class")
local logging = require(cwd .. ".logging")

local shader = {}

local shaders = {}

local Shader = class()

function Shader:init(...)
  local args = {...}
  self.frag = args[1]
  self.vert = args[2]

  self.shader = love.graphics.newShader(...)
end

function Shader:apply()
  love.graphics.setShader(self.shader)
end

function Shader:stop()
  love.graphics.setShader()
end

function Shader:sendUniform(uniform, ...)
  if self.shader:hasUniform(uniform) then
    self.shader:send(uniform, ...)
  end
end

function Shader:reload()
  local ok, errMsg = pcall(function()
    self.shader = love.graphics.newShader(self.frag, self.vert)
  end)

  if not ok then
    logging.error(errMsg)
  end
end

function shader.new(name, ...)
  if shaders[name] then
    return shaders[name].shader
  else
    local newShader = Shader(...)
    shaders[name] = newShader
    return newShader
  end
end

function shader.reloadAll()
  for _, v in pairs(shaders) do
    v:reload()
  end
end

return shader
