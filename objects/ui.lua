---
-- @classmod Ui

local middleclass = require("middleclass")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")
require("gooi")

---
-- @table instance
-- @tfield gooi.component _position_joystick
-- @tfield gooi.component _direction_joystick
-- @tfield gooi.component _impulse_button
-- @tfield number _prev_player_angle

local Ui = middleclass("Ui")

---
-- @function new
-- @tparam Rectangle screen
-- @tparam func impulse_handler func(): nil
-- @treturn Ui
function Ui:initialize(screen, impulse_handler)
  assert(typeutils.is_instance(screen, Rectangle))
  assert(typeutils.is_callable(impulse_handler))

  gooi.setStyle({font = love.graphics.newFont(screen:font_size())})

  local grid_step = screen.height / 4
  local margin = grid_step / 4
  self._position_joystick = gooi.newJoy({
    x = screen.x + margin,
    y = screen.y + screen.height - grid_step - margin,
    size = grid_step,
  })
  self._position_joystick:opacity(0.5)

  self._direction_joystick = gooi.newJoy({
    x = screen.x + screen.width - grid_step - margin,
    y = screen.y + screen.height - grid_step - margin,
    size = grid_step,
  })
  self._direction_joystick:opacity(0.5)
  self._direction_joystick:noSpring()

  self._impulse_button = gooi.newButton({
    text = "~~>",
    x = screen.x + screen.width - grid_step - margin,
    y = screen.y + screen.height - 1.625 * grid_step - margin,
    w = grid_step,
    h = grid_step / 2,
  })
  self._impulse_button:opacity(0.5)
  self._impulse_button:onPress(impulse_handler)

  self._prev_player_angle = 0
end

---
-- @treturn number x
-- @treturn number y
function Ui:center_position()
  local x = (self._position_joystick.x + self._direction_joystick.x) / 2
    + self._position_joystick.w / 2
  local y = self._position_joystick.y + self._position_joystick.h / 2
  return x, y
end

---
-- @treturn number x
-- @treturn number y
function Ui:player_position()
  return self._position_joystick:xValue(), self._position_joystick:yValue()
end

---
-- @treturn number
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
  return player_angle_delta
end

---
-- @function destroy
function Ui:destroy()
  gooi.removeComponent(self._position_joystick)
  gooi.removeComponent(self._direction_joystick)
  gooi.removeComponent(self._impulse_button)
end

return Ui
