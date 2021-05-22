---
-- @classmod Target

local middleclass = require("middleclass")
local mlib = require("mlib")
local typeutils = require("typeutils")
local mathutils = require("mathutils")
local Rectangle = require("models.rectangle")
local Player = require("objects.player")
local physics = require("physics")
local drawing = require("drawing")

---
-- @table instance
-- @tfield number _initial_lifetime
-- @tfield number _rest_lifetime
-- @tfield number _initial_lifes
-- @tfield number _current_lifes
-- @tfield windfield.Collider _collider
-- @tfield func _life_decrement_handler func(lifes: number): nil

local Target = middleclass("Target")

---
-- @function new
-- @tparam windfield.World world
-- @tparam Rectangle screen
-- @tparam Player player
-- @tfield func life_decrement_handler func(lifes: number): nil
-- @treturn Target
function Target:initialize(world, screen, player, life_decrement_handler)
  assert(type(world) == "table")
  assert(typeutils.is_instance(screen, Rectangle))
  assert(typeutils.is_instance(player, Player))
  assert(typeutils.is_callable(life_decrement_handler))

  self._initial_lifetime = 5
  self._rest_lifetime = self._initial_lifetime

  self._initial_lifes = 5
  self._current_lifes = self._initial_lifes

  local distance =
    mathutils.random_in_range(2 * screen:grid_step(), 5 * screen:grid_step())
  local additional_angle = mathutils.random_in_range(-math.pi / 3, math.pi / 3)
  local direction =
    mlib.vec2.rotate(mlib.vec2.new(1, 0), player:angle() + additional_angle)
  local player_position_x, player_position_y = player:position()
  self._collider = physics.make_circle_collider(
    world,
    "static",
    0,
    0,
    screen:grid_step() / 2
  )
  self._collider:setPosition(
    distance * direction.x + player_position_x,
    distance * direction.y + player_position_y
  )

  self._life_decrement_handler = life_decrement_handler
end

---
-- @treturn bool
function Target:alive()
  return self._rest_lifetime > 0 and self._current_lifes > 0
end

---
-- @tparam Rectangle screen
function Target:draw(screen)
  assert(typeutils.is_instance(screen, Rectangle))

  local font_size = screen.height / 20
  love.graphics.setFont(love.graphics.newFont(font_size))

  drawing.draw_collider(self._collider, function()
    love.graphics.setColor(0, 0.5, 0)
    love.graphics.circle("fill", 0, 0, screen:grid_step() / 2)

    local elapsed_lifetime_factor = self._rest_lifetime / self._initial_lifetime
    love.graphics.setColor(0, 0.3, 0)
    love.graphics.setLineWidth(screen:grid_step() / 10)
    love.graphics.arc(
      "line",
      "open",
      0,
      0,
      screen:grid_step() / 2,
      2 * math.pi - math.pi / 2 - 2 * math.pi * elapsed_lifetime_factor,
      2 * math.pi - math.pi / 2
    )

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
      tostring(self._current_lifes),
      -screen:grid_step() / 2,
      -font_size / 2,
      screen:grid_step(),
      "center"
    )
  end)
end

---
-- @function update
function Target:update()
  local dt = love.timer.getDelta()
  self._rest_lifetime = self._rest_lifetime - dt

  if self._collider:enter("Impulse") then
    self._current_lifes = self._current_lifes - 1
    self._life_decrement_handler(self._current_lifes)
  end
end

---
-- @function destroy
function Target:destroy()
  self._collider:destroy()
end

return Target
