local cwd = (...):gsub("%.statemachine$", "")
local class = require(cwd .. ".class")

local StateMachine = class()

function StateMachine:init(obj)
  self.obj = obj
  self.states = {}
end

function StateMachine:addState(name, updateFunc, drawFunc, startFunc, endFunc)
  self.states[name] = {
    updateFunc = updateFunc,
    drawFunc = drawFunc,
    startFunc = startFunc,
    endFunc = endFunc
  }
  return self
end

function StateMachine:setCurrent(name)
  if not self.states[name] then
    error("State '" .. name "' not added to this state machine.")
  end

  if self.current and self.states[self.current].endFunc then
    self.states[self.current].endFunc(self.obj)
  end
  self.current = name
  if self.states[self.current].startFunc then
    self.states[self.current].startFunc(self.obj)
  end

  return self
end

function StateMachine:getCurrent()
  return self.current
end

function StateMachine:update()
  if not self.current then
    error("State not yet set.")
  end

  if self.states[self.current].updateFunc then
    self.states[self.current].updateFunc(self.obj, love.timer.getDelta())
  end
end

function StateMachine:draw()
  if not self.current then
    error("State not yet set.")
  end

  if self.states[self.current].drawFunc then
    self.states[self.current].drawFunc(self.obj)
  end
end

return StateMachine
