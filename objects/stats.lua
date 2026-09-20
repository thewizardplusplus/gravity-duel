-- luacheck: no max comment line length

---
-- @classmod Stats

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")
local Vector2D = require("luamath.vector2d")
local Color = require("luamath.models.color")
local BoundingBox = require("luamath.models.boundingbox")
local Label = require("models.label")
local drawing = require("drawing")

local Stats = middleclass("Stats")
Stats:include(Nameable)
Stats:include(Stringifiable)

---
-- @table instance
-- @tfield number performed_impulses [0, ∞)
-- @tfield number hit_targets [0, ∞)
-- @tfield number destroyed_targets [0, ∞)

---
-- @function new
-- @treturn Stats
function Stats:initialize()
  self.performed_impulses = 0
  self.hit_targets = 0
  self.destroyed_targets = 0
end

---
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Stats:__data()
  return {
    performed_impulses = self.performed_impulses,
    hit_targets = self.hit_targets,
    destroyed_targets = self.destroyed_targets,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

---
-- @treturn number [0, 1]
function Stats:impulse_accuracy()
  return self.performed_impulses ~= 0
    and self.hit_targets / self.performed_impulses
    or 0
end

---
-- @tparam BoundingBox screen
-- @tparam {[string]=Font,...} fonts
function Stats:draw(screen, fonts)
  assertions.is_instance(screen, BoundingBox)
  assertions.is_table(fonts, checks.is_string, function(font)
    return type(font) == "userdata"
  end)

  local margin = screen:size().height / 16
  local position = Vector2D:new(margin, margin)
  love.graphics.setColor(Color.WHITE:channels())
  drawing.draw_labels(screen, fonts, position, {
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
  assertions.is_number(target_lifes)

  self.hit_targets = self.hit_targets + 1
  if target_lifes == 0 then
    self.destroyed_targets = self.destroyed_targets + 1
  end
end

return Stats
