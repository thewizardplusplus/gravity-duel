local luaunit = require("luaunit")
local BestStats = require("objects.beststats")

-- luacheck: globals TestBestStats
TestBestStats = {}

function TestBestStats.test_tostring()
  local best_stats = BestStats:new(10, 20)
  local text = tostring(best_stats)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"BestStats\"," ..
    "destroyed_targets = 20," ..
    "impulse_accuracy = 10" ..
  "}")
end
