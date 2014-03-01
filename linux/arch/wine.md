
# arch wine documentation
#### Updated 2-28-2014

This is a simplified set of notes on getting Wine up and running in Arch.

For extreme details and troubleshooting, read [Their Guide](https://wiki.archlinux.org/index.php/wine) religiously.


## Installing

Install the initial packages:

    pacman -S wine wine-gecko wine-mono winetricks

Arch's Wine is built with the 64 bit flag and will support the x64 architecture.  It will by default use 64 bit wine.

However, winetricks and numerous other wine tools are 32 bit only, so your system must have 32 bit libraries enabled, and many of the 32 bit matching packages must be installed.


## Setting Up

Let's start by enabling [multilib](https://wiki.archlinux.org/index.php/Multilib).  Open your `/etc/pacman.conf` file and remove comments from:

    [multilib]
    Include = /etc/pacman.d/mirrorlist

_This is required if you want the 32 bit of anything to work._

Next update the package lists with:

    pacman -Syyu

Now install the multilib gcc:

    pacman -S gcc-multilib

You can specify the wine prefix with:

    WINEPREFIX=~/.wine

If you want to create a prefix without opening the `winecfg` gui tool you can set the flag above then run:

    wineboot -u

To ensure your Wine instance does not run as a 64 bit instance by default, set `WINEARCH`:

    WINEARCH=win32

You must rebuild a wine instance afterwards for the architecture changes to take affect.


## Working Sound

Install packages:

    pacman -S alsa-lib pulseaudio openal alsa-plugins pulseaudio-alsa lib32-alsa-lib lib32-alsa-plugins lib32-libpulse lib32-openal

_Without these it may not work at all, or try to use the wrong output source._


## Matching Graphics Drivers

With 32 bit expectations you will also need the 32 bit version of your drivers.

In my case that was nvidia:

    pacman -S lib32-nvidia-libgl


## Recommended Packages

To get a number of miscellanious tools working, you should consider installing these packages:

    pacman -S lib32-libxml2 lib32-mpg123 lib32-giflib lib32-libpng lib32-gnutls samba


## Winetricks

**Remember that winetricks packages are not 64-bit compatible.**

Packages installed from this are pretty much dependent on what you are trying to run, so I will separate the tricks I installed according to what I wanted running.

**IF YOU WANT IE8 TO INSTALL YOU MUST INSTALL IT AS THE VERY FIRST THING YOU DO TO YOUR WINE INSTANCE.**


## RPG Maker Games

To get any games made with the modern-day RPG Maker packages you may have to install additional packages, such as:

    winetricks directsound


### Final Fantasy XIV:ARR Setup

_Despite my best efforts I never did get this working.  I got as far as a client that loads to the first menu, but character selection never displays, and I only made it that far by creating a VM with windows to download and update the game files._

**Requires IE8**

Afterwards, you must still install `winhttp`, `xact_jun2010` and `allfonts` for best interaction.

Afterwards you should be able to run the client installer:

    wine ffxivsetup.exe

When you try to launch it with:

    wine 'C:\Program Files\\SquareEnix\\FINAL FANTASY XIV - A Realm Rebort\\boot\\ffxivboot.exe'

You will get a screen and cannot click to accept the agreement (next button is grey and popup is in your way).  To bypass this you can manually accept by changing the EULA flag inside the FFXIV_BOOT.cfg file it created in your (C-related) `My Documents/My Games/` folder.

Next you will be directed to create an account, then enter the account information.


## Bugs

Most applications will launch with problem messages:

    p11-kit: couldn't load module: /usr/lib32/pkcs11/gnome-keyring-pkcs11.so: /usr/lib32/pkcs11/gnome-keyring-pkcs11.so: cannot open shared object file: No such file or directory

Apparently, this is caused by non-multiarch compatible gnome-keyring package, a work in progress.

