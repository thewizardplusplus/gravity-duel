-- luacheck: no max comment line length

---
-- @classmod BestStats

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")
local Rectangle = require("models.rectangle")
local Label = require("models.label")
local Stats = require("objects.stats")
local drawing = require("drawing")

---
-- @table instance
-- @tfield number impulse_accuracy [0, ∞)
-- @tfield number destroyed_targets [0, ∞)

local BestStats = middleclass("BestStats")
BestStats:include(Nameable)
BestStats:include(Stringifiable)

---
-- @function new
-- @tparam number impulse_accuracy [0, ∞)
-- @tparam number destroyed_targets [0, ∞)
-- @treturn BestStats
function BestStats:initialize(impulse_accuracy, destroyed_targets)
  assertions.is_number(impulse_accuracy)
  assertions.is_number(destroyed_targets)

  self.impulse_accuracy = impulse_accuracy
  self.destroyed_targets = destroyed_targets
end

---
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function BestStats:__data()
  return {
    impulse_accuracy = self.impulse_accuracy,
    destroyed_targets = self.destroyed_targets,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

---
-- @tparam Rectangle screen
function BestStats:draw(screen)
  assertions.is_instance(screen, Rectangle)

  local x = screen.width - 0.6 * screen.height
  local y = screen.height / 16
  love.graphics.setColor(0, 0.5, 0)
  drawing.draw_labels(screen, x, y, {
    Label:new(
      "Best accuracy",
      string.format("%.2f%%", 100 * self.impulse_accuracy)
    ),
    Label:new("Best targets", self.destroyed_targets),
  })
end

---
-- @tparam Stats stats
-- @treturn bool was updated
function BestStats:update(stats)
  assertions.is_instance(stats, Stats)

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
