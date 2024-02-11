local keybinds = {}

local input = {}

function input.addKey(name, key)
  keybinds[name] = {key=key, type="key"}
end

function input.addMouse(name, button)
  keybinds[name] = {button=button, type="mouse"}
end

function input.isPressed(name)
  local bind = keybinds[name]
  if not bind then
    error("Keybind '" .. name .. "' does not exist.")
  end

  if bind.type == "key" then
    return love.keyboard.isDown(bind.key)
  elseif bind.type == "mouse" then
    return love.mouse.isDown(bind.button)
  end
end

return input
