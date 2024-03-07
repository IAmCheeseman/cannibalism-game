local Ai = class()

function Ai:init(anchor)
  self.anchor = anchor
  self.velx, self.vely = 0, 0
end

function Ai:getVelocity()
  return self.velx, self.vely
end

return Ai
