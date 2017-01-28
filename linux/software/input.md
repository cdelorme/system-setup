
# input

I found myself toying with the console font and keyboard maps at one point, and while I have since decided that mozc and ibus type packages are a better way to switch input types, I figured I'd list some useful references.


## console setup

You can modify the file in `/etc/default/console-setup` to change the default font used by the terminal (tty).  This does nothing from pty terminals or ssh, and debian has a very limited default set of fonts located in `/usr/share/consolefonts/` so their default happens to be the best option in my experience.

If modified you can run `setupcon` after to reload, or systemd to rerun `console-setup` itself.

The "debian way" would be to modify a file in `/etc/console-setup/config`, but it doesn't exist by default.


## keyboard

The keyboard layout can be modified from `/etc/default/keyboard`, which lets you change the model and language.  _This is super useful to know if you have a non-standard keyboard and it gets incorrectly detected._

Sadly, I never figured out how to switch keyboard layouts based on the keyboard being used, so if you had multiple keyboards connected and each had a different layout you might be boned.

Same as with the console, running `setupcon` or using systemd to reload `console-setup` seems to do the trick for this.

The "debian way" says to edit `/etc/kbd/config`, but I haven't bothered trying.


# references

- [stack overflow info](http://unix.stackexchange.com/questions/49779/can-i-change-the-font-of-terminal)
- [XKB Config](http://www.x.org/releases/X11R7.6/doc/xorg-docs/input/XKB-Config.html)
