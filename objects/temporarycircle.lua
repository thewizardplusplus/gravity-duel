---
-- @classmod TemporaryCircle

local middleclass = require("middleclass")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")
local Circle = require("models.circle")
local Color = require("models.color")
local physics = require("physics")
local drawing = require("drawing")

---
-- @table instance
-- @tfield number _initial_lifetime [0, ∞)
-- @tfield number _rest_lifetime
-- @tfield number _border_width [0, ∞)
-- @tfield number _radius [0, ∞)
-- @tfield Color _fill_color
-- @tfield Color _border_color
-- @tfield windfield.Collider _collider

local TemporaryCircle = middleclass("TemporaryCircle")

---
-- @function new
-- @tparam windfield.World world
-- @tparam number initial_lifetime [0, ∞)
-- @tparam number border_width [0, ∞)
-- @tparam Circle circle
-- @tparam Color fill_color
-- @tparam Color border_color
-- @treturn TemporaryCircle
function TemporaryCircle:initialize(
  world,
  initial_lifetime,
  border_width,
  circle,
  fill_color,
  border_color
)
  assert(type(world) == "table")
  assert(typeutils.is_positive_number(initial_lifetime))
  assert(typeutils.is_positive_number(border_width))
  assert(typeutils.is_instance(circle, Circle))
  assert(typeutils.is_instance(fill_color, Color))
  assert(typeutils.is_instance(border_color, Color))

  self._initial_lifetime = initial_lifetime
  self._rest_lifetime = initial_lifetime
  self._border_width = border_width
  self._radius = circle.radius
  self._fill_color = fill_color
  self._border_color = border_color

  self._collider = physics.make_circle_collider(world, "static", circle)
end

---
-- @treturn bool
function TemporaryCircle:alive()
  return self._rest_lifetime > 0
end

---
-- @tparam Rectangle screen
function TemporaryCircle:draw(screen)
  assert(typeutils.is_instance(screen, Rectangle))

  drawing.draw_collider(self._collider, function()
    love.graphics.setColor(self._fill_color:channels())
    love.graphics.circle("fill", 0, 0, self._radius)

    local elapsed_lifetime_factor = self._rest_lifetime / self._initial_lifetime
    love.graphics.setColor(self._border_color:channels())
    love.graphics.setLineWidth(self._border_width)
    love.graphics.arc(
      "line",
      "open",
      0,
      0,
      self._radius,
      2 * math.pi - math.pi / 2 - 2 * math.pi * elapsed_lifetime_factor,
      2 * math.pi - math.pi / 2
    )
  end)
end

---
-- @function update
function TemporaryCircle:update()
  local dt = love.timer.getDelta()
  self._rest_lifetime = self._rest_lifetime - dt
end

---
-- @function destroy
function TemporaryCircle:destroy()
  self._collider:destroy()
end

return TemporaryCircle
