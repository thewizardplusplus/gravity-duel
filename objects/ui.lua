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

local Ui = middleclass("Ui")

---
-- @function new
-- @tparam Rectangle screen
-- @tparam func impulse_handler func(): nil
-- @treturn Ui
function Ui:initialize(screen, impulse_handler)
  assert(typeutils.is_instance(screen, Rectangle))
  assert(typeutils.is_callable(impulse_handler))

  local grid_step = screen.height / 4
  local margin = grid_step / 4
  self._position_joystick = gooi.newJoy({
    x = screen.x + margin,
    y = screen.y + screen.height - grid_step - margin,
    size = grid_step,
  })
  self._direction_joystick = gooi.newJoy({
    x = screen.x + screen.width - grid_step - margin,
    y = screen.y + screen.height - grid_step - margin,
    size = grid_step,
  })
  self._direction_joystick:noSpring()

  self._impulse_button = gooi.newButton({
    text = "~~>",
    x = screen.x + screen.width - grid_step - margin,
    y = screen.y + screen.height - 1.625 * grid_step - margin,
    w = grid_step,
    h = grid_step / 2,
  })
  self._impulse_button:onPress(impulse_handler)
end

---
-- @function destroy
function Ui:destroy()
  gooi.removeComponent(self._position_joystick)
  gooi.removeComponent(self._direction_joystick)
  gooi.removeComponent(self._impulse_button)
end

return Ui
