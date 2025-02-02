-- luacheck: no max comment line length

---
-- @classmod Circle

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")

---
-- @table instance
-- @tfield number x
-- @tfield number y
-- @tfield number radius [0, ∞)

local Circle = middleclass("Circle")
Circle:include(Nameable)
Circle:include(Stringifiable)

---
-- @function new
-- @tparam number x
-- @tparam number y
-- @tparam number radius [0, ∞)
-- @treturn Circle
function Circle:initialize(x, y, radius)
  assertions.is_number(x)
  assertions.is_number(y)
  assertions.is_number(radius)

  self.x = x
  self.y = y
  self.radius = radius
end

---
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Circle:__data()
  return {
    x = self.x,
    y = self.y,
    radius = self.radius,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

return Circle
