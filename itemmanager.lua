local Item = require("item")

local itemManager = {}

local items = {}

function itemManager.define(id, heldObj, slotSprite, sprite)
  items[id] = {
    slotSprite = slotSprite,
    sprite = sprite,
    heldObj = heldObj,
  }
end

function itemManager.create(id)
  local itemData = items[id]
  return Item(id, itemData.slotSprite, itemData.sprite)
end

return itemManager
