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
core.Timer        = require(cwd .. ".timer")
core.StateMachine = require(cwd .. ".statemachine")
core.Sprite       = require(cwd .. ".sprite")
core.World        = require(cwd .. ".world")
core.GameObj      = objs.GameObj
core.WorldObj     = objs.WorldObj

require(cwd .. ".stringf")

return core
