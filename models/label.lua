-- luacheck: no max comment line length

---
-- @classmod Label

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")

---
-- @table instance
-- @tfield string title
-- @tfield string value

local Label = middleclass("Label")
Label:include(Nameable)
Label:include(Stringifiable)

---
-- @function new
-- @tparam string title
-- @tparam any value it will be cast to a string with the tostring() function
-- @treturn Label
function Label:initialize(title, value)
  assertions.is_string(title)

  self.title = title
  self.value = tostring(value)
end

---
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Label:__data()
  return {
    title = self.title,
    value = self.value,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

return Label
