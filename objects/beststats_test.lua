local luaunit = require("luaunit")
local checks = require("luatypechecks.checks")
local json = require("luaserialization.json")
local BestStats = require("objects.beststats")

-- luacheck: globals TestBestStats
TestBestStats = {}

function TestBestStats.test_from_json_success()
  local best_stats, err = json.from_json(
    [[{
      "__name": "BestStats",
      "impulse_accuracy": 10,
      "destroyed_targets": 20
    }]],
    BestStats.schema(),
    { BestStats = BestStats.from_options }
  )

  luaunit.assert_is_table(best_stats)
  luaunit.assert_is_true(checks.is_instance(best_stats, BestStats))

  luaunit.assert_is_number(best_stats.impulse_accuracy)
  luaunit.assert_equals(best_stats.impulse_accuracy, 10)

  luaunit.assert_is_number(best_stats.destroyed_targets)
  luaunit.assert_equals(best_stats.destroyed_targets, 20)

  luaunit.assert_is_nil(err)
end

function TestBestStats.test_from_json_error()
  local best_stats, err = json.from_json(
    [[{
      "__name": "BestStats",
      "impulse_accuracy": "invalid",
      "destroyed_targets": 20
    }]],
    BestStats.schema(),
    { BestStats = BestStats.from_options }
  )

  luaunit.assert_is_nil(best_stats)

  luaunit.assert_is_string(err)
  luaunit.assert_str_matches(
    err,
    "^invalid data: " ..
      [[property "impulse_accuracy" validation failed: ]] ..
      "wrong type: " ..
      "expected number, got string$"
  )
end

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
