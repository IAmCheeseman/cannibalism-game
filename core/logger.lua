local logFile = ...
local channel = "logger"

while true do
  local message = love.thread.getChannel(channel):pop()
  if message then
    local ok, error = love.filesystem.append(logFile, message .. "\n")
    if not ok then
      print(error)
    end
  end
end
