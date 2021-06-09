---
-- @classmod Target

local middleclass = require("middleclass")
local mlib = require("mlib")
local typeutils = require("typeutils")
local mathutils = require("mathutils")
local Rectangle = require("models.rectangle")
local Circle = require("models.circle")
local Color = require("models.color")
local TemporaryCircle = require("objects.temporarycircle")
local Player = require("objects.player")
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
-- @tfield number _initial_lifes [0, ∞)
-- @tfield number _current_lifes
-- @tfield func _life_decrement_handler func(lifes: number): nil

local Target = middleclass("Target", TemporaryCircle)

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

  local distance =
    mathutils.random_in_range(2 * screen:grid_step(), 5 * screen:grid_step())
  local additional_angle = mathutils.random_in_range(-math.pi / 3, math.pi / 3)
  local direction =
    mlib.vec2.rotate(mlib.vec2.new(1, 0), player:angle() + additional_angle)
  local player_position_x, player_position_y = player:position()
  TemporaryCircle.initialize(
    self,
    world,
    5,
    screen:grid_step() / 10,
    Circle:new(
      distance * direction.x + player_position_x,
      distance * direction.y + player_position_y,
      screen:grid_step() / 2
    ),
    Color:new(0, 0.5, 0),
    Color:new(0, 0.3, 0)
  )

  self._initial_lifes = 5
  self._current_lifes = self._initial_lifes

  self._life_decrement_handler = life_decrement_handler
end

---
-- @treturn bool
function Target:alive()
  return TemporaryCircle.alive(self) and self._current_lifes > 0
end

---
-- @tparam Rectangle screen
function Target:draw(screen)
  assert(typeutils.is_instance(screen, Rectangle))

  TemporaryCircle.draw(self, screen)

  drawing.draw_collider(self._collider, function()
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
      tostring(self._current_lifes),
      -screen:grid_step() / 2,
      -screen:font_size() / 2,
      screen:grid_step(),
      "center"
    )
  end)
end

---
-- @function update
function Target:update()
  TemporaryCircle.update(self)

  if self._collider:enter("Impulse") then
    self._current_lifes = self._current_lifes - 1
    self._life_decrement_handler(self._current_lifes)
  end
end

---
-- @function destroy

return Target
