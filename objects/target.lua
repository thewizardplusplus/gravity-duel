---
-- @classmod Target

local middleclass = require("middleclass")
local mlib = require("mlib")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")
local Player = require("objects.player")
local physics = require("physics")
local drawing = require("drawing")

---
-- @table instance
-- @tfield windfield.Collider _collider

local Target = middleclass("Target")

---
-- @function new
-- @tparam windfield.World world
-- @tparam Rectangle screen
-- @tparam number x
-- @tparam number y
-- @treturn Target
function Target:initialize(world, screen, x, y)
  assert(type(world) == "table")
  assert(typeutils.is_instance(screen, Rectangle))
  assert(type(x) == "number")
  assert(type(y) == "number")

  self._collider = physics.make_circle_collider(
    world,
    "static",
    x,
    y,
    screen:grid_step() / 2
  )
end

---
-- @tparam Rectangle screen
function Target:draw(screen)
  assert(typeutils.is_instance(screen, Rectangle))

  love.graphics.setColor(0, 0.5, 0)
  drawing.draw_collider(self._collider, function()
    love.graphics.circle("fill", 0, 0, screen:grid_step() / 2)
  end)
end

---
-- @function destroy
function Target:destroy()
  self._collider:destroy()
end

return Target
