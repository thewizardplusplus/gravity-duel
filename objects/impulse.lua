---
-- @classmod Impulse

local middleclass = require("middleclass")
local mlib = require("mlib")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")
local Circle = require("models.circle")
local Hole = require("objects.hole")
local Player = require("objects.player")
local physics = require("physics")
local drawing = require("drawing")

---
-- @table instance
-- @tfield windfield.Collider _collider

local Impulse = middleclass("Impulse")

---
-- @function new
-- @tparam windfield.World world
-- @tparam Rectangle screen
-- @tparam Player player
-- @treturn Impulse
function Impulse:initialize(world, screen, player)
  assert(type(world) == "table")
  assert(typeutils.is_instance(screen, Rectangle))
  assert(typeutils.is_instance(player, Player))

  self._collider = physics.make_circle_collider(world, "dynamic", Circle:new(
    0,
    0,
    screen:grid_step() / 12
  ))
  self._collider:setCollisionClass("Impulse")
  self._collider:setMass(1 / 36)
  self._collider:setPosition(player:position())

  local impulse_speed = 2 * screen.height
  local dt = love.timer.getDelta()
  local player_direction = mlib.vec2.rotate(mlib.vec2.new(1, 0), player:angle())
  self._collider:applyLinearImpulse(
    impulse_speed * dt * player_direction.x,
    impulse_speed * dt * player_direction.y
  )
end

---
-- @treturn bool
function Impulse:hit()
  return self._collider:enter("Default")
end

---
-- @tparam Rectangle screen
function Impulse:draw(screen)
  assert(typeutils.is_instance(screen, Rectangle))

  love.graphics.setColor(0, 0.5, 1)
  drawing.draw_collider(self._collider, function()
    love.graphics.circle("fill", 0, 0, screen:grid_step() / 12)
  end)
end

---
-- @tparam Rectangle screen
-- @tparam Hole hole
function Impulse:apply_hole(screen, hole)
  assert(typeutils.is_instance(screen, Rectangle))
  assert(typeutils.is_instance(hole, Hole))

  local vector = mlib.vec2.sub(
    mlib.vec2.new(hole:position()),
    mlib.vec2.new(self._collider:getPosition())
  )
  if hole:kind() == "white" then
    vector = mlib.vec2.mul(vector, -1)
  end

  local factor = 1000000 * math.pow(screen.height / 400, 3)
  local distance = mlib.vec2.len(vector)
  local direction = mlib.vec2.normalize(vector)
  local force = mlib.vec2.mul(direction, factor / math.pow(distance, 2))
  self._collider:applyForce(force.x, force.y)
end

---
-- @function destroy
function Impulse:destroy()
  self._collider:destroy()
end

return Impulse
