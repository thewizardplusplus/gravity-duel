# Gravity Duel

## Building

Clone this repository:

```
$ git clone https://github.com/thewizardplusplus/gravity-duel.git
$ cd gravity-duel
```

Build the game with the [makelove](https://github.com/pfirsich/makelove) tool:

```
$ makelove ( win64 | macos | appimage )
```

Take the required build from the corresponding subdirectory of the created `builds` directory.

## Running

See for details: <https://love2d.org/wiki/Getting_Started#Running_Games>

### On the Android

Clone this repository:

```
$ git clone https://github.com/thewizardplusplus/gravity-duel.git
$ cd gravity-duel
```

Make a ZIP archive containing it:

```
$ git archive --format zip --output gravity-duel.zip HEAD
```

Change its extension from `.zip` to `.love`:

```
$ mv gravity-duel.zip gravity-duel.love
```

Transfer the resulting file to the Android device.

Open it with the [LÖVE for Android](https://play.google.com/store/apps/details?id=org.love2d.android) app.

### On the PC

Clone this repository:

```
$ git clone https://github.com/thewizardplusplus/gravity-duel.git
$ cd gravity-duel
```

Then run the game with the [LÖVE](https://love2d.org/) engine:

```
$ love .
```

## License

The MIT License (MIT)

Copyright &copy; 2021 thewizardplusplus
