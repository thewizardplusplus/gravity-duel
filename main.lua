local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local windfield = require("windfield")
local mlib = require("mlib")
local baton = require("baton")
local tick = require("tick")
local typeutils = require("typeutils")
local drawing = require("drawing")
local factory = require("factory")
local Rectangle = require("models.rectangle")
local Target = require("objects.target")
local Hole = require("objects.hole")
local Player = require("objects.player")
local Impulse = require("objects.impulse")
local Ui = require("objects.ui")
local Stats = require("objects.stats")
require("gooi")
require("luatable")
require("compat52")

local screen = nil -- models.Rectangle
local world = nil -- windfield.World
local targets = {} -- {objects.Target,...}
local holes = {} -- {objects.Hole,...}
local player = nil -- objects.Player
local impulses = {} -- {objects.Impulse,...}
local ui = nil -- objects.Ui
local keys = nil -- baton.Player
local stats = nil -- objects.Stats
local best_stats = nil -- objects.BestStats
local stats_storage = nil -- StatsStorage

local function _enter_fullscreen()
  local os = love.system.getOS()
  local is_mobile_os = table.find({"Android", "iOS"}, os)
  if not is_mobile_os then
    return true
  end

  local ok = love.window.setFullscreen(true, "desktop")
  if not ok then
    return false, "unable to enter fullscreen"
  end

  return true
end

local function _make_screen()
  local x, y, width, height = love.window.getSafeArea()
  return Rectangle:new(x, y, width, height)
end

local function _load_keys(path)
  assert(type(path) == "string")

  local data, loading_err = typeutils.load_json(path, {
    type = "object",
    properties = {
      moved_left = {["$ref"] = "#/definitions/source_group"},
      moved_right = {["$ref"] = "#/definitions/source_group"},
      moved_top = {["$ref"] = "#/definitions/source_group"},
      moved_bottom = {["$ref"] = "#/definitions/source_group"},
    },
    required = {"moved_left", "moved_right", "moved_top", "moved_bottom"},
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

function love.load()
  math.randomseed(os.time())
  love.setDeprecationOutput(true)
  assert(_enter_fullscreen())

  screen = _make_screen()

  world = windfield.newWorld(0, 0, true)
  world:addCollisionClass("Player")
  world:addCollisionClass("Impulse", {ignores = {"Player", "Impulse"}})

  player = Player:new(world, screen)

  ui = Ui:new(screen, function()
    stats:add_impulse()

    local impulse = Impulse:new(world, screen, player)
    table.insert(impulses, impulse)
  end)
  keys = assert(_load_keys("keys_config.json"))

  stats = Stats:new()
  stats_storage = assert(factory.create_stats_storage("stats-db"))
  best_stats = stats_storage:get_stats()

  tick.recur(function()
    local target = Target:new(world, screen, player, function(lifes)
      assert(typeutils.is_positive_number(lifes))

      stats:hit_target(lifes)
    end)
    table.insert(targets, target)
  end, 2.5)

  tick.recur(function()
    local kind = math.random() < 0.5 and "black" or "white"
    local hole = Hole:new(kind, world, screen, player)
    table.insert(holes, hole)
  end, 2.5)
end

function love.draw()
  local ui_center_position_x, ui_center_position_y = ui:center_position()
  local player_position_x, player_position_y = player:position()
  love.graphics.setColor(0.5, 0.5, 0.5)
  drawing.draw_with_transformations(function()
    love.graphics.translate(ui_center_position_x, ui_center_position_y)
    love.graphics.rotate(-player:angle(true))
    love.graphics.translate(-ui_center_position_x, -ui_center_position_y)
    love.graphics.translate(
      -(player_position_x - ui_center_position_x),
      -(player_position_y - ui_center_position_y)
    )

    table.eachi(holes, function(hole)
      hole:draw(screen)
    end)

    table.eachi(targets, function(target)
      target:draw(screen)
    end)

    table.eachi(impulses, function(impulse)
      impulse:draw(screen)
    end)

    player:draw(screen)
  end)

  gooi.draw()

  stats:draw(screen)
  best_stats:draw(screen)
end

function love.update(dt)
  world:update(dt)
  tick.update(dt)

  table.eachi(targets, Target.update)
  targets = table.accept(targets, function(target)
    local alive = target:alive()
    if not alive then
      target:destroy()
    end

    return alive
  end)

  table.eachi(holes, Hole.update)
  holes = table.accept(holes, function(hole)
    local alive = hole:alive()
    if not alive then
      hole:destroy()
    end

    return alive
  end)

  impulses = table.accept(impulses, function(impulse)
    local hit = impulse:hit()
    if hit then
      impulse:destroy()
    end

    return not hit
  end)
  table.eachi(impulses, function(impulse)
    table.eachi(holes, function(hole)
      impulse:apply_hole(screen, hole)
    end)
  end)

  local player_move_direction = mlib.vec2.add(
    mlib.vec2.new(ui:player_position()),
    mlib.vec2.new(keys:get("moved"))
  )
  player:move(screen, player_move_direction.x, player_move_direction.y)
  player:set_direction(ui:player_direction())

  gooi.update(dt)
  keys:update()

  local was_updated = best_stats:update(stats)
  if was_updated then
    stats_storage:store_stats(best_stats)
  end
end

function love.resize()
  screen = _make_screen()

  table.eachi(targets, Target.destroy)
  targets = {}

  table.eachi(holes, Hole.destroy)
  holes = {}

  table.eachi(impulses, Impulse.destroy)
  impulses = {}

  player:destroy()
  player = Player:new(world, screen)

  ui:destroy()
  ui = Ui:new(screen, function()
    stats:add_impulse()

    local impulse = Impulse:new(world, screen, player)
    table.insert(impulses, impulse)
  end)
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
