---
-- @classmod Stats

local middleclass = require("middleclass")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")
local Label = require("models.label")
local drawing = require("drawing")

---
-- @table instance
-- @tfield number performed_impulses [0, ∞)
-- @tfield number hit_targets [0, ∞)
-- @tfield number destroyed_targets [0, ∞)

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

  local margin = screen.height / 16
  love.graphics.setColor(1, 1, 1)
  drawing.draw_labels(screen, margin, margin, {
    Label:new("Impulses", self.performed_impulses),
    Label:new("Hits", self.hit_targets),
    Label:new(
      "Accuracy",
      string.format("%.2f%%", 100 * self:impulse_accuracy())
    ),
    Label:new("Targets", self.destroyed_targets),
  })
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
