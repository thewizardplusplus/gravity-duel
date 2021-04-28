local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local windfield = require("windfield")
local Rectangle = require("models.rectangle")
local physics = require("physics")
require("gooi")
require("luatable")
require("compat52")

local screen = nil -- models.Rectangle
local world = nil -- windfield.World
local stones = {}
local position_joystick = nil
local direction_joystick = nil

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
  world:setQueryDebugDrawing(true)

  local side_count = 3
  local grid_step = screen.height / 8
  local offset_x = screen.x + screen.width / 2 - (2 * side_count + 1) * grid_step / 2
  local offset_y = screen.y + screen.height / 2 - (2 * side_count + 1) * grid_step / 2
  for row = 0, side_count - 1 do
    for column = 0, side_count - 1 do
      local stone = physics.make_collider(world, "dynamic", Rectangle:new(
        offset_x + (2 * column + 1) * grid_step,
        offset_y + (2 * row + 1) * grid_step,
        grid_step,
        grid_step
      ))
      table.insert(stones, stone)
    end
  end

  local joystick_size = screen.height / 4
  local joystick_margin = screen.height / 16
  position_joystick = gooi.newJoy({
    x = screen.x + joystick_margin,
    y = screen.y + screen.height - joystick_size - joystick_margin,
    size = joystick_size,
  })
  direction_joystick = gooi.newJoy({
    x = screen.x + screen.width - joystick_size - joystick_margin,
    y = screen.y + screen.height - joystick_size - joystick_margin,
    size = joystick_size,
  })
  direction_joystick:noSpring()
end

function love.draw()
  world:draw()
  gooi.draw()
end

function love.update(dt)
  world:update(dt)
  gooi.update(dt)
end

function love.resize()
  screen = _make_screen()

  physics.process_colliders(stones, function(stone)
    stone:destroy()
  end)
  stones = {}

  local side_count = 3
  local grid_step = screen.height / 8
  local offset_x = screen.x + screen.width / 2 - (2 * side_count + 1) * grid_step / 2
  local offset_y = screen.y + screen.height / 2 - (2 * side_count + 1) * grid_step / 2
  for row = 0, side_count - 1 do
    for column = 0, side_count - 1 do
      local stone = physics.make_collider(world, "dynamic", Rectangle:new(
        offset_x + (2 * column + 1) * grid_step,
        offset_y + (2 * row + 1) * grid_step,
        grid_step,
        grid_step
      ))
      table.insert(stones, stone)
    end
  end

  local joystick_size = screen.height / 4
  local joystick_margin = screen.height / 16

  gooi.removeComponent(position_joystick)
  position_joystick = gooi.newJoy({
    x = screen.x + joystick_margin,
    y = screen.y + screen.height - joystick_size - joystick_margin,
    size = joystick_size,
  })

  gooi.removeComponent(direction_joystick)
  direction_joystick = gooi.newJoy({
    x = screen.x + screen.width - joystick_size - joystick_margin,
    y = screen.y + screen.height - joystick_size - joystick_margin,
    size = joystick_size,
  })
  direction_joystick:noSpring()
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
