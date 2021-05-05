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
local player = nil
local player_initial_x = 0
local player_initial_y = 0
local impulses = {}
local position_joystick = nil
local direction_joystick = nil
local impulse_button = nil

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
  local grid_step = screen.height / 8
  local offset_x = screen.x + screen.width / 2 - (2 * side_count + 1) * grid_step / 2
  local offset_y = screen.y + screen.height / 2 - (2 * side_count + 1) * grid_step / 2
  for row = 0, side_count - 1 do
    for column = 0, side_count - 1 do
      if row ~= math.floor(side_count / 2)
        or column ~= math.floor(side_count / 2) then
        local stone = physics.make_rectangle_collider(world, "dynamic", Rectangle:new(
          offset_x + (2 * column + 1) * grid_step,
          offset_y + (2 * row + 1) * grid_step,
          grid_step,
          grid_step
        ))
        table.insert(stones, stone)
      end
    end
  end

  player = physics.make_rectangle_collider(world, "dynamic", Rectangle:new(
    offset_x + 3 * grid_step,
    offset_y + 3 * grid_step - grid_step / 6,
    grid_step,
    grid_step + grid_step / 3
  ))
  player:setCollisionClass("Player")
  player_initial_x, player_initial_y = player:getPosition()

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

  impulse_button = gooi.newButton({
    text = "~~>",
    x = screen.x + screen.width - joystick_size - joystick_margin,
    y = screen.y + screen.height - 1.625 * joystick_size - joystick_margin,
    w = joystick_size,
    h = joystick_size / 2,
  })
  impulse_button:onPress(function()
    local player_x, player_y = player:getPosition()
    local impulse = physics.make_circle_collider(
      world,
      "dynamic",
      player_x,
      player_y,
      grid_step / 12
    )
    impulse:setCollisionClass("Impulse")

    table.insert(impulses, impulse)
  end)
end

function love.draw()
  local grid_step = screen.height / 8
  local player_x, player_y = player:getPosition()
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.push()
  love.graphics.translate(
    -(player_x - player_initial_x),
    -(player_y - player_initial_y)
  )

  physics.process_colliders(stones, function(stone)
    love.graphics.push()
    love.graphics.translate(stone:getPosition())
    love.graphics.rotate(stone:getAngle())
    love.graphics.rectangle(
      "fill",
      -grid_step / 2,
      -grid_step / 2,
      grid_step,
      grid_step
    )
    love.graphics.pop()
  end)

  love.graphics.push()
  love.graphics.translate(player:getPosition())
  love.graphics.rotate(player:getAngle())
  love.graphics.rectangle(
    "fill",
    -grid_step / 2,
    -grid_step / 2 + grid_step / 6,
    grid_step,
    grid_step
  )
  love.graphics.rectangle(
    "fill",
    -grid_step / 2,
    -grid_step / 2 - grid_step / 6,
    grid_step / 3,
    grid_step / 3
  )
  love.graphics.rectangle(
    "fill",
    -grid_step / 2 + 2 * grid_step / 3,
    -grid_step / 2 - grid_step / 6,
    grid_step / 3,
    grid_step / 3
  )
  love.graphics.pop()

  love.graphics.setColor(0, 0.5, 1)
  physics.process_colliders(impulses, function(impulse)
    love.graphics.push()
    love.graphics.translate(impulse:getPosition())
    love.graphics.circle("fill", 0, 0, grid_step / 12)
    love.graphics.pop()
  end)

  love.graphics.pop()

  gooi.draw()
end

function love.update(dt)
  world:update(dt)

  local player_speed = 5000
  player:setLinearVelocity(
    player_speed * dt * position_joystick:xValue(),
    player_speed * dt * position_joystick:yValue()
  )
  player:setAngle(math.atan2(
    direction_joystick:yValue(),
    direction_joystick:xValue()
  ))

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
      if row ~= math.floor(side_count / 2)
        or column ~= math.floor(side_count / 2) then
        local stone = physics.make_rectangle_collider(world, "dynamic", Rectangle:new(
          offset_x + (2 * column + 1) * grid_step,
          offset_y + (2 * row + 1) * grid_step,
          grid_step,
          grid_step
        ))
        table.insert(stones, stone)
      end
    end
  end

  player:destroy()
  player = physics.make_rectangle_collider(world, "dynamic", Rectangle:new(
    offset_x + 3 * grid_step,
    offset_y + 3 * grid_step - grid_step / 6,
    grid_step,
    grid_step + grid_step / 3
  ))
  player:setCollisionClass("Player")
  player_initial_x, player_initial_y = player:getPosition()

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

  gooi.removeComponent(impulse_button)
  impulse_button = gooi.newButton({
    text = "~~>",
    x = screen.x + screen.width - joystick_size - joystick_margin,
    y = screen.y + screen.height - 1.625 * joystick_size - joystick_margin,
    w = joystick_size,
    h = joystick_size / 2,
  })
  impulse_button:onPress(function()
    local player_x, player_y = player:getPosition()
    local impulse = physics.make_circle_collider(
      world,
      "dynamic",
      player_x,
      player_y,
      grid_step / 12
    )
    impulse:setCollisionClass("Impulse")

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
