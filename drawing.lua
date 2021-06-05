---
-- @module drawing

local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")

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

---
-- @tparam Rectangle screen
-- @tparam {tab,...} drawables group of tables with the draw() method
function drawing.draw_drawables(screen, drawables)
  assert(typeutils.is_instance(screen, Rectangle))
  assert(type(drawables) == "table")

  table.eachi(drawables, function(drawable)
    assert(typeutils.is_callable(drawable.draw))

    drawable:draw(screen)
  end)
end

return drawing
