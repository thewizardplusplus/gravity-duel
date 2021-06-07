---
-- @module drawing

local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")
local Label = require("models.label")

local drawing = {}

---
-- @tparam Rectangle screen
function drawing.set_font(screen)
  assert(typeutils.is_instance(screen, Rectangle))

  local font = love.graphics.newFont(screen:font_size())
  love.graphics.setFont(font)
  gooi.setStyle({font = font})
end

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

---
-- @tparam Rectangle screen
-- @tparam number x [0, ∞)
-- @tparam number y [0, ∞)
-- @tparam {Label,...} labels
function drawing.draw_labels(screen, x, y, labels)
  assert(typeutils.is_instance(screen, Rectangle))
  assert(typeutils.is_positive_number(x))
  assert(typeutils.is_positive_number(y))
  assert(type(labels) == "table")

  local grid_step = screen.height / 16
  for index, label in ipairs(labels) do
    assert(typeutils.is_instance(label, Label))

    love.graphics.print(
      string.format("%s: %s", label.title, label.value),
      x,
      y + (index - 1) * grid_step
    )
  end
end

return drawing
