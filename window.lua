---
-- @module window

local window = {}

---
-- @treturn bool always true
-- @error error message
function window.enter_fullscreen()
  local os = love.system.getOS()
  local is_mobile_os = table.find({"Android", "iOS"}, os)
  if not is_mobile_os then
    return true
  end

  local ok = love.window.setFullscreen(true, "desktop")
  if not ok then
    return nil, "unable to enter fullscreen"
  end

  return true
end

return window
