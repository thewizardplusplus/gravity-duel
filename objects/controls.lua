---
-- @classmod Controls

local baton = require("baton")
local middleclass = require("middleclass")
local mlib = require("mlib")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")
local Ui = require("objects.ui")

local function _load_keys(path)
  assert(type(path) == "string")

  local data, loading_err = typeutils.load_json(path, {
    type = "object",
    properties = {
      moved_left = {["$ref"] = "#/definitions/source_group"},
      moved_right = {["$ref"] = "#/definitions/source_group"},
      moved_top = {["$ref"] = "#/definitions/source_group"},
      moved_bottom = {["$ref"] = "#/definitions/source_group"},
      rotated_left = {["$ref"] = "#/definitions/source_group"},
      rotated_right = {["$ref"] = "#/definitions/source_group"},
      impulse = {["$ref"] = "#/definitions/source_group"},
    },
    required = {
      "moved_left",
      "moved_right",
      "moved_top",
      "moved_bottom",
      "rotated_left",
      "rotated_right",
      "impulse",
    },
    definitions = {
      source_group = {
        type = "array",
        items = {type = "string", pattern = "^%a+:%w+$"},
        minItems = 1,
      },
    },
  })
  if not data then
    return nil, "unable to load the keys: " .. loading_err
  end

  return baton.new({
    controls = data,
    pairs = {
      moved = {"moved_left", "moved_right", "moved_top", "moved_bottom"},
    },
  })
end

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
-- @function new
-- @tparam Rectangle screen
-- @tparam string keys_config_path
-- @tparam func impulse_handler func(): nil
-- @treturn Controls
-- @raise error message
function Controls:initialize(screen, keys_config_path, impulse_handler)
  assert(typeutils.is_instance(screen, Rectangle))
  assert(type(keys_config_path) == "string")
  assert(typeutils.is_callable(impulse_handler))

  Ui.initialize(self, screen, function()
    if self:_impulse_allowed() then
      impulse_handler()
    end
  end)

  self._keys = assert(_load_keys(keys_config_path))
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
  if self._keys:pressed("impulse") and self:_impulse_allowed() then
    self._impulse_handler()
  end

  self._position_joystick:setEnabled(not self:_is_player_rotating())
  self._direction_joystick:setEnabled(not self:_is_player_moving())
  self._impulse_button:setEnabled(self:_impulse_allowed())
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
function Controls:_impulse_allowed()
  return not self:_is_player_moving() and not self:_is_player_rotating()
end

return Controls
