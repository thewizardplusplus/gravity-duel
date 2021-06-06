---
-- @classmod BestStats

local middleclass = require("middleclass")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")
local Stats = require("objects.stats")

---
-- @table instance
-- @tfield number impulse_accuracy
-- @tfield number destroyed_targets

local BestStats = middleclass("BestStats")

---
-- @function new
-- @tfield number impulse_accuracy [0, ∞)
-- @tfield number destroyed_targets [0, ∞)
-- @treturn BestStats
function BestStats:initialize(impulse_accuracy, destroyed_targets)
  assert(typeutils.is_positive_number(impulse_accuracy))
  assert(typeutils.is_positive_number(destroyed_targets))

  self.impulse_accuracy = impulse_accuracy
  self.destroyed_targets = destroyed_targets
end

---
-- @tparam Rectangle screen
function BestStats:draw(screen)
  assert(typeutils.is_instance(screen, Rectangle))

  local grid_step = screen.height / 4
  local margin = grid_step / 4
  love.graphics.setColor(0, 0.5, 0)
  love.graphics.print(
    "Best accuracy: " .. string.format("%.2f%%", 100 * self.impulse_accuracy),
    screen.width - 0.6 * screen.height,
    margin
  )
  love.graphics.print(
    "Best targets: " .. tostring(self.destroyed_targets),
    screen.width - 0.6 * screen.height,
    margin + grid_step / 4
  )
end

---
-- @tparam Stats stats
-- @treturn bool was updated
function BestStats:update(stats)
  assert(typeutils.is_instance(stats, Stats))

  local was_updated = false
  local preliminary_impulses = 50
  if
    stats.performed_impulses > preliminary_impulses
      and self.impulse_accuracy < stats:impulse_accuracy()
  then
    self.impulse_accuracy = stats:impulse_accuracy()
    was_updated = true
  end
  if self.destroyed_targets < stats.destroyed_targets then
    self.destroyed_targets = stats.destroyed_targets
    was_updated = true
  end

  return was_updated
end

return BestStats
