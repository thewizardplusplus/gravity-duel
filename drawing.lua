---
-- @module drawing

local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Rectangle = require("models.rectangle")
local Label = require("models.label")

local drawing = {}

---
-- @tparam Rectangle screen
function drawing.set_font(screen)
  assertions.is_instance(screen, Rectangle)

  local font = love.graphics.newFont(screen:font_size())
  love.graphics.setFont(font)
  gooi.setStyle({font = font})
end

---
-- @tparam func drawer func(): nil
function drawing.draw_with_transformations(drawer)
  assertions.is_function(drawer)

  love.graphics.push()
  drawer()
  love.graphics.pop()
end

---
-- @tparam windfield.Collider collider
-- @tparam func drawer func(): nil
function drawing.draw_collider(collider, drawer)
  assertions.is_table(collider)
  assertions.is_function(drawer)

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
  assertions.is_instance(screen, Rectangle)
  assertions.is_sequence(drawables, checks.is_table)

  table.eachi(drawables, function(drawable)
    assertions.is_table(drawable)

    drawable:draw(screen)
  end)
end

---
-- @tparam Rectangle screen
-- @tparam number x [0, ∞)
-- @tparam number y [0, ∞)
-- @tparam {Label,...} labels
function drawing.draw_labels(screen, x, y, labels)
  assertions.is_instance(screen, Rectangle)
  assertions.is_number(x)
  assertions.is_number(y)
  assertions.is_sequence(labels, checks.make_instance_checker(Label))

  local grid_step = screen.height / 16
  for index, label in ipairs(labels) do
    love.graphics.print(
      string.format("%s: %s", label.title, label.value),
      x,
      y + (index - 1) * grid_step
    )
  end
end

return drawing
