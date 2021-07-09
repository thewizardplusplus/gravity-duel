---
-- @classmod Ui

local middleclass = require("middleclass")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")

---
-- @table instance
-- @tfield gooi.component _position_joystick
-- @tfield gooi.component _direction_joystick
-- @tfield gooi.component _impulse_button
-- @tfield number _prev_player_angle [0, 2 * math.pi]

local Ui = middleclass("Ui")

---
-- @function new
-- @tparam Rectangle screen
-- @tparam func impulse_handler func(): nil
-- @treturn Ui
function Ui:initialize(screen, impulse_handler)
  assert(typeutils.is_instance(screen, Rectangle))
  assert(typeutils.is_callable(impulse_handler))

  local screen_maximum_x, screen_maximum_y = screen:maximum()
  local margin = screen:ui_grid_step() / 4
  self._position_joystick = gooi.newJoy({
    x = screen.x + margin,
    y = screen_maximum_y - screen:ui_grid_step() - margin,
    size = screen:ui_grid_step(),
  })
  self._position_joystick:opacity(0.5)

  self._direction_joystick = gooi.newJoy({
    x = screen_maximum_x - screen:ui_grid_step() - margin,
    y = screen_maximum_y - screen:ui_grid_step() - margin,
    size = screen:ui_grid_step(),
  })
  self._direction_joystick:opacity(0.5)
  self._direction_joystick:noSpring()

  self._impulse_button = gooi.newButton({
    text = "~~>",
    x = screen_maximum_x - screen:ui_grid_step() - margin,
    y = screen_maximum_y - 1.625 * screen:ui_grid_step() - margin,
    w = screen:ui_grid_step(),
    h = screen:ui_grid_step() / 2,
  })
  self._impulse_button:opacity(0.5)
  self._impulse_button:onPress(impulse_handler)

  self._prev_player_angle = 0
end

---
-- @treturn number x [0, ∞)
-- @treturn number y [0, ∞)
function Ui:center_position()
  local x = (self._position_joystick.x + self._direction_joystick.x) / 2
    + self._position_joystick.w / 2
  local y = self._position_joystick.y + self._position_joystick.h / 2
  return x, y
end

---
-- @treturn number x [-1, 1]
-- @treturn number y [-1, 1]
function Ui:player_move_direction()
  return self._position_joystick:xValue(), self._position_joystick:yValue()
end

---
-- @treturn number [-math.pi, math.pi]
function Ui:player_angle_delta()
  local player_direction_x, player_direction_y =
    self._direction_joystick:xValue(), self._direction_joystick:yValue()
  if player_direction_x == 0 and player_direction_y == 0 then
    return 0
  end

  local player_angle = math.atan2(player_direction_y, player_direction_x)
  if player_angle < 0 then
    player_angle = 2 * math.pi + player_angle
  end

  local player_angle_delta = player_angle - self._prev_player_angle
  if math.abs(player_angle_delta) > math.pi then
    local player_angle_delta_sign = player_angle_delta > 0 and 1 or -1
    player_angle_delta =
      player_angle_delta_sign * (2 * math.pi - math.abs(player_angle_delta))
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
