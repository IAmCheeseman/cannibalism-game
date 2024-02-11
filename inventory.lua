local Inventory = class()

function Inventory:init(size)
  self.size = size
  self.items = {}
end

function Inventory:slotExists(at)
  return at > 0 and at <= self.size
end

function Inventory:isSlotEmpty(at)
  return self.items[at] ~= nil
end

function Inventory:ensureSlotIsValid(at)
  if not self:slotExists(at) then
    error("Slot '" .. at .. "' is invalid.")
  end
end

function Inventory:getItem(at)
  self:ensureSlotIsValid(at)
  return self.items[at]
end

function Inventory:setSlot(at, item)
  self:ensureSlotIsValid(at)
  self.items[at] = item
end

function Inventory:addItem(item)
  local index = 1
  while not self:isSlotEmpty(index) do
    index = index + 1
  end

  -- No space to add the item
  if not self:slotExists(index) then
    return false
  end

  self:setSlot(index, item)
  return true
end

return Inventory
