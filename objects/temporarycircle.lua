---
-- @classmod TemporaryCircle

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Range = require("luamath.models.range")
local Color = require("luamath.models.color")
local BoundingBox = require("luamath.models.boundingbox")
local Circle = require("models.circle")
local Collider = require("objects.collider")
local Player = require("objects.player")
local physics = require("physics")
local drawing = require("drawing")

local TemporaryCircle = middleclass("TemporaryCircle")
TemporaryCircle:include(Collider)

---
-- @table instance
-- @tfield number _initial_lifetime [0, ∞)
-- @tfield number _rest_lifetime
-- @tfield number _radius [0, ∞)
-- @tfield number _border_width [0, ∞)
-- @tfield Color _fill_color
-- @tfield Color _border_color
-- @tfield windfield.Collider _collider

---
-- @function new
-- @tparam number initial_lifetime [0, ∞)
-- @tparam windfield.World world
-- @tparam Player player
-- @tparam Range distance_range
-- @tparam Range additional_angle_range
-- @tparam number radius [0, ∞)
-- @tparam number border_width [0, ∞)
-- @tparam Color fill_color
-- @tparam Color border_color
-- @treturn TemporaryCircle
function TemporaryCircle:initialize(
  initial_lifetime,
  world,
  player,
  distance_range,
  additional_angle_range,
  radius,
  border_width,
  fill_color,
  border_color
)
  assertions.is_number(initial_lifetime)
  assertions.is_table(world)
  assertions.is_instance(player, Player)
  assertions.is_instance(distance_range, Range)
  assertions.is_instance(additional_angle_range, Range)
  assertions.is_number(radius)
  assertions.is_number(border_width)
  assertions.is_instance(fill_color, Color)
  assertions.is_instance(border_color, Color)

  self._initial_lifetime = initial_lifetime
  self._rest_lifetime = initial_lifetime
  self._radius = radius
  self._border_width = border_width
  self._fill_color = fill_color
  self._border_color = border_color

  local distance = distance_range:random()
  local additional_angle = additional_angle_range:random()
  local circle_position =
    player:direction(nil, additional_angle) * distance + player:position()
  self._collider = physics.make_circle_collider(world, "static", Circle:new(
    circle_position,
    radius
  ))
end

---
-- @function position
-- @treturn Vector2D

---
-- @treturn bool
function TemporaryCircle:alive()
  return self._rest_lifetime > 0
end

---
-- @tparam BoundingBox screen
function TemporaryCircle:draw(screen)
  assertions.is_instance(screen, BoundingBox)

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

return TemporaryCircle
