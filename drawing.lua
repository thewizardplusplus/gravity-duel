---
-- @module drawing

local typeutils = require("typeutils")

local drawing = {}

---
-- @tparam func drawer func(): nil
function drawing.draw_with_transformations(drawer)
  assert(typeutils.is_callable(drawer))

  love.graphics.push()
  drawer()
  love.graphics.pop()
end

---
-- @tparam windfield.Collider collider
-- @tparam func drawer func(): nil
function drawing.draw_collider(collider, drawer)
  assert(type(collider) == "table")
  assert(typeutils.is_callable(drawer))

  drawing.draw_with_transformations(function()
    love.graphics.translate(collider:getPosition())
    love.graphics.rotate(collider:getAngle())
    drawer()
  end)
end

return drawing
