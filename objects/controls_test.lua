local luaunit = require("luaunit")
local json = require("luaserialization.json")
local Controls = require("objects.controls")
require("luatable")

local _original_love = nil

-- luacheck: globals TestControls
TestControls = {}

function TestControls.setUp()
  _original_love = love

  love = {
    filesystem = {
      read = function()
        luaunit.fail("the function should not be called")
      end,
    },
  }
end

function TestControls.tearDown()
  love = _original_love
end

function TestControls.test_from_json_success()
  local controls, err = json.from_json(
    [[{
      "moved_left": ["key:a"],
      "moved_right": ["key:d"],
      "moved_top": ["key:w"],
      "moved_bottom": ["key:s"],
      "rotated_left": ["key:left", "key:j"],
      "rotated_right": ["key:right", "key:l"],
      "impulse": ["key:return", "key:space"]
    }]],
    Controls.controls_schema()
  )

  luaunit.assert_is_table(controls)
  luaunit.assert_equals(controls.moved_left, {"key:a"})
  luaunit.assert_equals(controls.moved_right, {"key:d"})
  luaunit.assert_equals(controls.moved_top, {"key:w"})
  luaunit.assert_equals(controls.moved_bottom, {"key:s"})
  luaunit.assert_equals(controls.rotated_left, {"key:left", "key:j"})
  luaunit.assert_equals(controls.rotated_right, {"key:right", "key:l"})
  luaunit.assert_equals(controls.impulse, {"key:return", "key:space"})

  luaunit.assert_is_nil(err)
end

function TestControls.test_from_json_error()
  local controls, err = json.from_json(
    [[{
      "moved_left": "invalid",
      "moved_right": ["key:d"],
      "moved_top": ["key:w"],
      "moved_bottom": ["key:s"],
      "rotated_left": ["key:left", "key:j"],
      "rotated_right": ["key:right", "key:l"],
      "impulse": ["key:return", "key:space"]
    }]],
    Controls.controls_schema()
  )

  luaunit.assert_is_nil(controls)

  luaunit.assert_is_string(err)
  luaunit.assert_str_matches(
    err,
    "^invalid data: " ..
      [[property "moved_left" validation failed: ]] ..
      "wrong type: " ..
      "expected array, got string$"
  )
end

function TestControls.test_load_keys_success()
  local controls_path = "controls.json"

  love.filesystem.read = function(path)
    luaunit.assert_equals(path, controls_path)

    return [[{
      "moved_left": ["key:a"],
      "moved_right": ["key:d"],
      "moved_top": ["key:w"],
      "moved_bottom": ["key:s"],
      "rotated_left": ["key:left", "key:j"],
      "rotated_right": ["key:right", "key:l"],
      "impulse": ["key:return", "key:space"]
    }]]
  end

  local keys, err = Controls.load_keys(controls_path)

  luaunit.assert_is_table(keys)
  luaunit.assert_is_table(keys.config)
  luaunit.assert_is_table(keys.config.controls)
  luaunit.assert_equals(keys.config.controls.moved_left, {"key:a"})
  luaunit.assert_equals(keys.config.controls.moved_right, {"key:d"})
  luaunit.assert_equals(keys.config.controls.moved_top, {"key:w"})
  luaunit.assert_equals(keys.config.controls.moved_bottom, {"key:s"})
  luaunit.assert_equals(keys.config.controls.rotated_left, {
    "key:left",
    "key:j",
  })
  luaunit.assert_equals(keys.config.controls.rotated_right, {
    "key:right",
    "key:l",
  })
  luaunit.assert_equals(keys.config.controls.impulse, {
    "key:return",
    "key:space",
  })

  luaunit.assert_is_table(keys.config.pairs)
  luaunit.assert_equals(keys.config.pairs.moved, {
    "moved_left",
    "moved_right",
    "moved_top",
    "moved_bottom",
  })

  luaunit.assert_is_nil(err)
end

function TestControls.test_load_keys_error()
  local controls_path = "controls.json"

  love.filesystem.read = function(path)
    luaunit.assert_equals(path, controls_path)

    return nil, "file not found"
  end

  local keys, err = Controls.load_keys(controls_path)

  luaunit.assert_is_nil(keys)

  luaunit.assert_is_string(err)
  luaunit.assert_equals(
    err,
    "unable to load the controls: " ..
      "unable to read the text: " ..
      "file not found"
  )
end
