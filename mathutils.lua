---
-- @module mathutils

local mlib = require("mlib")
local typeutils = require("typeutils")
local Range = require("models.range")

local mathutils = {}

---
-- @tparam Range range
-- @treturn number [range.minimum, range.maximum)
function mathutils.random_in_range(range)
  assert(typeutils.is_instance(range, Range))

  return math.random() * (range.maximum - range.minimum) + range.minimum
end

---
-- @tparam number x
-- @tparam number y
-- @tparam number factor
-- @tparam[opt=true] bool with_time
-- @tparam[optchain=0] number offset_x
-- @tparam[optchain=0] number offset_y
-- @treturn number x
-- @treturn number y
function mathutils.transform_vector(
  x,
  y,
  factor,
  with_time,
  offset_x,
  offset_y
)
  with_time = with_time == nil and true or with_time
  offset_x = offset_x or 0
  offset_y = offset_y or 0

  assert(typeutils.is_number(x))
  assert(typeutils.is_number(y))
  assert(typeutils.is_number(factor))
  assert(type(with_time) == "boolean")
  assert(typeutils.is_number(offset_x))
  assert(typeutils.is_number(offset_y))

  if with_time then
    local dt = love.timer.getDelta()
    factor = factor * dt
  end

  local transformed_vector = mlib.vec2.add(
    mlib.vec2.mul(mlib.vec2.new(x, y), factor),
    mlib.vec2.new(offset_x, offset_y)
  )
  return transformed_vector.x, transformed_vector.y
end

return mathutils
