local cwd = (...):gsub("%.init$", "")

local core = {}

local objs = require(cwd .. ".objs")

core.assets       = require(cwd .. ".assets")
core.class        = require(cwd .. ".class")
core.event        = require(cwd .. ".event")
core.physics      = require(cwd .. ".physics")
core.table        = require(cwd .. ".tablef")
core.math         = require(cwd .. ".mathf")
core.viewport     = require(cwd .. ".viewport")
core.input        = require(cwd .. ".input")
core.logging      = require(cwd .. ".logging")
core.shader       = require(cwd .. ".shader")
core.Timer        = require(cwd .. ".timer")
core.StateMachine = require(cwd .. ".statemachine")
core.Sprite       = require(cwd .. ".sprite")
core.World        = require(cwd .. ".world")
core.Event        = require(cwd .. ".event")
core.TileSet      = require(cwd .. ".tiling.tileset")
core.TileMap      = require(cwd .. ".tiling.tilemap")
core.GameObj      = objs.GameObj
core.WorldObj     = objs.WorldObj

require(cwd .. ".stringf")

core.events = {}

function core.defineLoveEvents()
  local loveEvents = {
    "directorydropped", "displayrotated", "filedropped", "focus", "mousefocus",
    "resize", "visible", "keypressed", "keyreleased", "textedited", "textinput",
    "mousemoved", "mousepressed", "mousereleased", "wheelmoved", "gamepadaxis",
    "gamepadpressed", "gamepadreleased", "joystickadded", "joystickaxis",
    "joystickhat", "joystickpressed", "joystickreleased", "joystickremoved",
    "touchmoved", "touchpressed", "touchreleased"
  }

  for _, callback in ipairs(loveEvents) do
    core.events[callback] = core.Event()
    love[callback] = function(...)
      core.events[callback]:call(...)
    end
  end
end

function core.init()
  local name, version, _, device = love.graphics.getRendererInfo( )
  core.logging.info(name .. " " .. version)
  core.logging.info(device)
end

return core
