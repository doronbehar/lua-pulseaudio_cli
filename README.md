# PulseAudio D-Bus command line controller

## Introduction & Motivation

This small Lua script was created out of the need for a simple command line application that will control PulseAudio on a multi-sink machine. One of the most needed features I wanted to have was to be able to change the default sink that will be used from now on in PulseAudio. Additionally and perhaps most importantly: I wanted this script to be able to move the current sink sources (programs that produce sound) to the new default sink. I don't know how Gnome and KDE implement this kind of control from within their desktop environment but I needed this to be created in Lua so it could be embedded in my [AwesomeWM configuration](https://github.com/doronbehar/.config_awesome). There are many alternatives listed in [Arch Linux's WiKi PulseAudio article](https://wiki.archlinux.org/index.php/PulseAudio#Console) but non of them fulfilled all of my requirements.

In addition to the above requirements, I wanted this script to connect PulseAudio not via system calls to `pacmd` or `pactl`. I wanted it to rely on `libpulse` directly.

## Usage

### Command line

In order to execute the command `lpulse`, you'll need to install the rock `lua_cliargs`.

When executing the script directly with the Lua interpreter, it accepts 4 sub commands:

- `up` - for raising the volume up.
- `down` - for raising the volume down.
- `mute` - for muting the current used default sink.
- `cycle` - for cycling through all available sinks and setting the next one as default while moving all sink sources to the new sink.

The 2 first commands accept an additional numeric optional argument that specifies the volume step that will be used when increasing or decreasing the volume (out of 100), default is 5.

### Lua API

If you `require` the module and not executing it, it won't process command line arguments and it will return a constructor function that accepts a single table with the following fields:

```lua
Pulseaudio = require('pulseaudio_cli')
settings = {
  -- volume step and maximum volume of sink devices (like speakers)
  sink_device = {
    volume_step = 5,
    volume_max = 100
  },
  -- volume step and maximum volume of sources devices (like a microphone)
  source_device = {
    volume_step = 5,
    volume_max = 100
  },
}
pa = Pulseaudio(settings)
```

No error is produced if any of the fields is `nil`.

### Lower level API

This luarock uses the Lua bindings library for libpulse - [`pulseaudio`](https://github.com/liaonau/lua-pulseaudio). If you desire a lower level control over PulseAudio in Lua so you can use it instead.

## Install

```
luarocks install --server=http://luarocks.org/dev pulseaudio_cli
```
