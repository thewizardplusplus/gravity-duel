---
-- @classmod Target

local middleclass = require("middleclass")
local mlib = require("mlib")
local typeutils = require("typeutils")
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

local Target = middleclass("Target")

---
-- @function new
-- @tparam windfield.World world
-- @tparam Rectangle screen
-- @tparam number x
-- @tparam number y
-- @treturn Target
function Target:initialize(world, screen, x, y)
  assert(type(world) == "table")
  assert(typeutils.is_instance(screen, Rectangle))
  assert(type(x) == "number")
  assert(type(y) == "number")

  self._initial_lifetime = 5
  self._rest_lifetime = self._initial_lifetime

  self._initial_lifes = 5
  self._current_lifes = self._initial_lifes

  self._collider = physics.make_circle_collider(
    world,
    "static",
    x,
    y,
    screen:grid_step() / 2
  )
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
  end
end

---
-- @function destroy
function Target:destroy()
  self._collider:destroy()
end

return Target