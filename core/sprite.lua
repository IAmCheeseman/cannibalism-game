local cwd = (...):gsub("%.sprite$", "")
local class = require(cwd .. ".class")
local assets = require(cwd .. ".assets")

local testAnim = {
  xframes = 10,
  yframes = 3,
  animations = {
    run = {
      start = 1,
      stop = 10,
      fps = 10,
    },
    idle = {
      start = 11,
      stop = 14,
      fps = 10,
    }
  }
}

local Sprite = class()

function Sprite:init(path, animationConfig)
  self.image = assets.getCached(path)
  if not self.image then
    self.image = love.graphics.newImage(path)
    assets.cacheAsset(path, self.image)
  end

  if animationConfig then
    self:_setupAnimation(animationConfig)
  end

  self.offsetx, self.offsety = 0, 0
  local width, height = self.image:getDimensions()
  self.quad = love.graphics.newQuad(
    0, 0,
    width, height,
    width, height)
end

function Sprite:setOffsetPreset(x, y)
  local width, height
  if self.animations then
    local imageWidth, imageHeight = self.image:getDimensions()
    width, height = imageWidth / self.xframes, imageHeight / self.yframes
  else
    width, height = self.image:getDimensions()
  end

  if x == "left" then
    self.offsetx = 0
  elseif x == "center" then
    self.offsetx = width / 2
  elseif x == "right" then
    self.offsetx = width
  end

  if y == "top" then
    self.offsety = 0
  elseif y == "center" then
    self.offsety = height / 2
  elseif y == "bottom" then
    self.offsety = height
  end
end

function Sprite:setAnimOverCallback(bind, callback)
  self.animOver = callback
  self.animOverBind = bind
end

function Sprite:getDimensions()
  local width, height = self.image:getDimensions()
  return width / self.xframes, height / self.yframes
end

function Sprite:getWidth()
  local width, _ = self:getDimensions()
  return width
end

function Sprite:getHeight()
  local _, height = self:getDimensions()
  return height
end

function Sprite:_setupAnimation(animationConfig)
  self.xframes = animationConfig.xframes
  self.yframes = animationConfig.yframes

  self.animations = {}
  for k, animation in pairs(animationConfig.animations) do
    animation.run = 1/animation.fps * (animation.stop - animation.start)
    self.animations[k] = animation
    if not self.playing then
      self.playing = k
      self.previous = k
    end
  end

  self.frames = {}
  local width, height = self.image:getDimensions()
  local frameWidth, frameHeight = width / self.xframes, height / self.yframes
  for y=0, self.yframes-1 do
    for x=0, self.xframes-1 do
      table.insert(self.frames,
        love.graphics.newQuad(
          x * frameWidth, y * frameHeight,
          frameWidth, frameHeight,
          width, height))
    end
  end

  self.frame = 1
  self.time = 0
end

function Sprite:getAnimation(name)
  return self.animations[name]
end

function Sprite:play(name)
  if name == self.playing then
    return
  end
  self.previous = self.playing
  self.playing = name
end

function Sprite:update()
  if not self.animations then
    return
  end

  local dt = love.timer.getDelta()

  self.time = self.time + dt

  local animation = self.animations[self.playing]
  if self.time > 1 / animation.fps then
    self.frame = self.frame + 1
    self.time = 0

    if self.frame == animation.stop + 1 then
      if self.animOver then
        self.animOver(self.animOverBind, self, self.playing)
      end

      if animation.once then
        self:play(self.previous)
      end
    end
  end

  if self.frame < animation.start or self.frame > animation.stop then
    self.frame = animation.start
  end
end

function Sprite:draw(x, y, r, sx, sy, kx, ky)
  if not self.animations then
    love.graphics.draw(
      self.image,
      x, y, r, sx, sy, self.offsetx, self.offsety, kx, ky)
  else
    love.graphics.draw(
      self.image, self.frames[self.frame],
      x, y, r, sx, sy, self.offsetx, self.offsety, kx, ky)
  end
end

return Sprite
