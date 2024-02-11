local cwd = (...):gsub("%.timer$", "")
local class = require(cwd .. ".class")

local Timer = class()

function Timer:init(totalTime)
  self.timeLeft = 0
  self.totalTime = totalTime
  self.isOver = true
  self.justFinished = false
end

function Timer:setCallback(callback)
  self.callback = callback
end

function Timer:start(newTime)
  self.totalTime = newTime or self.totalTime
  self.timeLeft = self.totalTime
  self.isOver = false
end

function Timer:percentageOver()
  return self.timeLeft / self.totalTime
end

function Timer:update()
  self.justFinished = false

  local dt = love.timer.getDelta()
  self.timeLeft = self.timeLeft - dt

  if self.timeLeft < 0 and not self.isOver then
    self.isOver = true
    self.justFinished = true
    if self.callback then
      self.callback()
    end
  end
end

return Timer

