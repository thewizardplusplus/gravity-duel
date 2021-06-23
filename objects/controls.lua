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
-- @tfield objects.Ui _ui
-- @tfield baton.Player _keys
-- @tfield func _impulse_handler func(): nil

local Controls = middleclass("Controls")

---
-- @function new
-- @tparam Rectangle screen
-- @tparam func impulse_handler func(): nil
-- @treturn Controls
function Controls:initialize(screen, impulse_handler)
  assert(typeutils.is_instance(screen, Rectangle))
  assert(typeutils.is_callable(impulse_handler))

  self._ui = Ui:new(screen, impulse_handler)
  self._impulse_handler = impulse_handler
end

---
-- @tparam string path
-- @error error message
function Controls:load_keys(path)
  assert(type(path) == "string")

  local keys, loading_err = _load_keys(path)
  if not keys then
    return nil, loading_err
  end

  self._keys = keys
  return true
end

---
-- @treturn number x [0, ∞)
-- @treturn number y [0, ∞)
function Controls:center_position()
  return self._ui:center_position()
end

---
-- @treturn number x [-1, 1]
-- @treturn number y [-1, 1]
function Controls:player_move_direction()
  local player_move_direction = mlib.vec2.add(
    mlib.vec2.new(self._ui:player_move_direction()),
    mlib.vec2.new(self._keys:get("moved"))
  )
  return player_move_direction.x, player_move_direction.y
end

---
-- @function update
function Controls:update()
  self._keys:update()

  local player_move_direction_x, player_move_direction_y =
    self:player_move_direction()
  if
    self._keys:pressed("impulse")
    and (player_move_direction_x == 0 and player_move_direction_y == 0)
    and self:player_angle_delta() == 0
  then
    self._impulse_handler()
  end
end

---
-- @treturn number [-math.pi, math.pi]
function Controls:player_angle_delta()
  local player_angle_delta = self._ui:player_angle_delta()

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
function Controls:destroy()
  self._ui:destroy()
end

return Controls
