---
-- @classmod Hole

local middleclass = require("middleclass")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")
local Color = require("models.color")
local Range = require("models.range")
local TemporaryCircle = require("objects.temporarycircle")
local Player = require("objects.player")

---
-- @table instance
-- @tfield number _initial_lifetime [0, ∞)
-- @tfield number _rest_lifetime
-- @tfield number _radius [0, ∞)
-- @tfield number _border_width [0, ∞)
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
    border_color = Color:new(0.15, 0.15, 0.15)
  elseif kind == "white" then
    fill_color = Color:new(0.75, 0.75, 0.75)
    border_color = Color:new(0.55, 0.55, 0.55)
  end

  TemporaryCircle.initialize(
    self,
    5,
    world,
    player,
    Range:new(2 * screen:grid_step(), 	5 * screen:grid_step()),
    Range:new(-math.pi, math.pi),
    3 * screen:grid_step() / 4,
    screen:grid_step() / 10,
    fill_color,
    border_color
  )

  self._kind = kind
end

---
-- @function position
-- @treturn number x
-- @treturn number y

---
-- @function alive
-- @treturn bool

---
-- @treturn "black"|"white"
function Hole:kind()
  return self._kind
end

---
-- @function draw
-- @tparam Rectangle screen

---
-- @function update

---
-- @function destroy

return Hole
