---
-- @classmod Player

local middleclass = require("middleclass")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")
local physics = require("physics")
local drawing = require("drawing")

---
-- @table instance
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

  self._collider =
    physics.make_rectangle_collider(world, "dynamic", Rectangle:new(
      screen.x + screen.width / 2
        - screen:grid_step() / 2 - screen:grid_step() / 6,
      screen.y + screen.height / 2 - screen:grid_step() / 2,
      screen:grid_step() + screen:grid_step() / 3,
      screen:grid_step()
    ))
  self._collider:setCollisionClass("Player")
  self._collider:setAngle(-math.pi / 2)
  self._collider:setMass(1 + 2 / 9)
end

---
-- @treturn number x
-- @treturn number y
function Player:position()
  return self._collider:getPosition()
end

---
-- @treturn number
function Player:angle()
  return self._collider:getAngle()
end

---
-- @tparam Rectangle screen
function Player:draw(screen)
  assert(typeutils.is_instance(screen, Rectangle))

  love.graphics.setColor(0.5, 0.5, 0.5)
  drawing.draw_collider(self._collider, function()
    love.graphics.rectangle(
      "fill",
      -screen:grid_step() / 2 - screen:grid_step() / 6,
      -screen:grid_step() / 2,
      screen:grid_step(),
      screen:grid_step()
    )
    love.graphics.rectangle(
      "fill",
      screen:grid_step() / 2 - screen:grid_step() / 6,
      -screen:grid_step() / 2,
      screen:grid_step() / 3,
      screen:grid_step() / 3
    )
    love.graphics.rectangle(
      "fill",
      screen:grid_step() / 2 - screen:grid_step() / 6,
      -screen:grid_step() / 2 + 2 * screen:grid_step() / 3,
      screen:grid_step() / 3,
      screen:grid_step() / 3
    )
  end)
end

---
-- @tparam number x
-- @tparam number y
function Player:set_direction(x, y)
  assert(type(x) == "number")
  assert(type(y) == "number")

  if x ~= 0 or y ~= 0 then
    self._collider:setAngle(math.atan2(y, x))
  end
end

---
-- @function destroy
function Player:destroy()
  self._collider:destroy()
end

return Player
