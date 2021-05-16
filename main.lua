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
local keys = nil

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

  local font_size = screen.height / 20
  gooi.setStyle({
    font = love.graphics.newFont(font_size),
  })

  ui = Ui:new(screen, function()
    local impulse = Impulse:new(world, screen, player)
    table.insert(impulses, impulse)
  end)

  local keys_config = assert(typeutils.load_json("keys_config.json", {
    type = "object",
    properties = {
      moved_left = {["$ref"] = "#/definitions/source_group"},
      moved_right = {["$ref"] = "#/definitions/source_group"},
      moved_top = {["$ref"] = "#/definitions/source_group"},
      moved_bottom = {["$ref"] = "#/definitions/source_group"},
    },
    required = {
      "moved_left",
      "moved_right",
      "moved_top",
      "moved_bottom",
    },
    definitions = {
      source_group = {
        type = "array",
        items = {type = "string", pattern = "^%a+:%w+$"},
        minItems = 1,
      },
    },
  }))
  keys = baton.new({
    controls = keys_config,
    pairs = {
      moved = {
        "moved_left",
        "moved_right",
        "moved_top",
        "moved_bottom",
      },
    },
  })
end

function love.draw()
  local player_x, player_y = player:position()
  local player_initial_x = (ui._position_joystick.x + ui._direction_joystick.x) / 2 + ui._position_joystick.w / 2
  local player_initial_y = ui._position_joystick.y + ui._position_joystick.h / 2
  love.graphics.setColor(0.5, 0.5, 0.5)
  drawing.draw_with_transformations(function()
    love.graphics.translate(player_initial_x, player_initial_y)
    love.graphics.rotate(-(player:angle() - -math.pi / 2))
    love.graphics.translate(-player_initial_x, -player_initial_y)
    love.graphics.translate(
      -(player_x - player_initial_x),
      -(player_y - player_initial_y)
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

    for _, impulse in ipairs(impulses) do
      impulse:draw(screen)
    end

    player:draw(screen)
  end)

  gooi.draw()
end

function love.update(dt)
  world:update(dt)

  local active_impulses = {}
  for _, impulse in ipairs(impulses) do
    if not impulse:hit() then
      table.insert(active_impulses, impulse)
    else
      impulse:destroy()
    end
  end
  impulses = active_impulses

  local player_speed = 10 * screen.height
  local position_keys_x, position_keys_y = keys:get("moved")
  local player_velocity = mlib.vec2.rotate(
    mlib.vec2.add(
      mlib.vec2.new(ui._position_joystick:xValue(), ui._position_joystick:yValue()),
      mlib.vec2.new(position_keys_x, position_keys_y)
    ),
    player:angle() - -math.pi / 2
  )
  player._collider:setLinearVelocity(
    player_speed * dt * player_velocity.x,
    player_speed * dt * player_velocity.y
  )
  if ui._direction_joystick:xValue() ~= 0
    or ui._direction_joystick:yValue() ~= 0 then
    player._collider:setAngle(math.atan2(
      ui._direction_joystick:yValue(),
      ui._direction_joystick:xValue()
    ))
  end

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

  for _, impulse in ipairs(impulses) do
    impulse:destroy()
  end
  impulses = {}

  player:destroy()
  player = Player:new(world, screen)

  local font_size = screen.height / 20
  gooi.setStyle({
    font = love.graphics.newFont(font_size),
  })

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
