---
-- @classmod Label

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")

---
-- @table instance
-- @tfield string title
-- @tfield string value

local Label = middleclass("Label")

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

return Label
