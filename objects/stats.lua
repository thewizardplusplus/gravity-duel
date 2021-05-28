---
-- @classmod Stats

local middleclass = require("middleclass")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")

---
-- @table instance
-- @tfield number _performed_impulses
-- @tfield number _hit_targets
-- @tfield number _destroyed_targets

local Stats = middleclass("Stats")

---
-- @function new
-- @treturn Stats
function Stats:initialize()
  self._performed_impulses = 0
  self._hit_targets = 0
  self._destroyed_targets = 0
end

---
-- @tparam Rectangle screen
function Stats:draw(screen)
  assert(typeutils.is_instance(screen, Rectangle))

  local grid_step = screen.height / 4
  local font_size = grid_step / 5
  love.graphics.setFont(love.graphics.newFont(font_size))

  local margin = grid_step / 4
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(
    "Impulses: " .. tostring(self._performed_impulses),
    margin,
    margin
  )
  love.graphics.print(
    "Hits: " .. tostring(self._hit_targets),
    margin,
    margin + grid_step / 4
  )
  if self._performed_impulses ~= 0 then
    love.graphics.print(
      "Accuracy: " .. string.format("%.2f%%", 100 * self._hit_targets / self._performed_impulses),
      margin,
      margin + 2 * grid_step / 4
    )
  end
  love.graphics.print(
    "Targets: " .. tostring(self._destroyed_targets),
    margin,
    margin + (self._performed_impulses ~= 0 and 3 or 2) * grid_step / 4
  )
end

---
-- @function add_impulse
function Stats:add_impulse()
  self._performed_impulses = self._performed_impulses + 1
end

---
-- @tparam number target_lifes [0, ∞)
function Stats:hit_target(target_lifes)
  assert(typeutils.is_positive_number(target_lifes))

  self._hit_targets = self._hit_targets + 1
  if target_lifes == 0 then
    self._destroyed_targets = self._destroyed_targets + 1
  end
end

return Stats
