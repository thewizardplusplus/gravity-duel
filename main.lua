local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local mlib = require("mlib")
local baton = require("baton")
local tick = require("tick")
local typeutils = require("typeutils")
local window = require("window")
local drawing = require("drawing")
local statsfactory = require("stats.statsfactory")
local Scene = require("objects.scene")
local Ui = require("objects.ui")
local Stats = require("objects.stats")
require("gooi")
require("luatable")
require("compat52")

local screen = nil -- models.Rectangle
local scene = nil -- objects.Scene
local ui = nil -- objects.Ui
local keys = nil -- baton.Player
local stats = nil -- objects.Stats
local best_stats = nil -- objects.BestStats
local stats_storage = nil -- stats.StatsStorage

local function _load_keys(path)
  assert(type(path) == "string")

  local data, loading_err = typeutils.load_json(path, {
    type = "object",
    properties = {
      moved_left = {["$ref"] = "#/definitions/source_group"},
      moved_right = {["$ref"] = "#/definitions/source_group"},
      moved_top = {["$ref"] = "#/definitions/source_group"},
      moved_bottom = {["$ref"] = "#/definitions/source_group"},
      rotated_left = {["$ref"] = "#/definitions/source_group"},
      rotated_right = {["$ref"] = "#/definitions/source_group"},
      impulse = {["$ref"] = "#/definitions/source_group"},
    },
    required = {
      "moved_left",
      "moved_right",
      "moved_top",
      "moved_bottom",
      "rotated_left",
      "rotated_right",
      "impulse",
    },
    definitions = {
      source_group = {
        type = "array",
        items = {type = "string", pattern = "^%a+:%w+$"},
        minItems = 1,
      },
    },
  })
  if not data then
    return nil, "unable to load the keys: " .. loading_err
  end

  return baton.new({
    controls = data,
    pairs = {
      moved = {"moved_left", "moved_right", "moved_top", "moved_bottom"},
    },
  })
end

local function _add_impulse()
  scene:add_impulse(screen)
  stats:add_impulse()
end

local function _repeat(period, handler)
  assert(typeutils.is_positive_number(period))
  assert(typeutils.is_callable(handler))

  tick.delay(handler, 0)
  tick.recur(handler, period)
end

function love.load()
  math.randomseed(os.time())
  love.setDeprecationOutput(true)
  assert(window.enter_fullscreen())

  screen = window.create_screen()
  drawing.set_font(screen)

  scene = Scene:new(screen)

  ui = Ui:new(screen, _add_impulse)
  keys = assert(_load_keys("keys_config.json"))

  stats = Stats:new()
  stats_storage = assert(statsfactory.create_stats_storage("stats-db"))
  best_stats = stats_storage:get_stats()

  _repeat(2.5, function()
    scene:add_target(screen, function(lifes)
      assert(typeutils.is_positive_number(lifes))

      stats:hit_target(lifes)
    end)
  end)
  _repeat(2.5, function() scene:add_hole(screen) end)
end

function love.draw()
  scene:draw(screen, ui:center_position())
  gooi.draw()
  drawing.draw_drawables(screen, {stats, best_stats})
end

function love.update(dt)
  scene:update(screen)
  tick.update(dt)

  local player_move_direction = mlib.vec2.add(
    mlib.vec2.new(ui:player_move_direction()),
    mlib.vec2.new(keys:get("moved"))
  )

  local player_keys_angle_factor = 0.6
  local player_angle_delta = ui:player_angle_delta()
  if keys:down("rotated_left") then
    player_angle_delta = player_angle_delta - player_keys_angle_factor * dt
  end
  if keys:down("rotated_right") then
    player_angle_delta = player_angle_delta + player_keys_angle_factor * dt
  end

  scene:control_player(
    screen,
    player_move_direction.x,
    player_move_direction.y,
    player_angle_delta
  )

  gooi.update(dt)
  keys:update()
  if
    keys:pressed("impulse")
    and mlib.vec2.len(player_move_direction) == 0
    and player_angle_delta == 0
  then
    _add_impulse()
  end

  local was_updated = best_stats:update(stats)
  if was_updated then
    stats_storage:store_stats(best_stats)
  end
end

function love.resize()
  screen = window.create_screen()
  drawing.set_font(screen)

  scene:destroy()
  scene = Scene:new(screen)

  ui:destroy()
  ui = Ui:new(screen, _add_impulse)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

function love.mousepressed()
  gooi.pressed()
end

function love.mousereleased()
  gooi.released()
end
