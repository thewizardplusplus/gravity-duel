---
-- @classmod Target

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Rectangle = require("models.rectangle")
local Color = require("models.color")
local Range = require("models.range")
local TemporaryCircle = require("objects.temporarycircle")
local Player = require("objects.player")
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
  assertions.is_table(world)
  assertions.is_instance(screen, Rectangle)
  assertions.is_instance(player, Player)
  assertions.is_function(life_decrement_handler)

  TemporaryCircle.initialize(
    self,
    5,
    world,
    player,
    Range:new(2 * screen:grid_step(), 	5 * screen:grid_step()),
    Range:new(-math.pi / 3, math.pi / 3),
    screen:grid_step() / 2,
    screen:grid_step() / 10,
    Color:new(0, 0.5, 0),
    Color:new(0, 0.3, 0)
  )

  self._initial_lifes = 5
  self._current_lifes = self._initial_lifes

  self._life_decrement_handler = life_decrement_handler
end

---
-- @function position
-- @treturn number x
-- @treturn number y

---
-- @treturn bool
function Target:alive()
  return TemporaryCircle.alive(self) and self._current_lifes > 0
end

---
-- @tparam Rectangle screen
function Target:draw(screen)
  assertions.is_instance(screen, Rectangle)

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
