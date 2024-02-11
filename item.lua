local Item = class(WorldObj)

function Item:init(id, slotSprite, sprite)
  local ssWidth, ssHeight = slotSprite:getDimensions()
  if ssWidth ~= 16 or ssHeight ~= 16 then
    error("slot sprite must be 16x16")
  end

  self.id = id
  self.slotSprite = slotSprite
  self.sprite = sprite
end

return Item
