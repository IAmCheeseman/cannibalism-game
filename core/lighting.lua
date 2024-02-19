local cwd = (...):gsub("%.lighting$", "")
local class = require(cwd .. ".class")
local objs = require(cwd .. ".objs")
local logging = require(cwd .. ".logging")
local viewport = require(cwd .. ".viewport")
local tablef = require(cwd .. ".tablef")
local shader = require(cwd .. ".shader")

local MAX_LIGHTS = 64
local lightingShader = shader.new("lighting", cwd:gsub("%.", "/") .. "/lighting.frag")

local lights = {}

local lighting = {
  ambientColor = {
    r = 1,
    g = 1,
    b = 1,
    a = 1
  },
  lightTint = 0.4,
}

local function addLight(light)
  if #lights > MAX_LIGHTS then
    logging.error("Cannot add another light. Max is 64.")
    return
  end
  table.insert(lights, light)
  light.index = #lights
end

local PointLight = class(objs.WorldObj)
lighting.PointLight = PointLight

function PointLight:init(x, y, radius, opts)
  self:base("init")

  self.x = x
  self.y = y
  self.radius = radius

  self.color = opts.color or {1, 1, 1, 1}
end

function PointLight:added(_)
  addLight(self)
end

function PointLight:removed(_)
  tablef.swapRemove(lights, self.index)
  local swapped = lights[self.index]
  if swapped then
    swapped.index = self.index
  end
end

function lighting.drawToViewport(viewportName)
  if #lights > 0 then
    local positions = {}
    local colors = {}
    local radii = {}
    local camx, camy = core.viewport.getCameraPos(viewportName)
    for i, light in ipairs(lights) do
      positions[i] = {light.x - camx, light.y - camy}
      colors[i] = light.color
      radii[i] = light.radius
    end

    lightingShader:sendUniform("lightPositions", unpack(positions))
    lightingShader:sendUniform("lightColors", unpack(colors))
    lightingShader:sendUniform("lightRadii", unpack(radii))
  end

  lightingShader:sendUniform("screenSize", {viewport.getSize(viewportName)})
  lightingShader:sendUniform("ambientLight", {
    lighting.ambientColor.r,
    lighting.ambientColor.g,
    lighting.ambientColor.b,
    lighting.ambientColor.a,
  })
  lightingShader:sendUniform("pointLightTint", lighting.lightTint)

  lightingShader:apply()
  viewport.draw(viewportName)
  lightingShader:stop()
end

return lighting
