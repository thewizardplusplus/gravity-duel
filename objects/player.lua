---
-- @classmod Player

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Vector2D = require("luamath.vector2d")
local Matrix3x3 = require("luamath.matrix3x3")
local Size = require("luamath.models.size")
local BoundingBox = require("luamath.models.boundingbox")
local Rectangle = require("models.rectangle")
local Collider = require("objects.collider")
local physics = require("physics")
local drawing = require("drawing")

local Player = middleclass("Player")
Player:include(Collider)

---
-- @table instance
-- @tfield windfield.Collider _collider

---
-- @function new
-- @tparam windfield.World world
-- @tparam Rectangle screen
-- @treturn Player
function Player:initialize(world, screen)
  assertions.is_table(world)
  assertions.is_instance(screen, Rectangle)

  local grid_step = screen:grid_step()
  local collider_size = Size:new(grid_step + grid_step / 3, grid_step)
  local collider_position = screen:center() - collider_size / 2
  self._collider =
    physics.make_rectangle_collider(
      world,
      "dynamic",
      BoundingBox.from_position_and_size(collider_position, collider_size)
    )
  self._collider:setCollisionClass("Player")
  self._collider:setAngle(-math.pi / 2)
  self._collider:setMass(1 + 2 / 9)
end

---
-- @function position
-- @treturn Vector2D

---
-- @tparam[opt=false] bool corrected_for_ui
-- @treturn number
--   [-math.pi, math.pi] or [0, 2 * math.pi] (if it is corrected for UI)
function Player:angle(corrected_for_ui)
  corrected_for_ui = corrected_for_ui or false

  assertions.is_boolean(corrected_for_ui)

  local angle = self._collider:getAngle()
  if corrected_for_ui then
    angle = angle + math.pi / 2
  end

  return angle
end

---
-- @tparam[opt=Vector2D.BASIS_X] Vector2D base_direction
-- @tparam[optchain=0] number additional_angle
-- @tparam[optchain=false] bool corrected_for_ui
-- @treturn Vector2D
function Player:direction(base_direction, additional_angle, corrected_for_ui)
  base_direction = base_direction or Vector2D.BASIS_X
  additional_angle = additional_angle or 0
  corrected_for_ui = corrected_for_ui or false

  assertions.is_instance(base_direction, Vector2D)
  assertions.is_number(additional_angle)
  assertions.is_boolean(corrected_for_ui)

  local direction_angle = self:angle(corrected_for_ui) + additional_angle
  return base_direction * Matrix3x3.rotate(direction_angle)
end

---
-- @tparam Rectangle screen
function Player:draw(screen)
  assertions.is_instance(screen, Rectangle)

  local grid_step = screen:grid_step()
  love.graphics.setColor(0.5, 0.5, 0.5)
  drawing.draw_collider(self._collider, function()
    drawing.draw_rectangle("fill", BoundingBox.from_position_and_size(
      Vector2D:new(-grid_step / 2 - grid_step / 6, -grid_step / 2),
      Size:new(grid_step, grid_step)
    ))
    drawing.draw_rectangle("fill", BoundingBox.from_position_and_size(
      Vector2D:new(grid_step / 2 - grid_step / 6, -grid_step / 2),
      Size:new(grid_step / 3, grid_step / 3)
    ))
    drawing.draw_rectangle("fill", BoundingBox.from_position_and_size(
      Vector2D:new(
        grid_step / 2 - grid_step / 6,
        -grid_step / 2 + 2 * grid_step / 3
      ),
      Size:new(grid_step / 3, grid_step / 3)
    ))
  end)
end

---
-- @tparam BoundingBox screen
-- @tparam Vector2D ui_direction
function Player:set_velocity(screen, ui_direction)
  assertions.is_instance(screen, BoundingBox)
  assertions.is_instance(ui_direction, Vector2D)

  local player_speed = 10 * screen:size().height
  local player_direction = self:direction(ui_direction, nil, true)
  local velocity = player_direction * (player_speed * love.timer.getDelta())
  self._collider:setLinearVelocity(velocity.x, velocity.y)
end

---
-- @tparam number angle_delta
function Player:rotate(angle_delta)
  assertions.is_number(angle_delta)

  self._collider:setAngle(self._collider:getAngle() + angle_delta)
end

---
-- @function reset_autorotation
function Player:reset_autorotation()
  self._collider:setAngularVelocity(0)
end

---
-- @function destroy

return Player
