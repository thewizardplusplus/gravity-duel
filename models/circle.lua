-- luacheck: no max comment line length

---
-- @classmod Circle

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")
local Vector2D = require("luamath.vector2d")

local Circle = middleclass("Circle")
Circle:include(Nameable)
Circle:include(Stringifiable)

---
-- @table instance
-- @tfield Vector2D center
-- @tfield number radius [0, ∞)

---
-- @function new
-- @tparam Vector2D center
-- @tparam number radius [0, ∞)
-- @treturn Circle
function Circle:initialize(center, radius)
  assertions.is_instance(center, Vector2D)
  assertions.is_number(radius)

  self.center = center
  self.radius = radius
end

---
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Circle:__data()
  return {
    center = self.center,
    radius = self.radius,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

return Circle
