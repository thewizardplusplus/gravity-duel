# Change Log

## [v1.3.1](https://github.com/thewizardplusplus/gravity-duel/tree/v1.3.1) (2021-12-04)

- Add the `Controls:_impulse_allowed()` method
- Fix the `Controls:initialize()` method
- Fix the code style
- Add the disclaimer in the `README.md` file
- Add the `Rectangle:ui_grid_step()` method
- Add the `Rectangle:maximum()` method
- Add the `Rectangle:center()` method
- Fix the running description in the `README.md` file
- Complete the `.gitignore` file
- Fix the `Controls:update()` method
- Add the `Controls:_is_player_moving()` method
- Add the `Controls:_is_player_rotating()` method
- Fix the `Controls:_is_impulse_allowed()` method
- Fix the version in the [makelove](https://github.com/pfirsich/makelove) configuration

## [v1.3](https://github.com/thewizardplusplus/gravity-duel/tree/v1.3) (2021-06-26)

- Add the `_add_impulse()` function
- Add the `_add_target()` function
- Add the `_add_hole()` function
- Add the `typeutils.is_number()` function
- Add the `Rectangle:font_size()` method
- Add the `Circle` class
- Add the `drawing.draw_drawables()` function
- Rename the `_make_screen()` function to `_create_screen()`
- Add the `drawing.set_font()` function
- Add the `_filter_destroyables()` function
- Fix the docs of the `BestStats` class
- Support negative coordinates in the `Circle` class
- Add the `drawing.draw_labels()` function
- Add the `TemporaryCircle` class
- Fix the docs of the `Stats` class
- Fix the docs of the `Player` class
- Fix the docs of the `Ui` class
- Add the `Collider` mixin
- Add the `Impulse:vector_to()` method
- Rename the `Ui:player_position()` method to `Ui:player_move_direction()`
- Extend the `TemporaryCircle:initialize()` method
- Improve the type assertions
- Fix the `mathutils.random_in_range()` function
- Add the `window.enter_fullscreen()` function
- Add the `window.create_screen()` function
- Add the `Player:direction()` method
- Add the `mathutils.transform_vector()` function
- Add the `Scene` class
- Add the `_repeat()` function
- Remove the redundant import from the `Ui` class
- Fix the `Ui:player_angle_delta()` method
- Rename the `Player:move()` method to `Player:set_velocity()`
- Add the `Scene:control_player()` method
- Add the `Controls` class
- Add the `miscutils.repeat_at_intervals()` function
- Add the `miscutils.filter_destroyables()` function
- Fix the `Controls:initialize()` method
- Make the `Ui` class a parent for the `Controls` class
- Fix the `StatsStorage:initialize()` method
- Add the `StatsManager` class

## [v1.2](https://github.com/thewizardplusplus/gravity-duel/tree/v1.2) (2021-06-04)

- Fix the player rotation
- Fix the graphical scale
- Reset the automatic player rotation
- Make the UI components transparent
- Support the impulse performing by a keyboard
- Support the player rotation by a keyboard
- Fix the `Impulse:initialize()` method
- Remove the too far player impulses
- Add the `Ui:player_angle_delta()` method
- Remove the `Ui:player_direction()` method
- Simplify the main code of the player rotation
- Add the `Player:rotate()` method
- Add the `Player:reset_autorotation()` method
- Remove the `Player:set_direction()` method
- Extend the keys config
- Disable the impulse performing during the player movement or rotation
- Disable the simultaneous performing of the player movement and rotation
- Create targets from the game beginning
- Create holes from the game beginning

## [v1.1](https://github.com/thewizardplusplus/gravity-duel/tree/v1.1) (2021-05-29)

- Count and display the performed player impulses
- Count and display the hit player impulses
- Count and display the accuracy of the player impulses
- Process the best stats
- Install the [MessagePack](https://github.com/markstinson/lua-MessagePack) library
- Install the [FlatDB](https://github.com/uleelx/FlatDB) library
- Add the `StatsStorage` class
- Add the `factory.create_stats_storage()` function
- Save the best stats
- Add the `Stats:initialize()` method
- Add the `Stats:add_impulse()` method
- Add the `Stats:hit_target()` method
- Add the `Stats:draw()` method
- Add the `BestStats:initialize()` method
- Add the `BestStats:draw()` method
- Make public the `Stats` class fields
- Add the `Stats:impulse_accuracy()` method
- Make public the `BestStats` class fields
- Add the `BestStats:update()` method
- Use the `BestStats` class in the `StatsStorage:get_stats()` method
- Use the `BestStats` class in the `StatsStorage:store_stats()` method
- Rename the `StatsStorage` class fields
- Add the `stats` module

## [v1.0](https://github.com/thewizardplusplus/gravity-duel/tree/v1.0) (2021-05-22)

- Add the `Hole` class
- Add a kind to the `Hole` class
- Apply the gravity to the player impulses
- Add the `Hole:position()` method
- Add the `Hole:kind()` method
- Add the `Impulse:apply_hole()` method
- Tune the hole power

## [v1.0-beta.3](https://github.com/thewizardplusplus/gravity-duel/tree/v1.0-beta.3) (2021-05-21)

- Add the `Target` class
- Add lifes to the `Target` class
- Add a lifetime to the `Target` class
- Install the [tick](https://github.com/rxi/tick) library
- Fix the creation of the targets
- Randomize the creation of the targets
- Fix the `Target:initialize()` method
- Display the number of the hit targets

## [v1.0-beta.2](https://github.com/thewizardplusplus/gravity-duel/tree/v1.0-beta.2) (2021-05-18)

- Add the `drawing.draw_with_transformations()` function
- Add the `drawing.draw_collider()` function
- Add the `Player:initialize()` method
- Add the `Player:draw()` method
- Add the `Player:position()` method
- Add the `Player:angle()` method
- Add the `Player:destroy()` method
- Add the `Rectangle:grid_step()` method
- Add the `Impulse:initialize()` method
- Add the `Impulse:draw()` method
- Add the `Impulse:hit()` method
- Add the `Impulse:destroy()` method
- Destroy all the player impulses on the screen reset
- Simplify the processing of the destroyed player impulses
- Fix the code style in the `Player:initialize()` method
- Add the `Ui:initialize()` method
- Add the `Ui:destroy()` method
- Add the `Ui:center_position()` method
- Tune the font in the `Ui:initialize()` method
- Simplify the main code
- Add the `_load_keys()` function
- Add the `Ui:player_position()` method
- Add the `Ui:player_direction()` method
- Add the `Player:set_direction()` method
- Fix the `Player:angle()` method
- Add the `Player:move()` method

## [v1.0-beta.1](https://github.com/thewizardplusplus/gravity-duel/tree/v1.0-beta.1) (2021-05-10)

- Fix the player position
- Rotate the scene around the player
- Make the player movement local
- Install the [Baton](https://github.com/tesselode/baton) library
- Load the keys config
- Process the keys
- Set the font size
- Tune the player speed
- Tune the player impulse speed
- Tune the debug stone mass
- Tune the player mass
- Tune the player impulse mass

## [v1.0-beta](https://github.com/thewizardplusplus/gravity-duel/tree/v1.0-beta) (2021-05-06)

- Process the player separately
- Make the player larger
- Draw the player ledges
- Add the impulse button
- Rename the `physics.make_collider()` function to `physics.make_rectangle_collider()`
- Add the `physics.make_circle_collider()` function
- Generate the player impulses
- Disable collisions between the player and its impulses
- Apply a velocity to the player impulses
- Fix applying of a velocity to the player impulses
- Fix the player drawing
- Fix the initial angle of the player
- Fix the physical body of the player
- Destroy a player impulse on its hit

## [v1.0-alpha.1](https://github.com/thewizardplusplus/gravity-duel/tree/v1.0-alpha.1) (2021-05-02)

- Install the [windfield](https://github.com/a327ex/windfield) library
- Initialize the debug stones
- Control the player stone
- Implement the custom drawing of the stones
- Pin the player stone to the screen center
- Update the [LDoc](https://github.com/lunarmodules/LDoc) configuration

## [v1.0-alpha](https://github.com/thewizardplusplus/gravity-duel/tree/v1.0-alpha) (2021-04-28)

- Add basics of the project
- Add the [LDoc](https://github.com/lunarmodules/LDoc) configuration
- The joysticks:
- Install the [GOOi](https://github.com/tavuntu/gooi) library
- Add the joysticks
- Display the states of the joysticks
