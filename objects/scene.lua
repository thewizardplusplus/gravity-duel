---
-- @classmod Scene

local middleclass = require("middleclass")
local windfield = require("windfield")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Vector2D = require("luamath.vector2d")
local BoundingBox = require("luamath.models.boundingbox")
local miscutils = require("miscutils")
local Rectangle = require("models.rectangle")
local Target = require("objects.target")
local Hole = require("objects.hole")
local Player = require("objects.player")
local Impulse = require("objects.impulse")
local drawing = require("drawing")

local Scene = middleclass("Scene")

---
-- @table instance
-- @tfield windfield.World _world
-- @tfield objects.Player _player
-- @tfield {objects.Target,...} _targets
-- @tfield {objects.Hole,...} _holes
-- @tfield {objects.Impulse,...} _impulses

---
-- @function new
-- @tparam Rectangle screen
-- @treturn Scene
function Scene:initialize(screen)
  assertions.is_instance(screen, Rectangle)

  self._world = windfield.newWorld(0, 0, true)
  self._world:addCollisionClass("Player")
  self._world:addCollisionClass("Impulse", {ignores = {"Player", "Impulse"}})

  self._player = Player:new(self._world, screen)

  self._targets = table.new()
  self._holes = table.new()
  self._impulses = table.new()
end

---
-- @tparam Rectangle screen
-- @tparam {[string]=Font,...} fonts
-- @tparam Vector2D center_position
function Scene:draw(screen, fonts, center_position)
  assertions.is_instance(screen, Rectangle)
  assertions.is_table(fonts, checks.is_string, function(font)
    return type(font) == "userdata"
  end)
  assertions.is_instance(center_position, Vector2D)

  local camera_offset = center_position - self._player:position()
  drawing.draw_with_transformations(function()
    love.graphics.translate(center_position.x, center_position.y)
    love.graphics.rotate(-self._player:angle(true))
    love.graphics.scale(0.75, 0.75)
    love.graphics.translate(-center_position.x, -center_position.y)
    love.graphics.translate(camera_offset.x, camera_offset.y)

    local drawables =
      self._holes .. self._targets .. self._impulses .. {self._player}
    drawing.draw_drawables(screen, fonts, drawables)
  end)
end

---
-- @tparam Rectangle screen
-- @tparam func life_decrement_handler func(lifes: number): nil
function Scene:add_target(screen, life_decrement_handler)
  assertions.is_instance(screen, Rectangle)
  assertions.is_function(life_decrement_handler)

  local target =
    Target:new(self._world, screen, self._player, life_decrement_handler)
  table.insert(self._targets, target)
end

---
-- @tparam Rectangle screen
function Scene:add_hole(screen)
  assertions.is_instance(screen, Rectangle)

  local kind = math.random() < 0.5 and "black" or "white"
  local hole = Hole:new(kind, self._world, screen, self._player)
  table.insert(self._holes, hole)
end

---
-- @tparam Rectangle screen
function Scene:add_impulse(screen)
  assertions.is_instance(screen, Rectangle)

  local impulse = Impulse:new(self._world, screen, self._player)
  table.insert(self._impulses, impulse)
end

---
-- @tparam Rectangle screen
function Scene:update(screen)
  assertions.is_instance(screen, Rectangle)

  local dt = love.timer.getDelta()
  self._world:update(dt)
  self._player:reset_autorotation()

  table.eachi(self._targets .. self._holes, function(updatable)
    assertions.is_table(updatable)

    updatable:update()
  end)
  self._targets = miscutils.filter_destroyables(self._targets, Target.alive)
  self._holes = miscutils.filter_destroyables(self._holes, Hole.alive)

  self._impulses =
    miscutils.filter_destroyables(self._impulses, function(impulse)
      assertions.is_instance(impulse, Impulse)

      local hit = impulse:hit()
      if hit then
        return false
      end

      local distance_to_player = impulse:vector_to(self._player):length()
      if distance_to_player > 10 * screen:grid_step() then
        return false
      end

      return true
    end)
  table.eachi(self._impulses, function(impulse)
    assertions.is_instance(impulse, Impulse)

    table.eachi(self._holes, function(hole)
      assertions.is_instance(hole, Hole)

      impulse:apply_hole(screen, hole)
    end)
  end)
end

---
-- @tparam BoundingBox screen
-- @tparam Vector2D move_direction
-- @tparam number angle_delta
function Scene:control_player(screen, move_direction, angle_delta)
  assertions.is_instance(screen, BoundingBox)
  assertions.is_instance(move_direction, Vector2D)
  assertions.is_number(angle_delta)

  if angle_delta == 0 then
    self._player:set_velocity(screen, move_direction)
  else
    self._player:set_velocity(screen, Vector2D.ZERO)
  end

  if move_direction == Vector2D.ZERO then
    self._player:rotate(angle_delta)
  end
end

---
-- @function destroy
function Scene:destroy()
  miscutils.filter_destroyables(
    self._targets .. self._holes .. self._impulses
      .. {self._player, self._world},
    function() return false end
  )
end

return Scene
