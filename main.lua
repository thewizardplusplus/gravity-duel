local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local windfield = require("windfield")
local mlib = require("mlib")
local baton = require("baton")
local typeutils = require("typeutils")
local drawing = require("drawing")
local physics = require("physics")
local Rectangle = require("models.rectangle")
local Player = require("objects.player")
local Impulse = require("objects.impulse")
local Ui = require("objects.ui")
require("gooi")
require("luatable")
require("compat52")

local screen = nil -- models.Rectangle
local world = nil -- windfield.World
local stones = {}
local player = nil -- objects.Player
local impulses = {} -- {objects.Impulse,...}
local ui = nil -- objects.Ui
local keys = nil -- baton.Player

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

  local side_count = 3
  local offset_x = screen.x + screen.width / 2 - (2 * side_count + 1) * screen:grid_step() / 2
  local offset_y = screen.y + screen.height / 2 - (2 * side_count + 1) * screen:grid_step() / 2
  for row = 0, side_count - 1 do
    for column = 0, side_count - 1 do
      if row ~= math.floor(side_count / 2)
        or column ~= math.floor(side_count / 2) then
        local stone = physics.make_rectangle_collider(world, "dynamic", Rectangle:new(
          offset_x + (2 * column + 1) * screen:grid_step(),
          offset_y + (2 * row + 1) * screen:grid_step(),
          screen:grid_step(),
          screen:grid_step()
        ))
        stone:setMass(1)

        table.insert(stones, stone)
      end
    end
  end

  player = Player:new(world, screen)

  ui = Ui:new(screen, function()
    local impulse = Impulse:new(world, screen, player)
    table.insert(impulses, impulse)
  end)
  keys = assert(_load_keys("keys_config.json"))
end

function love.draw()
  local ui_center_position_x, ui_center_position_y = ui:center_position()
  local player_position_x, player_position_y = player:position()
  love.graphics.setColor(0.5, 0.5, 0.5)
  drawing.draw_with_transformations(function()
    love.graphics.translate(ui_center_position_x, ui_center_position_y)
    love.graphics.rotate(-(player:angle() - -math.pi / 2))
    love.graphics.translate(-ui_center_position_x, -ui_center_position_y)
    love.graphics.translate(
      -(player_position_x - ui_center_position_x),
      -(player_position_y - ui_center_position_y)
    )

    physics.process_colliders(stones, function(stone)
      drawing.draw_collider(stone, function()
        love.graphics.rectangle(
          "fill",
          -screen:grid_step() / 2,
          -screen:grid_step() / 2,
          screen:grid_step(),
          screen:grid_step()
        )
      end)
    end)

    table.eachi(impulses, function(impulse)
      impulse:draw(screen)
    end)

    player:draw(screen)
  end)

  gooi.draw()
end

function love.update(dt)
  world:update(dt)

  impulses = table.accept(impulses, function(impulse)
    local hit = impulse:hit()
    if hit then
      impulse:destroy()
    end

    return not hit
  end)

  local player_speed = 10 * screen.height
  local ui_player_position_x, ui_player_position_y = ui:player_position()
  local keys_player_position_x, keys_player_position_y = keys:get("moved")
  local player_velocity = mlib.vec2.rotate(
    mlib.vec2.add(
      mlib.vec2.new(ui_player_position_x, ui_player_position_y),
      mlib.vec2.new(keys_player_position_x, keys_player_position_y)
    ),
    player:angle() - -math.pi / 2
  )
  player._collider:setLinearVelocity(
    player_speed * dt * player_velocity.x,
    player_speed * dt * player_velocity.y
  )

  player:set_direction(ui:player_direction())

  gooi.update(dt)
  keys:update()
end

function love.resize()
  screen = _make_screen()

  physics.process_colliders(stones, function(stone)
    stone:destroy()
  end)
  stones = {}

  local side_count = 3
  local offset_x = screen.x + screen.width / 2 - (2 * side_count + 1) * screen:grid_step() / 2
  local offset_y = screen.y + screen.height / 2 - (2 * side_count + 1) * screen:grid_step() / 2
  for row = 0, side_count - 1 do
    for column = 0, side_count - 1 do
      if row ~= math.floor(side_count / 2)
        or column ~= math.floor(side_count / 2) then
        local stone = physics.make_rectangle_collider(world, "dynamic", Rectangle:new(
          offset_x + (2 * column + 1) * screen:grid_step(),
          offset_y + (2 * row + 1) * screen:grid_step(),
          screen:grid_step(),
          screen:grid_step()
        ))
        stone:setMass(1)

        table.insert(stones, stone)
      end
    end
  end

  table.eachi(impulses, Impulse.destroy)
  impulses = {}

  player:destroy()
  player = Player:new(world, screen)

  ui:destroy()
  ui = Ui:new(screen, function()
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
