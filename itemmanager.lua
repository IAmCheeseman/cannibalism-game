local Item = require("item")

local itemManager = {}

local items = {}

function itemManager.define(id, heldObj, slotSprite, sprite, traits)
  local ssWidth, ssHeight = slotSprite:getDimensions()
  if ssWidth ~= 16 or ssHeight ~= 16 then
    error("slot sprite must be 16x16")
  end

  items[id] = {
    slotSprite = slotSprite,
    sprite = sprite,
    heldObj = heldObj,
    traits = traits,
  }
end

function itemManager.create(id)
  local itemData = items[id]
  return Item(id, itemData)
end

return itemManager
