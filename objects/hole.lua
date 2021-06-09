---
-- @classmod Hole

local middleclass = require("middleclass")
local mlib = require("mlib")
local typeutils = require("typeutils")
local mathutils = require("mathutils")
local Rectangle = require("models.rectangle")
local Circle = require("models.circle")
local Color = require("models.color")
local TemporaryCircle = require("objects.temporarycircle")
local Player = require("objects.player")

---
-- @table instance
-- @tfield number _initial_lifetime [0, ∞)
-- @tfield number _rest_lifetime
-- @tfield number _border_width [0, ∞)
-- @tfield number _radius [0, ∞)
-- @tfield Color _fill_color
-- @tfield Color _border_color
-- @tfield windfield.Collider _collider
-- @tfield "black"|"white" _kind

local Hole = middleclass("Hole", TemporaryCircle)

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

  local fill_color
  local border_color
  if kind == "black" then
    fill_color = Color:new(0.3, 0.3, 0.3)
    border_color = Color(0.15, 0.15, 0.15)
  elseif kind == "white" then
    fill_color = Color:new(0.75, 0.75, 0.75)
    border_color = Color(0.55, 0.55, 0.55)
  end

  local distance =
    mathutils.random_in_range(2 * screen:grid_step(), 5 * screen:grid_step())
  local angle = mathutils.random_in_range(0, 2 * math.pi)
  local direction = mlib.vec2.rotate(mlib.vec2.new(1, 0), angle)
  local player_position_x, player_position_y = player:position()
  TemporaryCircle.initialize(
    self,
    world,
    5,
    screen:grid_step() / 10,
    Circle:new(
      distance * direction.x + player_position_x,
      distance * direction.y + player_position_y,
      3 * screen:grid_step() / 4
    ),
    fill_color,
    border_color
  )

  self._kind = kind
end

---
-- @function alive
-- @treturn bool

---
-- @treturn "black"|"white"
function Hole:kind()
  return self._kind
end

---
-- @treturn number x
-- @treturn number y
function Hole:position()
  return self._collider:getPosition()
end

---
-- @function draw
-- @tparam Rectangle screen

---
-- @function update

---
-- @function destroy

return Hole
