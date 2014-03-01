
# Debian Wheezy Gnome3 UI
#### Updated 1-9-2014

My former [gui](gui.md) documentation was a mixture of generic and gnome3 specific information.

For those who are unaware, gnome3 is the modern heavy-weight graphical user interface, which comes as the default in many distributions.

From my experience, it is a very user friendly interface, but many of its benefits are also negatives.  Specifically, everything is tightly integrated.  This is great because different tools are seemlessly part of the same system, but it removes the power of choice that linux is so widely known for.  More specifically it takes away the seemless experience by introducing alternatives that may or may not work as well with the system as a whole (despite many of those tools working perfectly fine on their own).


## Hardware

This interface requires at least half a gigabyte of memory to run, but it would be ideal to have 1GB or more to work with if you plan on actually doing anything inside of it.


## Troubleshooting

Gnome3 depends on the graphics processor to handle specific UI tasks, though driver installation varies wildly and won't be covered here.  If you install the packages below and cannot run `startx` or `telinit 3` into the gdm3 GUI, then you may have to look elsewhere for information.


## Installation

Minimalist Gnome3 Packages:

    aptitude install -y gnome-session gnome-terminal gnome-disk-utility gnome-screenshot gnome-screensaver gksu gdm3 xorg-dev ia32-libs-gtk binfmt-support desktop-base xdg-user-dirs-gtk xdg-utils network-manager eog gnash guake

This will give you all the bare bones of a Gnome3 interface, without nearly a gigabyte of miscelanious software that comes bundled with the default `gnome` package.

**Additional software recommendations can be found in my [gui](gui.md) document.**


### Adjusting Boot Services

With the GUI now installed, we have a bluetooth and network manager service running all the time.  If you have a wireless connection you probably want to leave that alone, but if you have a wired connection you may benefit from turning these services off.  Similarly you can also tell the system not to load the graphical user interface at the default run-level (2), which would allow you to launch it on-demand if you did not need it on every boot.

Here is how you can adjust those services:

    update-rc.d network-manager disable 2
    update-rc.d network-manager disable 3
    update-rc.d network-manager disable 4
    update-rc.d network-manager disable 5
    update-rc.d bluetooth disable 2
    update-rc.d bluetooth disable 3
    update-rc.d bluetooth disable 4
    update-rc.d bluetooth disable 5
    update-rc.d gdm3 disable 2

This will prevent the network manager and bluetooth services from loading, and the default run-level (2) will not launch the login screen.

We can use `telinit 3` to start the GUI, or `startx` if preferred to jump strait in, allowing us to reduce consumed resources at boot time since we don't always need the GUI.


### Patching Guake

At time of writing Guake had a bug that prevented it from executing at login due to `notification.show()`, where the command could not yet process as the system was not ready to accept it.  _This may have been fixed, check the code before applying any patches._

Fortunately Guake is written in python, and this bug can easily be fixed by modifying `/usr/bin/guake`:

    sed -i 's/notification.show()/try:\n                notification.show()\n            except Exception:\n                pass/' /usr/bin/guake

I recommend removing the xdg auto-start desktop file, as it explicitly has auto-start turned off (so it seems):

    rm /etc/xdg/autostart/guake.desktop

I create a new .desktop file in `~/.local/share/applications/guake.desktop` containing:

    [Desktop Entry]
    Name=Guake Terminal
    Comment=Use the command line in a Quake-like terminal
    TryExec=guake
    Exec=guake
    Icon=/usr/share/pixmaps/guake/guake.png
    Type=Application
    Categories=GNOME;GTK;Utility;TerminalEmulator;

Then I can easily setuo local autostart in `~/.config/autostart` and symlink the new .desktop:

    mkdir -p ~/.config/autostart
    ln -s ~/.local/share/applications/guake.desktop ~/.config/autostart/guake.desktop


### Enable GDM Login as Root

This is entirely optional, but I like having it in the event that I have to debug.

By default debian's pam is configured to disallow root gui login, but we can resolve this simply with:

    sed -i "s/user != root//" /etc/pam.d/gdm3
