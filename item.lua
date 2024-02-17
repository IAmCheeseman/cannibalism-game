local Item = class(WorldObj)

function Item:init(id, item)
  self.id = id
  self.slotSprite = item.slotSprite
  self.sprite = item.sprite

  for k, v in pairs(item.traits) do
    self[k] = v
  end
end

return Item
