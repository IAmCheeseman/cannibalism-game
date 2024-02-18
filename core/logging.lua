local cwd = (...):gsub("%.logging$", ""):gsub("%.", "/")
local logging = {}

local loggingDirectory = "logs/"
local date = os.date("*t")
love.filesystem.createDirectory("logs")
local logFile = ("%s/%d-%d-%d_%d-%d.log"):format(loggingDirectory, date.year, date.month, date.day, date.hour, date.min)

local oldPrint = print

love.filesystem.write(logFile, "")

local thread = love.thread.newThread(cwd .. "/logger.lua")
thread:start(logFile)

function logging.addType(name)
  logging[name] = function(...)
    local message = table.concat({...}, "\t")
    local out = "[".. name .. "] " .. tostring(message)
    love.thread.getChannel("logger"):push(out)
    oldPrint(out)
  end
end

logging.addType("log")
logging.addType("error")
logging.addType("warning")
logging.addType("info")

print = logging.log

-- Remove old logs
local maxLogLifetime = 3600 * 24 * 5 -- 5 days

for _, file in ipairs(love.filesystem.getDirectoryItems(loggingDirectory)) do
  local path = loggingDirectory .. file
  local info = love.filesystem.getInfo(path)
  if info then
    local time = info.modtime or 0
    local currentTime = os.time()
    if currentTime - time > maxLogLifetime then
      logging.log("Removed log " .. path)
      love.filesystem.remove(path)
    end
  end
end


local utf8 = require("utf8")

-- Modified version of https://www.love2d.org/wiki/love.errorhandler
local function error_printer(msg, layer)
	logging.error(debug.traceback(tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", ""))
end

function love.errorhandler(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end

	love.graphics.reset()
	local font = love.graphics.setNewFont(14)

	love.graphics.setColor(1, 1, 1)

	local trace = debug.traceback()

	love.graphics.origin()

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	local err = {}

	table.insert(err, "Error\n")
	table.insert(err, sanitizedmsg)

	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

	table.insert(err, "\n")

	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")

	local function draw()
		if not love.graphics.isActive() then return end
		local pos = 70
		love.graphics.clear(0, 0, 0)
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.present()
	end

	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		p = p .. "\nCopied to clipboard!"
	end

  p = [[
Hooray! You got an error! Please follow these instructions:
Press 'O', which will open the logs folder.
Then send the most recent log file in my Discord server.
Press 'D' to copy the Discord link.

]] .. p

	if love.system then
		p = p .. "\n\nPress Ctrl+C or tap to copy this error, but please send the whole log file instead."
	end

	return function()
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
      elseif e == "keypressed" and a == "d" then
        love.system.setClipboardText("https://discord.gg/Rb9HbHDYXq")
        p = p .. "\nCopied Discord link!"
      elseif e == "keypressed" and a == "o" then
        love.system.openURL("file://" .. love.filesystem.getSaveDirectory() .. "/" .. loggingDirectory)
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end
end

return logging
