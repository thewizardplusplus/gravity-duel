local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local tick = require("tick")
local typeutils = require("typeutils")
local window = require("window")
local drawing = require("drawing")
local miscutils = require("miscutils")
local Scene = require("objects.scene")
local Controls = require("objects.controls")
local StatsManager = require("stats.statsmanager")
require("gooi")
require("luatable")
require("compat52")

local screen = nil -- models.Rectangle
local scene = nil -- objects.Scene
local controls = nil -- objects.Controls
local stats_manager = nil -- stats.StatsManager

local function _add_impulse()
  scene:add_impulse(screen)
  stats_manager:add_impulse()
end

function love.load()
  math.randomseed(os.time())
  love.setDeprecationOutput(true)
  assert(window.enter_fullscreen())

  screen = window.create_screen()
  drawing.set_font(screen)

  scene = Scene:new(screen)
  controls = Controls:new(screen, "keys_config.json", _add_impulse)
  stats_manager = StatsManager:new("stats-db")

  miscutils.repeat_at_intervals(2.5, function()
    scene:add_target(screen, function(lifes)
      assert(typeutils.is_positive_number(lifes))

      stats_manager:hit_target(lifes)
    end)
  end)
  miscutils.repeat_at_intervals(2.5, function() scene:add_hole(screen) end)
end

function love.draw()
  scene:draw(screen, controls:center_position())
  gooi.draw()
  stats_manager:draw(screen)
end

function love.update(dt)
  scene:update(screen)
  controls:update()
  stats_manager:update()
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
