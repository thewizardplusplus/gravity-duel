---
-- @classmod Impulse

local middleclass = require("middleclass")
local mlib = require("mlib")
local assertions = require("luatypechecks.assertions")
local mathutils = require("mathutils")
local Rectangle = require("models.rectangle")
local Circle = require("models.circle")
local Collider = require("objects.collider")
local Hole = require("objects.hole")
local Player = require("objects.player")
local physics = require("physics")
local drawing = require("drawing")

---
-- @table instance
-- @tfield windfield.Collider _collider

local Impulse = middleclass("Impulse")
Impulse:include(Collider)

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

  local player_position_x, player_position_y = player:position()
  self._collider = physics.make_circle_collider(world, "dynamic", Circle:new(
    player_position_x,
    player_position_y,
    screen:grid_step() / 12
  ))
  self._collider:setCollisionClass("Impulse")
  self._collider:setMass(1 / 36)

  local impulse_speed = 2 * screen.height
  local player_direction_x, player_direction_y = player:direction()
  self._collider:applyLinearImpulse(mathutils.transform_vector(
    player_direction_x,
    player_direction_y,
    impulse_speed
  ))
end

---
-- @function position
-- @treturn number x
-- @treturn number y

---
-- @treturn bool
function Impulse:hit()
  return self._collider:enter("Default")
end

---
-- @treturn number x
-- @treturn number y
function Impulse:vector_to(collider)
  assertions.is_table(collider)

  local vector = mlib.vec2.sub(
    mlib.vec2.new(collider:position()),
    mlib.vec2.new(self:position())
  )
  return vector.x, vector.y
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
-- @tparam Rectangle screen
-- @tparam Hole hole
function Impulse:apply_hole(screen, hole)
  assertions.is_instance(screen, Rectangle)
  assertions.is_instance(hole, Hole)

  local vector_to_hole = mlib.vec2.new(self:vector_to(hole))
  if hole:kind() == "white" then
    vector_to_hole = mlib.vec2.mul(vector_to_hole, -1)
  end

  local factor = 1000000 * math.pow(screen.height / 400, 3)
  factor = factor / math.pow(mlib.vec2.len(vector_to_hole), 2)

  local direction_to_hole = mlib.vec2.normalize(vector_to_hole)
  self._collider:applyForce(mathutils.transform_vector(
    direction_to_hole.x,
    direction_to_hole.y,
    factor,
    false
  ))
end

---
-- @function destroy

return Impulse
