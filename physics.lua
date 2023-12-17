---
-- @module physics

local assertions = require("luatypechecks.assertions")
local Rectangle = require("models.rectangle")
local Circle = require("models.circle")

local physics = {}

---
-- @tparam windfield.World world
-- @tparam "static"|"dynamic" kind
-- @tparam Rectangle rectangle
-- @treturn windfield.Collider
function physics.make_rectangle_collider(world, kind, rectangle)
  assertions.is_table(world)
  assertions.is_enumeration(kind, {"static", "dynamic"})
  assertions.is_instance(rectangle, Rectangle)

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
-- @tparam Circle circle
-- @treturn windfield.Collider
function physics.make_circle_collider(world, kind, circle)
  assertions.is_table(world)
  assertions.is_enumeration(kind, {"static", "dynamic"})
  assertions.is_instance(circle, Circle)

  local collider = world:newCircleCollider(circle.x, circle.y, circle.radius)
  collider:setType(kind)

  return collider
end

return physics
