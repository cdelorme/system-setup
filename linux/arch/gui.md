
# arch (gnome) gui documentation
#### Updated 11-21-2013

This is my attempt to take the template and turn it into a full fledged development environment with various matching tools installed and configured.


## Installing Gnome

Arch makes this far too easy.  All we need to do is install the gnome package.  Unlike debian, arch actually separates all the "Extra" non-dependent software into a `gnome-extras` package.  However I install a slightly larger list of packages:

    pacman -S xorg-server xorg-server-devel xorg-xinit gnome gdm guake gksu gnome-tweak-tool gnome-screensaver gparted gnash-gtk vlc gtk-recordmydesktop libmcrypt qt3 bpython nodejs go gcc-go swftools openshot gimp inkscape transmission-cli transmission-gtk flashplugin linux-headers xdg-utils chromium guichan

_The `gnome` package alone consumes 1.2GiB of memory on disk after installation, so be aware that you will need enough space in root (/)._

If you want the graphical environment at boot you can enable gdm:

    systemctl enable gdm

I personally prefer to start it "on-demand":

    systemctl start gdm

_Unfortunately if you have 3D Acceleration checked you're gonna have a bad time mmmk?_  There is currently a bug (believed to be VBox related not arch related) where the video overlay is off-centered covering the title box and not matching the actual mouse cursors position.  **You can _fix_ the off-centered overlay by turning off 3D Acceleration, but then Gnome will run slower.**

It should use mesa-libgl by default, if you see the nvidia option do not select it or you will get a borked gdm.

Gnome integrates with pulse audio, but if you want audio in terminal you can install `alsa-utils`.  By default audio is muted, so let's run `alsamixer` and crank the gain til it reaches 0dB.


### nVidia Drivers

Instead of installing nvidia-libgl from the gnome install, I ran `pacman -S nvidia`.  Sadly I got a black screen.  However, the fix was easy.

First, to get vidia I logged in by typing (without video) the login prompt, then `rmmod nvidia` followed by `modprobe nouveau`, which loaded the nouveau drivers without a problem.

The issue was a conflict with onboard graphics (IvyBridge HD4000).  I simply added to `/etc/modprobe.d/blacklist.conf`:

    install i915 /usr/bin/false
    install intel_agp /usr/bin/false

Then I rebooted, and video appeared!  However, it was only using one monitor by default, so I am working to resolve that currently.


### Flash Configuration

Since I have a compatible nvidia card, the docs say to enable better support edit `/etc/adobe/mms.cfg` and set `EnableLinuxHWVideoDecode=1`.


## Gnome Instability

Gnome on arch feels unstable and somewhat broken.

Instructions to modify the time to also display the date at the top of the screen don't keep, unless you go through the graphical tool (gconf I believe?), and even then it's erratic.

Further, any custom `.desktop` files don't parse variables or local path, which makes it very difficult to create portable dynamic `.desktop` files.  This is something that works fine on debian and fedora, but I couldn't find anything about it in arch.


## AUR Software

You can get chrome dev off the AUR, ran `makepkg -s`, but the latest iteration is broken due to an incompatible dependency.


## Bluetooth & Trackpads

Fortunately arch comes with bluez 5, which is excellent with way better hardware support.

However, there is almost no documentation on trackpad configuration, so my magic trackpad while I can connect it locks up the system when I try to use it.

Even after spending several days looking into this, I never managed to resolve this.  Primarily I couldn't even find a way to log the errors, since logs are now stored in binary and nearly unusable with `systemd`.

**Here are my almost working instructions**

First, I had to install some packages:

    pacman -S bluez-utils rfkill

Next, I have to enable the bluetooth device, since there is a `softblock` on it by default (I would love to know why exactly...)  I had to run some commands to unblock it, enable it, and then specify that I want to use it:

    rfkill list
    # This returned wireless devices, 0 was my wifi, 1 was my hci/bluetooth
    rfkill unblock 1
    hciconfig hci0 up

Then, despite already being "active" you have to both start and enable bluetooth.  Doing so will rebuild some symlinks (enable will turn it on at next boot):

    systemctl start bluetooth
    systemctl enable bluetooth

Now, when I run `bluetoothctl` I will have a default controller fired up and ready.  Instructions to use this utility are [best described here](https://wiki.archlinux.org/index.php/Bluetooth_Keyboard), but for record-keeping I'll document how I did it:

Start `bluetoothctl` and run these commands:

    power on
    agent KeyboardOnly
    agent default-agent
    pairable on
    scan on

Once you've seen a device mac address appear, you can run these commands:

    pair au:to:co:pl:ete
    trust au:to:co:pl:ete
    connect au:to:co:pl:ete

_I hope it was obvious enough that you can (and should) just auto-complete the device ids._

**During the pair operation, it should ask you to enter a pin to authenticate.  Sometimes this won't work, but those situations will require more work than I can write here usefully.**

For example, I got my Logitech K810 keyboard working, with these extra steps:

- running `hcitool scan` first, which gets a different device mac address than bluetoothctl
- Using that mac address in bluetoothctl for pairing

For my apple keyboard I wanted to remap the function mode.  The steps to do this are tricky.  First, check for the `/sys/modules/hid_apple/parameters/fnmode` file.  It has a 1, set it to 2 and you're set for the current runtime.  To have it set at boot, create a conf file in `/etc/modprobe.d` with: `options hid_apple fnmode=2`.  When you reboot going forward, this should be taken care of.  To load these settings, rebuild your `mkinitcpio -P`.  _An alternative is to add an argument to the kernel line in your grub `hid_apple.fnmode=2` (this can be added to `/etc/default/grub`'s `GRUB_CMDLINE_LINUX_DEFAULT`)._  Don't forget to rebuild the grub config if you got that route.


### Japanese Input

First, mozc is a google-only tool, so arch doesn't use it.  They use Fedora's kkc, which is a fully opened source and brand new alternative.

packages:

    pacman -S ibus-kkc otf-ipafont

Sadly, they have very limited japanese font options from packages.

After installing you can open the `Settings` gui and add input devices, though I have no idea how to accomplish this through cli.
