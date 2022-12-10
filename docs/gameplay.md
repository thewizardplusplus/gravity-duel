# Gameplay (EN / [RU](gameplay_ru.md))

[<< Back](README.md)

![](screenshot.png)

## Description of the game field

The game field is represented by three kinds of entities: the player ship, targets, and black and white holes.

The player ship is represented by a gray rectangle. The longer sides of the rectangle are the sides of the ship. The ship also has a notch in its front part.

The targets are represented by green circles. The targets are approximately the size of the player ship.

The black and white holes are represented by dark gray and white circles, respectively. The black and white holes are slightly larger than the player ship.

## Functioning of the game field

### Functioning of the player ship

The player can control the position of his ship on the game field:

- move it up, down, right and left;
- turn it to the right and left.

Despite this, the player ship will remain fixed in the center of the screen. Actually, it is the game field who will change its position relative to the player ship (fixed camera effect).

Also, the player can produce the energy pulses. They appear in the notch of the player ship and start moving forward in a straight line (also see below) in the same direction as the player ship was at the moment of the energy pulse.

Note that all the listed actions **cannot** be performed simultaneously. The player can either move his ship, or turn it, or produce the energy pulses &mdash; only one thing at each particular moment of time.

### Functioning of the targets

The targets appear at a random location of a certain sector in front of the player ship (i.e., in a certain area ahead in the direction of the player ship; because of the fixed camera, it means that the targets always appear in the visible part of the game field). This happens every 2.5 s. After appearing, the targets do not change their position.

The targets have a limited lifetime:

- the targets cease to exist after 5 s of appearing;
- the targets cease to exist after 5 hits of the player energy pulse.

### Functioning of the black and white holes

The black and white holes appear at a random location of a certain sector in front of the player ship (i.e., in a certain area ahead in the direction of the player ship; because of the fixed camera, it means that the black and white holes always appear in the visible part of the game field). This happens every 2.5 s. After appearing, the black and white holes do not change their position.

The black and white holes have a limited lifetime:

- the black or white holes cease to exist after 5 s of appearing.

The black and white holes have gravitational effects on the energy pulses of the player:

- the black holes attract them;
- the white holes repel them.

At the same time, the black and white holes do not affect the player ship.

## The game goals and statistics

The game goals are:

- to hit as many of the targets as possible with as few misses as possible with the energy pulses;
- maximizing the number of the targets that have ceased to exist because of the energy pulses (and not because of time elapsed).

The game keeps statistics, recording the following data:

- the maximum accuracy of the player, i.e., the maximum ratio of the number of the energy pulses that hit the targets to the number of the energy pulses produced, expressed as a percentage;
- the maximum number of the targets that have ceased to exist as a result of the energy pulses (and not because of time elapsed).
