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
function physics.make_collider(world, kind, rectangle)
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
-- @tparam {windfield.Collider,...} colliders
-- @tparam func handler func(collider: windfield.Collider): nil
function physics.process_colliders(colliders, handler)
  assert(type(colliders) == "table")
  assert(typeutils.is_callable(handler))

  for _, collider in ipairs(colliders) do
    if not collider:isDestroyed() then
      handler(collider)
    end
  end
end

return physics
