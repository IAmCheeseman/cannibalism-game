local cwd = (...):gsub("%.assets$", "")

local assets = {}

local assetCache = {}

function assets.cacheAsset(path, value)
  assetCache[path] = value
end

function assets.getCached(path)
  return assetCache[path]
end

function assets.runScripts(dirPath)
  local files = love.filesystem.getDirectoryItems(dirPath)

  for _, fileName in ipairs(files) do
    local filePath = dirPath .. "/" .. fileName
    local info = love.filesystem.getInfo(filePath)
    if info then
      if info.type == "file" then
        if fileName:gmatch(".lua$") then
          require(filePath:gsub(".lua$", ""))
        end
      end
    end
  end
end

function assets.noise(w, h, scale, layers, layerDetail)
  scale = scale or 0.5
  layers = layers or 0
  layerDetail = layerDetail or 0.5
  local image = love.graphics.newCanvas(w, h)

  love.graphics.setCanvas(image)
  for x=0, w-1 do
    for y=0, h-1 do
      local n = love.math.noise(x * scale, y * scale)
      for i=1, layers do
        local detail = scale + layerDetail * i
        n = n + love.math.noise(x * detail, y * detail)
      end
      n = n / (layers + 1)
      love.graphics.setColor(n, n, n)
      love.graphics.points(x, y)
    end
  end
  love.graphics.setCanvas()

  return image
end

return assets

