---
-- @module drawing

local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Vector2D = require("luamath.vector2d")
local BoundingBox = require("luamath.models.boundingbox")
local Rectangle = require("models.rectangle")
local Label = require("models.label")

local _ICONS_FONT_PATH =
  "resources/fonts/font-awesome/font_awesome_free_7.3.0_solid_900.otf"

local drawing = {}

---
-- @tparam Rectangle screen
-- @treturn {[string]=Font,...}
function drawing.load_fonts(screen)
  assertions.is_instance(screen, Rectangle)

  local font_size = screen:font_size()
  return {
    default = love.graphics.newFont(font_size),
    icons = love.graphics.newFont(_ICONS_FONT_PATH, font_size),
  }
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
-- @tparam BoundingBox screen
-- @tparam {[string]=Font,...} fonts
-- @tparam {tab,...} drawables group of tables with the draw() method
function drawing.draw_drawables(screen, fonts, drawables)
  assertions.is_instance(screen, BoundingBox)
  assertions.is_table(fonts, checks.is_string, function(font)
    return type(font) == "userdata"
  end)
  assertions.is_sequence(drawables, checks.is_table)

  table.eachi(drawables, function(drawable)
    assertions.is_table(drawable)

    drawable:draw(screen, fonts)
  end)
end

---
-- @tparam "fill"|"line" mode
-- @tparam BoundingBox rectangle
function drawing.draw_rectangle(mode, rectangle)
  assertions.is_enumeration(mode, {"fill", "line"})
  assertions.is_instance(rectangle, BoundingBox)

  local position = rectangle:position()
  local size = rectangle:size()
  love.graphics.rectangle(
    mode,
    position.x,
    position.y,
    size.width,
    size.height
  )
end

---
-- @tparam BoundingBox screen
-- @tparam {[string]=Font,...} fonts
-- @tparam Vector2D position
-- @tparam {Label,...} labels
function drawing.draw_labels(screen, fonts, position, labels)
  assertions.is_instance(screen, BoundingBox)
  assertions.is_table(fonts, checks.is_string, function(font)
    return type(font) == "userdata"
  end)
  assertions.is_instance(position, Vector2D)
  assertions.is_sequence(labels, checks.make_instance_checker(Label))

  local grid_step = screen:size().height / 16
  for index, label in ipairs(labels) do
    love.graphics.print(
      string.format("%s: %s", label.title, label.value),
      fonts.default,
      position.x,
      position.y + (index - 1) * grid_step
    )
  end
end

return drawing
