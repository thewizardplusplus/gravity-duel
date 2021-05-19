---
-- @module physics

local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")

local physics = {}

---
-- @tparam windfield.World world
-- @tparam "static"|"dynamic" kind
-- @tparam Rectangle rectangle
-- @treturn windfield.Collider
function physics.make_rectangle_collider(world, kind, rectangle)
  assert(type(world) == "table")
  assert(kind == "static" or kind == "dynamic")
  assert(typeutils.is_instance(rectangle, Rectangle))

  local collider = world:newRectangleCollider(
    rectangle.x,
    rectangle.y,
    rectangle.width,
    rectangle.height
  )
  collider:setType(kind)

  return collider
end

---
-- @tparam windfield.World world
-- @tparam "static"|"dynamic" kind
-- @tparam number x [0, ∞)
-- @tparam number y [0, ∞)
-- @tparam number radius [0, ∞)
-- @treturn windfield.Collider
function physics.make_circle_collider(world, kind, x, y, radius)
  assert(type(world) == "table")
  assert(kind == "static" or kind == "dynamic")
  assert(typeutils.is_positive_number(x))
  assert(typeutils.is_positive_number(y))
  assert(typeutils.is_positive_number(radius))

  local collider = world:newCircleCollider(x, y, radius)
  collider:setType(kind)

  return collider
end

return physics
