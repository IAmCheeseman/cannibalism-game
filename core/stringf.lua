-- This is the only library we actually merge with the default lua one,
-- since you can call from that table direction on a string. For example:
-- ("abc"):sub(1, 2)

function string.get(string, index)
  return string.sub(string, index, index)
end
