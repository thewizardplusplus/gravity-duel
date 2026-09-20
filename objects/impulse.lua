---
-- @classmod Impulse

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local BoundingBox = require("luamath.models.boundingbox")
local Rectangle = require("models.rectangle")
local Circle = require("models.circle")
local Collider = require("objects.collider")
local Hole = require("objects.hole")
local Player = require("objects.player")
local physics = require("physics")
local drawing = require("drawing")

local Impulse = middleclass("Impulse")
Impulse:include(Collider)

---
-- @table instance
-- @tfield windfield.Collider _collider

---
-- @function new
-- @tparam windfield.World world
-- @tparam Rectangle screen
-- @tparam Player player
-- @treturn Impulse
function Impulse:initialize(world, screen, player)
  assertions.is_table(world)
  assertions.is_instance(screen, Rectangle)
  assertions.is_instance(player, Player)

  self._collider = physics.make_circle_collider(world, "dynamic", Circle:new(
    player:position(),
    screen:grid_step() / 12
  ))
  self._collider:setCollisionClass("Impulse")
  self._collider:setMass(1 / 36)

  local impulse_speed = 2 * screen:size().height
  local impulse = player:direction() * (impulse_speed * love.timer.getDelta())
  self._collider:applyLinearImpulse(impulse.x, impulse.y)
end

---
-- @function position
-- @treturn Vector2D

---
-- @treturn bool
function Impulse:hit()
  return self._collider:enter("Default")
end

---
-- @tparam Collider collider
-- @treturn Vector2D
function Impulse:vector_to(collider)
  assertions.is_table(collider)

  return collider:position() - self:position()
end

---
-- @tparam Rectangle screen
function Impulse:draw(screen)
  assertions.is_instance(screen, Rectangle)

  love.graphics.setColor(0, 0.5, 1)
  drawing.draw_collider(self._collider, function()
    love.graphics.circle("fill", 0, 0, screen:grid_step() / 12)
  end)
end

---
-- @tparam BoundingBox screen
-- @tparam Hole hole
function Impulse:apply_hole(screen, hole)
  assertions.is_instance(screen, BoundingBox)
  assertions.is_instance(hole, Hole)

  local vector_to_hole = self:vector_to(hole)
  if hole:kind() == "white" then
    vector_to_hole = -vector_to_hole
  end

  local factor = 1000000 * math.pow(screen:size().height / 400, 3)
  factor = factor / vector_to_hole:length_squared()

  local force = vector_to_hole:normalized() * factor
  self._collider:applyForce(force.x, force.y)
end

---
-- @function destroy

return Impulse
