-- luacheck: no max comment line length

---
-- @classmod Color

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")

---
-- @table instance
-- @tfield number red [0, 1]
-- @tfield number green [0, 1]
-- @tfield number blue [0, 1]

local Color = middleclass("Color")
Color:include(Nameable)
Color:include(Stringifiable)

---
-- @function new
-- @tparam number red [0, 1]
-- @tparam number green [0, 1]
-- @tparam number blue [0, 1]
-- @treturn Color
function Color:initialize(red, green, blue)
  assertions.is_number(red)
  assertions.is_number(green)
  assertions.is_number(blue)

  self.red = red
  self.green = green
  self.blue = blue
end

---
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Color:__data()
  return {
    red = self.red,
    green = self.green,
    blue = self.blue,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

---
-- @treturn {number,number,number}
--   red, green and blue values in the range [0, 1]
function Color:channels()
  return {self.red, self.green, self.blue}
end

return Color
