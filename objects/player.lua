---
-- @classmod Player

local middleclass = require("middleclass")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")
local physics = require("physics")

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

  local grid_step = screen.height / 8
  local x = screen.x + screen.width / 2 - grid_step / 2 - grid_step / 6
  local y = screen.y + screen.height / 2 - grid_step / 2
  self._collider = physics.make_rectangle_collider(world, "dynamic", Rectangle:new(
    x,
    y,
    grid_step + grid_step / 3,
    grid_step
  ))
  self._collider:setCollisionClass("Player")
  self._collider:setAngle(-math.pi / 2)
  self._collider:setMass(1 + 2 / 9)
end

return Player
