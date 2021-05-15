---
-- @classmod Impulse

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

  local player_position_x, player_position_y = player:position()
  self._collider = physics.make_circle_collider(
    world,
    "dynamic",
    player_position_x,
    player_position_y,
    screen:grid_step() / 12
  )
  self._collider:setCollisionClass("Impulse")
  self._collider:setMass(1 / 36)

  local impulse_speed = 2 * screen.height
  local dt = love.timer.getDelta()
  local player_direction = mlib.vec2.rotate(mlib.vec2.new(1, 0), player:angle())
  self._collider:applyLinearImpulse(
    impulse_speed * dt * player_direction.x,
    impulse_speed * dt * player_direction.y
  )
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

return Impulse
