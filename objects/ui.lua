---
-- @classmod Ui

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Vector2D = require("luamath.vector2d")
local Size = require("luamath.models.size")
local mathutils = require("luamath.utils")
local Rectangle = require("models.rectangle")
local icons = require("constants.icons")

local Ui = middleclass("Ui")

---
-- @table instance
-- @tfield gooi.component _position_joystick
-- @tfield gooi.component _direction_joystick
-- @tfield gooi.component _impulse_button
-- @tfield number _prev_player_angle [0, 2 * math.pi]

---
-- @function new
-- @tparam Rectangle screen
-- @tparam {[string]=Font,...} fonts
-- @tparam func impulse_handler func(): nil
-- @treturn Ui
function Ui:initialize(screen, fonts, impulse_handler)
  assertions.is_instance(screen, Rectangle)
  assertions.is_table(fonts, checks.is_string, function(font)
    return type(font) == "userdata"
  end)
  assertions.is_function(impulse_handler)

  local margin = screen:ui_grid_step() / 4
  self._position_joystick = gooi.newJoy({
    x = screen.min.x + margin,
    y = screen.max.y - screen:ui_grid_step() - margin,
    size = screen:ui_grid_step(),
  })
  self._position_joystick:opacity(0.5)

  self._direction_joystick = gooi.newJoy({
    x = screen.max.x - screen:ui_grid_step() - margin,
    y = screen.max.y - screen:ui_grid_step() - margin,
    size = screen:ui_grid_step(),
  })
  self._direction_joystick:opacity(0.5)
  self._direction_joystick:noSpring()

  local button_size = Size:new(screen:ui_grid_step(), screen:ui_grid_step() / 2)
  self._impulse_button = gooi.newButton({
    text = icons.IMPULSE_ICON,
    x = screen.max.x - screen:ui_grid_step() - margin,
    y = screen.max.y - 1.625 * screen:ui_grid_step() - margin,
    w = button_size.width, h = button_size.height,
  })
  self._impulse_button:setStyle({ font = fonts.icons })
  -- restore the size after applying the font
  self._impulse_button:setBounds(
    nil,
    nil,
    button_size.width,
    button_size.height
  )
  self._impulse_button:opacity(0.5)
  self._impulse_button:onPress(impulse_handler)

  self._prev_player_angle = 0
end

---
-- @treturn Vector2D
function Ui:center_position()
  return Vector2D:new(
    (self._position_joystick.x + self._direction_joystick.x) / 2
      + self._position_joystick.w / 2,
    self._position_joystick.y + self._position_joystick.h / 2
  )
end

---
-- @treturn Vector2D
function Ui:player_move_direction()
  return Vector2D:new(
    self._position_joystick:xValue(),
    self._position_joystick:yValue()
  )
end

---
-- @treturn number [-math.pi, math.pi]
function Ui:player_angle_delta()
  local player_direction = Vector2D:new(
    self._direction_joystick:xValue(),
    self._direction_joystick:yValue()
  )
  if player_direction == Vector2D.ZERO then
    return 0
  end

  local player_angle = math.atan2(player_direction.y, player_direction.x)
  if player_angle < 0 then
    player_angle = 2 * math.pi + player_angle
  end

  local player_angle_delta = player_angle - self._prev_player_angle
  if math.abs(player_angle_delta) > math.pi then
    player_angle_delta =
      mathutils.sign(player_angle_delta)
      * (2 * math.pi - math.abs(player_angle_delta))
  end

  self._prev_player_angle = player_angle

  local player_angle_delta_factor = 0.25
  return player_angle_delta_factor * player_angle_delta
end

---
-- @function destroy
function Ui:destroy()
  gooi.removeComponent(self._position_joystick)
  gooi.removeComponent(self._direction_joystick)
  gooi.removeComponent(self._impulse_button)
end

return Ui
