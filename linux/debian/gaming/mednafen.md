
# mednafen

This is a well known light weight no-interface cli-only multi-platform emulator, and _for the most part_ it works fantastic.


## configuring sound

The audio on modern systems does not work until you modify the configuration (`~/.mednafen` look for a `.cfg`).

It was intended to map directly to `hw:0`, which may not always be the correct device, and if it is it's under control of pulseaudio.

To solve this, you have to set the `sound device` to `sexyal-literal-default` (that's sound device not sound driver, don't make my mistake).


## setting controls

This is perhaps the best feature of mednafen, when you launch any game you can use `alt+shift+1` to trigger a complete control remap.

This accepts both keyboard and controller input, and will ask for inputs for all controllers (eg. 2 controllers for nintendo & snes).  It will also ask for turbo inputs as well.


### both keyboard and controller

If you want both the keyboard and a controller to work, you need to remap the controller input to emulate keyboard input.

This can be done by modifying the `xboxdrv` configuration, but then the controller won't work for other use-cases, and this requires root access.

Another potential option is to modify how xorg interprets the input, although I have no idea whether this conflicts with the xboxdrv input handling.

_My preference is simply to not require this behavior._


## psx

This is the only area I would say that mednafen is poor in, and I have yet to get a single PSX game running in it.

The bios configuration is fairly easy, but you do need to have one to supply to the emulator.

Every other PSX emulator has excellent support for various image types, but mednafen explicitly requires both a `cue` (for sound track mappings) and `bin` file.

_At best I get the music player when I load a `cue` file, and at worst I get errors about the image being "too large" when I try loading the `bin` file(s)._

**I may end up adding another emulator specifically for playstation games.**
