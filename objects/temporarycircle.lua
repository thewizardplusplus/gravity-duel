---
-- @classmod TemporaryCircle

local middleclass = require("middleclass")
local mlib = require("mlib")
local typeutils = require("typeutils")
local mathutils = require("mathutils")
local Rectangle = require("models.rectangle")
local Circle = require("models.circle")
local Color = require("models.color")
local Range = require("models.range")
local Collider = require("objects.collider")
local Player = require("objects.player")
local physics = require("physics")
local drawing = require("drawing")

---
-- @table instance
-- @tfield number _initial_lifetime [0, ∞)
-- @tfield number _rest_lifetime
-- @tfield number _radius [0, ∞)
-- @tfield number _border_width [0, ∞)
-- @tfield Color _fill_color
-- @tfield Color _border_color
-- @tfield windfield.Collider _collider

local TemporaryCircle = middleclass("TemporaryCircle")
TemporaryCircle:include(Collider)

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
  assert(typeutils.is_positive_number(initial_lifetime))
  assert(type(world) == "table")
  assert(typeutils.is_instance(player, Player))
  assert(typeutils.is_instance(distance_range, Range))
  assert(typeutils.is_instance(additional_angle_range, Range))
  assert(typeutils.is_positive_number(radius))
  assert(typeutils.is_positive_number(border_width))
  assert(typeutils.is_instance(fill_color, Color))
  assert(typeutils.is_instance(border_color, Color))

  self._initial_lifetime = initial_lifetime
  self._rest_lifetime = initial_lifetime
  self._radius = radius
  self._border_width = border_width
  self._fill_color = fill_color
  self._border_color = border_color

  local distance =
    mathutils.random_in_range(distance_range.minimum, distance_range.maximum)
  local additional_angle = mathutils.random_in_range(
    additional_angle_range.minimum,
    additional_angle_range.maximum
  )
  local direction =
    mlib.vec2.rotate(mlib.vec2.new(1, 0), player:angle() + additional_angle)
  local player_position_x, player_position_y = player:position()
  self._collider = physics.make_circle_collider(world, "static", Circle:new(
    distance * direction.x + player_position_x,
    distance * direction.y + player_position_y,
    radius
  ))
end

---
-- @function position
-- @treturn number x
-- @treturn number y

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

return TemporaryCircle