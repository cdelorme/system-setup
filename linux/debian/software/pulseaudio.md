
# pulseaudio

This is a somewhat controversial software.  When it was released it got a lot of flack for not being very usable but still being set as the default.

In its current state pulseaudio is at least as stable as alsa, but with a much better selection of user friendly utilities, especially `pavucontrol` and `pacmd/pactl`.


## quirks

There are still some quirks:

- it has crappy defaults
- the way it saves state is stupidly unintuitive
- it lacks aliases for simple cli controls

When I say crappy defaults what I mean is having all devices muted by default, failing to create pulse configuration files and save state unless you fiddle with some set of tools, failing to intelligently pick a default sink that isn't the first device in the list, and many more.

If you run `pactl` commands to select sinks, toggle mute, change volume, and then reboot, all changes will be ignored and you'll be back to the crappy defaults.  Instead you **need** to launch pavucontrol or perhaps use `pacmd` (haven't tried) to ensure that `~/.config/pulse/` is created and populated with files storing the state you left with.

When you want to modify anything using a command, you need to explicitly provide the numeric identifier for a given sink, source, or other type of asset.  **This is a huge problem for scripted behavior, since it means you cannot simply change the volume of the "default" or "master" sink.**  At the same time, there is also the question of multiple-sinks, are you targeting all or one when you ask to change volume levels or mute?
