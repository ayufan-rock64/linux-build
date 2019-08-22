# GPU accelerated OpenArena / Quake 3

It is possible to run OpenArena and Quake 3
on Rock64 / RockPro64 / Pinebook Pro and all
GPU accelerated applications and games.

## Installation

You first have to install OpenArena and Quake 3:

```bash
sudo apt install openarena
sudo apt install quake3
```

For running Quake 3 you might need either Demo files,
or actual game files.

## Use GL4ES

The RK3328 and RK3399 does not support OpenGL. It does
only support OpenGL ES 1.0/1.1/2.0. The OpenArena / Quake 3
do only run on OpenGL, for that purpose you need to use
library that will translate all OpenGL to OpenGL ES,
ie.: [gl4es](https://github.com/ptitSeb/gl4es).

You can easily install that on this builds, it is already installed
if you use desktop images:

```bash
sudo apt install libgl4es1
```

Next to run application using this translation layer,
prefix your executable with `gl4es` command:

```bash
gl4es glxgears
gl4es openarena ...
gl4es quake3 ...
```

## Run the games

To run OpenArena you need to make it ran through `gl4es`:

```bash
DBUS_FATAL_WARNINGS=0 gl4es openarena +set cl_renderer opengl1 +set r_mode -1 +set r_customwidth 1920 +set r_customheight 1080 +set r_fullscreen 1 +set cg_drawFPS 1
```

Running Quake 3 is exactly the same:

```bash
DBUS_FATAL_WARNINGS=0 gl4es openarena +set cl_renderer opengl1 +set r_mode -1 +set r_customwidth 1920 +set r_customheight 1080 +set r_fullscreen 1 +set cg_drawFPS 1
```

## FAQ

1. The `DBUS_FATAL_WARNINGS=0` suppresses warnings like this:

    ```
    dbus[5410]: arguments to dbus_message_new_method_call() were incorrect, assertion "path != NULL" failed in file ../../../dbus/dbus-message.c line 1362.
    This is normally a bug in some application using the D-Bus library.

      D-Bus not built with -rdynamic so unable to print a backtrace
    ----- Client Shutdown (Received signal 6) -----
    RE_Shutdown( 1 )
    tty]dbus[5410]: arguments to dbus_message_new_method_call() were incorrect, assertion "path != NULL" failed in file ../../../dbus/dbus-message.c line 1362.
    This is normally a bug in some application using the D-Bus library.

      D-Bus not built with -rdynamic so unable to print a backtrace
    DOUBLE SIGNAL FAULT: Received signal 6, exiting...
    ```

2. The `gl4es` makes to run game using OpenGL to OpenGL ES translation layer,
   so using hardware accelerated GPU. This image does not use this translation
   layer by default, as it is not always possible to run applications
   with it. This is why if you want to run application with it,
   you have to run it from `Terminal` with `gl4es` command.
