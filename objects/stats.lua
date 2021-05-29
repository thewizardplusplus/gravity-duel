---
-- @classmod Stats

local middleclass = require("middleclass")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")

---
-- @table instance
-- @tfield number performed_impulses
-- @tfield number hit_targets
-- @tfield number destroyed_targets

local Stats = middleclass("Stats")

---
-- @function new
-- @treturn Stats
function Stats:initialize()
  self.performed_impulses = 0
  self.hit_targets = 0
  self.destroyed_targets = 0
end

---
-- @treturn number [0, 1]
function Stats:impulse_accuracy()
  return self.performed_impulses ~= 0
    and self.hit_targets / self.performed_impulses
    or 0
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
    "Impulses: " .. tostring(self.performed_impulses),
    margin,
    margin
  )
  love.graphics.print(
    "Hits: " .. tostring(self.hit_targets),
    margin,
    margin + grid_step / 4
  )
  love.graphics.print(
    "Accuracy: " .. string.format("%.2f%%", 100 * self:impulse_accuracy()),
    margin,
    margin + 2 * grid_step / 4
  )
  love.graphics.print(
    "Targets: " .. tostring(self.destroyed_targets),
    margin,
    margin + 3 * grid_step / 4
  )
end

---
-- @function add_impulse
function Stats:add_impulse()
  self.performed_impulses = self.performed_impulses + 1
end

---
-- @tparam number target_lifes [0, ∞)
function Stats:hit_target(target_lifes)
  assert(typeutils.is_positive_number(target_lifes))

  self.hit_targets = self.hit_targets + 1
  if target_lifes == 0 then
    self.destroyed_targets = self.destroyed_targets + 1
  end
end

return Stats
