local luaunit = require("luaunit")
local Label = require("models.label")

-- luacheck: globals TestLabel
TestLabel = {}

function TestLabel.test_tostring()
  local label = Label:new("title", "value")
  local text = tostring(label)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"Label\"," ..
    [[title = "title",]] ..
    [[value = "value"]] ..
  "}")
end
