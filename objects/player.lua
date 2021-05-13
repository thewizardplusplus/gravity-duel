---
-- @classmod Player

local middleclass = require("middleclass")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")
local physics = require("physics")
local drawing = require("drawing")

---
-- @table instance
-- @tfield number _grid_step [0, ∞)
-- @tfield windfield.Collider _collider

local Player = middleclass("Player")

---
-- @function new
-- @tparam windfield.World world
-- @tparam Rectangle screen
-- @treturn Player
function Player:initialize(world, screen)
  assert(type(world) == "table")
  assert(typeutils.is_instance(screen, Rectangle))

  self._grid_step = screen.height / 8

  local x = screen.x + screen.width / 2 - self._grid_step / 2 - self._grid_step / 6
  local y = screen.y + screen.height / 2 - self._grid_step / 2
  self._collider = physics.make_rectangle_collider(world, "dynamic", Rectangle:new(
    x,
    y,
    self._grid_step + self._grid_step / 3,
    self._grid_step
  ))
  self._collider:setCollisionClass("Player")
  self._collider:setAngle(-math.pi / 2)
  self._collider:setMass(1 + 2 / 9)
end

---
-- @function draw
function Player:draw()
  love.graphics.setColor(0.5, 0.5, 0.5)
  drawing.draw_collider(self._collider, function()
    love.graphics.rectangle(
      "fill",
      -self._grid_step / 2 - self._grid_step / 6,
      -self._grid_step / 2,
      self._grid_step,
      self._grid_step
    )
    love.graphics.rectangle(
      "fill",
      self._grid_step / 2 - self._grid_step / 6,
      -self._grid_step / 2,
      self._grid_step / 3,
      self._grid_step / 3
    )
    love.graphics.rectangle(
      "fill",
      self._grid_step / 2 - self._grid_step / 6,
      -self._grid_step / 2 + 2 * self._grid_step / 3,
      self._grid_step / 3,
      self._grid_step / 3
    )
  end)
end

return Player
