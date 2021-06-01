---
-- @classmod Player

local middleclass = require("middleclass")
local mlib = require("mlib")
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
-- @tparam[opt=false] bool corrected_for_ui
-- @treturn number
function Player:angle(corrected_for_ui)
  corrected_for_ui = corrected_for_ui or false

  assert(type(corrected_for_ui) == "boolean")

  local angle = self._collider:getAngle()
  if corrected_for_ui then
    angle = angle + math.pi / 2
  end

  return angle
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
-- @tparam Rectangle screen
-- @tparam number ui_direction_x
-- @tparam number ui_direction_y
function Player:move(screen, ui_direction_x, ui_direction_y)
  assert(typeutils.is_instance(screen, Rectangle))
  assert(type(ui_direction_x) == "number")
  assert(type(ui_direction_y) == "number")

  local player_speed = 10 * screen.height
  local dt = love.timer.getDelta()
  local player_ui_direction = mlib.vec2.rotate(
    mlib.vec2.new(ui_direction_x, ui_direction_y),
    self:angle(true)
  )
  self._collider:setLinearVelocity(
    player_speed * dt * player_ui_direction.x,
    player_speed * dt * player_ui_direction.y
  )
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
-- @tparam number angle_delta
function Player:rotate(angle_delta)
  assert(type(angle_delta) == "number")

  self._collider:setAngle(self._collider:getAngle() + angle_delta)
end

---
-- @function destroy
function Player:destroy()
  self._collider:destroy()
end

return Player
