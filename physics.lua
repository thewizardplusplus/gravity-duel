---
-- @module physics

local assertions = require("luatypechecks.assertions")
local BoundingBox = require("luamath.models.boundingbox")
local Circle = require("models.circle")

local physics = {}

---
-- @tparam windfield.World world
-- @tparam "static"|"dynamic" kind
-- @tparam BoundingBox rectangle
-- @treturn windfield.Collider
function physics.make_rectangle_collider(world, kind, rectangle)
  assertions.is_table(world)
  assertions.is_enumeration(kind, {"static", "dynamic"})
  assertions.is_instance(rectangle, BoundingBox)

  local position = rectangle:position()
  local size = rectangle:size()
  local collider = world:newRectangleCollider(
    position.x,
    position.y,
    size.width,
    size.height
  )
  collider:setType(kind)

  return collider
end

---
-- @tparam windfield.World world
-- @tparam "static"|"dynamic" kind
-- @tparam Circle circle
-- @treturn windfield.Collider
function physics.make_circle_collider(world, kind, circle)
  assertions.is_table(world)
  assertions.is_enumeration(kind, {"static", "dynamic"})
  assertions.is_instance(circle, Circle)

  local collider = world:newCircleCollider(
    circle.center.x,
    circle.center.y,
    circle.radius
  )
  collider:setType(kind)

  return collider
end

return physics
