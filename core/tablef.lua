local tablef = {}

function tablef.swapRemove(t, index)
  t[index] = t[#t]
  t[#t] = nil
end

function tablef.flatten(t)
  local new = {}
  for _, st in pairs(t) do
    for _, v in ipairs(st) do
      table.insert(new, v)
    end
  end
  return new
end

function tablef.copy(t)
  local copy = {}
  for k, v in pairs(t) do
    copy[k] = v
  end
  return copy
end

function tablef.deepCopy(t, levels)
  levels = levels or -1

  if levels == 0 then
    return t
  end

  local copy = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      copy[k] = tablef.deepCopy(v, levels - 1)
    else
      copy[k] = v
    end
  end
  return copy
end

function tablef.flush(t)
  return function()
    if #t == 0 then
      return nil
    end
    return #t, table.remove(t)
  end
end

function tablef.print(t, i)
  i = i or 1
  local lowerTab = ("\t"):rep(i - 1)
  local tabs = ("\t"):rep(i)
  print(lowerTab .. "{\n")
  for k, v in pairs(t) do
    if type(v) == "table" then
      io.write(tabs .. tostring(k) .. " = ")
      tablef.print(v)
    else
      io.write(tabs .. tostring(k) .. " = " .. tostring(v))
    end
  end
  io.write(lowerTab .. "}\n")
end

return tablef
