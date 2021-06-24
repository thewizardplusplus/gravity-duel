local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local tick = require("tick")
local typeutils = require("typeutils")
local window = require("window")
local drawing = require("drawing")
local miscutils = require("miscutils")
local statsfactory = require("stats.statsfactory")
local Scene = require("objects.scene")
local Controls = require("objects.controls")
local Stats = require("objects.stats")
require("gooi")
require("luatable")
require("compat52")

local screen = nil -- models.Rectangle
local scene = nil -- objects.Scene
local controls = nil -- objects.Controls
local stats = nil -- objects.Stats
local best_stats = nil -- objects.BestStats
local stats_storage = nil -- stats.StatsStorage

local function _add_impulse()
  scene:add_impulse(screen)
  stats:add_impulse()
end

function love.load()
  math.randomseed(os.time())
  love.setDeprecationOutput(true)
  assert(window.enter_fullscreen())

  screen = window.create_screen()
  drawing.set_font(screen)

  scene = Scene:new(screen)
  controls = Controls:new(screen, "keys_config.json", _add_impulse)

  stats = Stats:new()
  stats_storage = assert(statsfactory.create_stats_storage("stats-db"))
  best_stats = stats_storage:get_stats()

  miscutils.repeat_at_intervals(2.5, function()
    scene:add_target(screen, function(lifes)
      assert(typeutils.is_positive_number(lifes))

      stats:hit_target(lifes)
    end)
  end)
  miscutils.repeat_at_intervals(2.5, function() scene:add_hole(screen) end)
end

function love.draw()
  scene:draw(screen, controls:center_position())
  gooi.draw()
  drawing.draw_drawables(screen, {stats, best_stats})
end

function love.update(dt)
  scene:update(screen)
  controls:update()
  tick.update(dt)
  gooi.update(dt)

  local player_move_direction_x, player_move_direction_y =
    controls:player_move_direction()
  scene:control_player(
    screen,
    player_move_direction_x,
    player_move_direction_y,
    controls:player_angle_delta()
  )

  local was_updated = best_stats:update(stats)
  if was_updated then
    stats_storage:store_stats(best_stats)
  end
end

function love.resize()
  screen = window.create_screen()
  drawing.set_font(screen)

  miscutils.filter_destroyables({scene, controls}, function() return false end)
  scene = Scene:new(screen)
  controls = Controls:new(screen, "keys_config.json", _add_impulse)
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
