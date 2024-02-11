
local PATH = (...):gsub('%.init$', '')

local LUI = {}


LUI.Element = require(PATH .. ".element_class")
LUI.Scene = require(PATH .. ".scene")


return LUI

