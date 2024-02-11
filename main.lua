love.graphics.setDefaultFilter("nearest", "nearest")

core = require("core")
core.event.defineLoveEvents()
class = core.class
WorldObj = core.WorldObj

local LUI = require("lib.LUI")

luiScene = LUI.Scene()

-- 16:9
local screenWidth, screenHeight = 256, 144

core.input.addKey("up", "w")
core.input.addKey("left", "a")
core.input.addKey("down", "s")
core.input.addKey("right", "d")
core.input.addKey("toggleBook", "tab")
core.input.addMouse("useWeapon", 1)
core.input.addMouse("useTome", 2)

core.viewport.new("default", screenWidth, screenHeight)
core.viewport.new("gui",     screenWidth, screenHeight)
core.viewport.setBgColor("default", 0, 0.25, 0.25, 1)
core.viewport.setBgColor("gui", 0, 0, 0, 0)

core.event.define("gui")

physicsWorld = core.physics.PhysicsWorld(128, 128)
world = core.World(physicsWorld)

local Player = require("player")
local Book = require("book")

function love.load()
  world:add(Player())
  world:add(Book())
end

function love.update()
  world:update()
end

function love.draw()
  core.viewport.drawTo("default", function()
    love.graphics.setColor(1, 0, 0.5)
    love.graphics.circle("fill", 0, 0, 16)
    world:draw()
  end)

  core.viewport.drawTo("gui", function()
    core.event.call("gui")
    luiScene:render()
  end)

  love.graphics.setColor(1, 1, 1, 1)
  core.viewport.draw("default")
  core.viewport.draw("gui")
end
