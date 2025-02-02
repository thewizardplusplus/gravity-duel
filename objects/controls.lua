-- luacheck: no max comment line length

---
-- @classmod Controls

local baton = require("baton")
local middleclass = require("middleclass")
local mlib = require("mlib")
local assertions = require("luatypechecks.assertions")
local json = require("luaserialization.json")
local Rectangle = require("models.rectangle")
local Ui = require("objects.ui")

local _MOVED_CONTROLS =
  {"moved_left", "moved_right", "moved_top", "moved_bottom"}

---
-- @table instance
-- @tfield gooi.component _position_joystick
-- @tfield gooi.component _direction_joystick
-- @tfield gooi.component _impulse_button
-- @tfield number _prev_player_angle [0, 2 * math.pi]
-- @tfield baton.Player _keys
-- @tfield func _impulse_handler func(): nil

local Controls = middleclass("Controls", Ui)

---
-- @function controls_schema
-- @static
-- @treturn tab JSON Schema for the controls
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Controls.static.controls_schema()
  local source_group = {
    type = "array",
    items = {
      type = "string",
      anyOf = {
        { pattern = "^key:[%w%p]+$" },
        { pattern = "^sc:[%w%p]+$" },
        { pattern = "^mouse:%d+$" },
        { pattern = "^axis:%w+[+-]$" },
        { pattern = "^button:%w+$" },
        { pattern = "^hat:%d+%a+$" },
      },
    },
    minItems = 1,
  }

  return {
    type = "object",
    properties = {
      moved_left = source_group,
      moved_right = source_group,
      moved_top = source_group,
      moved_bottom = source_group,
      rotated_left = source_group,
      rotated_right = source_group,
      impulse = source_group,
    },
    required = table.merge(_MOVED_CONTROLS, {
      "rotated_left",
      "rotated_right",
      "impulse",
    }),
  }
end

---
-- @function load_keys
-- @static
-- @tparam string controls_path
-- @treturn baton.Player
-- @error error message
function Controls.static.load_keys(controls_path)
  assertions.is_string(controls_path)

  local controls, err = json.load_from_json(
    controls_path,
    Controls.controls_schema(),
    nil,
    function(path)
      assertions.is_string(path)

      local data, err = love.filesystem.read(path)
      return data, data == nil and err or nil
    end
  )
  if not controls then
    return nil, "unable to load the controls: " .. err
  end

  return baton.new({ controls = controls, pairs = { moved = _MOVED_CONTROLS } })
end

---
-- @function new
-- @tparam Rectangle screen
-- @tparam string controls_path
-- @tparam func impulse_handler func(): nil
-- @treturn Controls
-- @raise error message
function Controls:initialize(screen, controls_path, impulse_handler)
  assertions.is_instance(screen, Rectangle)
  assertions.is_string(controls_path)
  assertions.is_function(impulse_handler)

  Ui.initialize(self, screen, function()
    if self:_is_impulse_allowed() then
      impulse_handler()
    end
  end)

  local keys, err = Controls.load_keys(controls_path)
  if not keys then
    error("unable to load the keys: " .. err)
  end

  self._keys = keys
  self._impulse_handler = impulse_handler
end

---
-- @function center_position
-- @treturn number x [0, ∞)
-- @treturn number y [0, ∞)

---
-- @treturn number x [-1, 1]
-- @treturn number y [-1, 1]
function Controls:player_move_direction()
  local player_move_direction = mlib.vec2.add(
    mlib.vec2.new(Ui.player_move_direction(self)),
    mlib.vec2.new(self._keys:get("moved"))
  )
  return player_move_direction.x, player_move_direction.y
end

---
-- @function update
function Controls:update()
  self._keys:update()
  if self._keys:pressed("impulse") and self:_is_impulse_allowed() then
    self._impulse_handler()
  end

  self._position_joystick:setEnabled(not self:_is_player_rotating())
  self._direction_joystick:setEnabled(not self:_is_player_moving())
  self._impulse_button:setEnabled(self:_is_impulse_allowed())
end

---
-- @treturn number [-math.pi, math.pi]
function Controls:player_angle_delta()
  local player_angle_delta = Ui.player_angle_delta(self)

  local player_keys_angle_factor = 0.6
  local dt = love.timer.getDelta()
  local player_keys_angle_delta = player_keys_angle_factor * dt
  if self._keys:down("rotated_left") then
    player_angle_delta = player_angle_delta - player_keys_angle_delta
  end
  if self._keys:down("rotated_right") then
    player_angle_delta = player_angle_delta + player_keys_angle_delta
  end

  return player_angle_delta
end

---
-- @function destroy

---
-- @treturn bool
function Controls:_is_player_moving()
  local player_move_direction_x, player_move_direction_y =
    self:player_move_direction()
  return player_move_direction_x ~= 0 or player_move_direction_y ~= 0
    or self._position_joystick.pressed
end

---
-- @treturn bool
function Controls:_is_player_rotating()
  return self:player_angle_delta() ~= 0 or self._direction_joystick.pressed
end

---
-- @treturn bool
function Controls:_is_impulse_allowed()
  return not (self:_is_player_moving() or self:_is_player_rotating())
end

return Controls
