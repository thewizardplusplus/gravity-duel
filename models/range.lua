-- luacheck: no max comment line length

---
-- @classmod Range

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")

---
-- @table instance
-- @tfield number minimum
-- @tfield number maximum [minimum, ∞)

local Range = middleclass("Range")
Range:include(Nameable)
Range:include(Stringifiable)

---
-- @function new
-- @tparam number minimum
-- @tparam number maximum [minimum, ∞)
-- @treturn Range
function Range:initialize(minimum, maximum)
  assertions.is_number(minimum)
  assertions.is_number(maximum)

  self.minimum = minimum
  self.maximum = maximum
end

---
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Range:__data()
  return {
    minimum = self.minimum,
    maximum = self.maximum,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

return Range
