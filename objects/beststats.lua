---
-- @classmod BestStats

local middleclass = require("middleclass")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")

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
  local font_size = grid_step / 5
  love.graphics.setFont(love.graphics.newFont(font_size))

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

return BestStats
