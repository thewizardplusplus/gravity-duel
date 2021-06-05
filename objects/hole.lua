---
-- @classmod Hole

local middleclass = require("middleclass")
local mlib = require("mlib")
local typeutils = require("typeutils")
local mathutils = require("mathutils")
local Rectangle = require("models.rectangle")
local Circle = require("models.circle")
local Player = require("objects.player")
local physics = require("physics")
local drawing = require("drawing")

---
-- @table instance
-- @tfield "black"|"white" _kind
-- @tfield number _initial_lifetime
-- @tfield number _rest_lifetime
-- @tfield windfield.Collider _collider

local Hole = middleclass("Hole")

---
-- @function new
-- @tparam "black"|"white" kind
-- @tparam windfield.World world
-- @tparam Rectangle screen
-- @tparam Player player
-- @treturn Hole
function Hole:initialize(kind, world, screen, player)
  assert(kind == "black" or kind == "white")
  assert(type(world) == "table")
  assert(typeutils.is_instance(screen, Rectangle))
  assert(typeutils.is_instance(player, Player))

  self._kind = kind

  self._initial_lifetime = 5
  self._rest_lifetime = self._initial_lifetime

  local distance =
    mathutils.random_in_range(2 * screen:grid_step(), 5 * screen:grid_step())
  local angle = mathutils.random_in_range(0, 2 * math.pi)
  local direction = mlib.vec2.rotate(mlib.vec2.new(1, 0), angle)
  local player_position_x, player_position_y = player:position()
  self._collider = physics.make_circle_collider(world, "static", Circle:new(
    0,
    0,
    3 * screen:grid_step() / 4
  ))
  self._collider:setPosition(
    distance * direction.x + player_position_x,
    distance * direction.y + player_position_y
  )
end

---
-- @treturn "black"|"white"
function Hole:kind()
  return self._kind
end

---
-- @treturn bool
function Hole:alive()
  return self._rest_lifetime > 0
end

---
-- @treturn number x
-- @treturn number y
function Hole:position()
  return self._collider:getPosition()
end

---
-- @tparam Rectangle screen
function Hole:draw(screen)
  assert(typeutils.is_instance(screen, Rectangle))

  drawing.draw_collider(self._collider, function()
    if self._kind == "black" then
      love.graphics.setColor(0.3, 0.3, 0.3)
    elseif self._kind == "white" then
      love.graphics.setColor(0.75, 0.75, 0.75)
    end
    love.graphics.circle("fill", 0, 0, 3 * screen:grid_step() / 4)

    local elapsed_lifetime_factor = self._rest_lifetime / self._initial_lifetime
    if self._kind == "black" then
      love.graphics.setColor(0.15, 0.15, 0.15)
    elseif self._kind == "white" then
      love.graphics.setColor(0.55, 0.55, 0.55)
    end
    love.graphics.setLineWidth(screen:grid_step() / 10)
    love.graphics.arc(
      "line",
      "open",
      0,
      0,
      3 * screen:grid_step() / 4,
      2 * math.pi - math.pi / 2 - 2 * math.pi * elapsed_lifetime_factor,
      2 * math.pi - math.pi / 2
    )
  end)
end

---
-- @function update
function Hole:update()
  local dt = love.timer.getDelta()
  self._rest_lifetime = self._rest_lifetime - dt
end

---
-- @function destroy
function Hole:destroy()
  self._collider:destroy()
end

return Hole
