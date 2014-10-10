
# Windows Multimedia System Documentation
#### Updated 2014-7-20

Latest version used in the making of this document was 8.1.  Unfortunately automation for Windows is fairly imposssible, so instead of that I'll simply document the setup and highly recommend creating a disk image backup to counter both time lost reconfiguring as well as virus problems in the future (they will invariably happen on windows).

As for the intended function, this system operates primarily as a gaming and video playback system.  In some cases I even use it for software development.

**I will say up front that I am biased against the windows platform.  I suffered it for 15 years of my life before discovering the glorious world of linux and unix, and only continue to use it because games still use DirectX.  If they used OpenGL and could be run suitably on Linux or even OSX I would drop this system like a bad habit.**


## Xen Tailored

These instructions were intended to be run on a Xen HVM with VGA Passthrough.  VGA Passthrough is not entirely stable with consumer cards, and as a result the setup process has been broken up into sections.

- A section prior to driver installation.
- System backup occurs here.
- Driver installation including GPLPV (xen specific drivers).
- Post driver software installation.

**This means many of the steps I document are precautionary to prevent BSoD problems within the virtual environment.**

If you too are setting up VGA Passthrough, be sure to follow the documentation closely.


## Warnings

First a quick overview of some trouble with Virtualization of Windows.

VGA Passthrough is still a very buggy situation, and consumer graphics cards are just not built for it unfortunately.  One major bug at present is with state reset.  The only cards that work without much difficulty are AMD graphics cards.  nVidia can be made to work with a series of custom patches, but you'll need to do a lot of footwork and testing.

The graphics card lacks a way to adequately reset its own state, since traditionally a rebooted computer will change the power of the adapter switching it off and on again.  In the case of a virtual machine no control is exerted over its power state, hence the problem.

Experiences vary greatly, some people have no problems, others have nothing but problems.

I have been successful in reproducing a series of steps that lead to a stable environment with my ADM Radeon HD 6870.


## Xen Configuration & System Specs

Virtual Machine Specs:

- 8GB RAM
- 2 Virtual Cores (IvyBridge 3770)
- 160GB Partition (40GB initially)

_More cores does not yield greater performance, as confirmed by Windows Experience Index and other tests.  Unless the software makes excellent use of multi-core processing the number of cores makes very little difference past 2._

__Surprisingly, Windows recognizes from task manager that it is in fact using virtual cores.__

Later during the process I pass PCI Devices to the machine:

- AMD Radeon HD 6870 Graphics Card
- Onboard USB 2.0 & 3.0 Controllers (3 of them)

_A xen configuration file should be included in the list of files in this repository._

I generally have over a dozen USB devices connected to this machine at any given time.


## Staging (For Xen)

In order to ensure my system is functional and easily restored I go through a staging process.

This involves two major states.  Pre-Drivers and Post-Drivers.

Pre-Drivers is before passing any devices to the machine, accessing it only through VNC or SDL in Xen, and installing only basic software with no graphics dependencies.

Immediately after setting up I will create a backup of the system using `dd` from Xen.

Afterwards I will pass the graphics card, USB controllers, and various other components, as well as increase the partition size.

I can then install all of the drivers.

**It is very important that before I pass the devices that I turn off automatic driver installation.  This will lead to the destruction of the VM due to auto-reboot and the previously mentioned state issues with the graphics card.**

So, it is ideal to pass the devices manually the first time using the xl toolstacks "pci-attach" commands, and to reboot the host frequently during the process instead of just the virtual machine.

## Pre-Drivers

I install and set an algorithm based password.

My first step post-install is to remove all Metro applications and run automatic updates until the system is up to date.

_I loath metro, as any metro applications execution state is entirely separated from the desktop environment, another example of poor design._

I then turn off automatic updates, and automatic hardware driver installation.  In Windows 8 there are three locations for these settings, and if all three are not disabled it can lead to problems with Xen as I mentioned before.

I modify the language settings so that English is still the main language, but the system has Japanese locale and IME setup for use.

I also install two fonts I am very fond of:

- [ForMateKonaVe](http://hetima.com/textmate/index.html)
- [EPSON Kyoukashoutai](http://www.wazu.jp/gallery/Fonts_Japanese.html)

_It is ill advised that you download the EPSON Kyoukashoutai font from the reference link, as its format was converted to ASCII at some stage and its font name became gibberish when attempting to use it from drop downs or otherwise.  You will want to modify the font name in a font editor first (I did)._

**Moving onto Productivity Software:**

- [Sublime Text](http://www.sublimetext.com/3)
- [Google Chrome Dev Channel](http://www.chromium.org/getting-involved/dev-channel)
- [Mumble (Client)](http://sourceforge.net/projects/mumble/)
- [7zip](http://www.7-zip.org/)
- [SumatraPDF](http://blog.kowalczyk.info/software/sumatrapdf/free-pdf-reader.html)
- [Flash & Flash Projector](http://www.adobe.com/support/flashplayer/downloads.html)
- [CCleaner](http://www.piriform.com/ccleaner)
- [Daemon Tools](http://www.daemon-tools.cc/downloads)
- [Transmission-QT](http://trqtw.sourceforge.net/blog/)
- SoThink SWF Decompiler
- [ffsplit](http://www.ffsplit.com/)

The ffsplit software is an absolutely fantastic screen-capture, recording, and merging software that is for Windows only.  It works out-of-the-box, allows you to easily specify capture devices and move them around on a display.  Setting the hotkeys, recording settings like resolution etc are simple too.  I use this with an HD Avermedia Capture Card and lay a webcam video ontop.  It took 5 minutes to get it ready for the first recording.

Generally I will test launch each application to ensure it is functional and configure it.

**It would be wise to reboot the entire physical machine prior to moving onto the Drivers stage.**


### [sublime text](https://github.com/cdelorme/system-setup/tree/master/shared_config/sublime_text.md)

Since installing and configuring sublime text is nearly identical between platforms I've moved its instructions to a more centralized location.  Click the header link to read it!


### Backup

At this very point you should create a backup of the machine.  This is so that if something goes wrong in the next step you can quickly and easily restore to the state you reached prior to the driver stage.


### Drivers

The following drivers are for devices passed to the virtual machine, and to eliminate layers to devices such as from the virtual machine to te hard disk or network adapter.

In general they improve performance, but if the device state of the graphics card is not fresh it can lead to corrupted installation, which creates an unfixable (afaik) BSoD problem.  If you rebooted fresh and passed the devices live to ensure automatic driver installation did not occur, then you should be fine.

**List of Drivers:***

- [Signed GPLPV](http://wiki.univention.de/index.php?title=Installing-signed-GPLPV-drivers)
- [AMD Drivers](http://support.amd.com/us/gpudownload/windows/Pages/radeonaiw_win8-64.aspx)
- [ASRock Z77 Extreme9 inf & USB 3.0](http://www.asrock.com/mb/Intel/Z77%20Extreme9/?cat=Download)

**Do the installations one at a time, and if any of them request a reboot be sure to shutdown instead and reboot the physical machine before proceeding.**

The next stage is all the software that is dependent on these drivers or the results of these drivers being installed.


## Post-Drivers

Connect and install all USB Devices:

- [Logitech K810 Bluetooth Keyboard](http://www.logitech.com/en-us/support/bluetooth-illuminated-keyboard-k810?section=downloads&bit=&osid=23)
- [Microsoft XBox 360 Wireless Driver](http://www.microsoft.com/hardware/en-us/d/xbox-360-wireless-controller-for-windows)

Install Video Dependent Software:

- [FFXIV Theme](http://www.finalfantasyxiv.com/alliance/na/dl/)
- [K-Lite Codec Packs](http://codecguide.com/download_kl.htm)
- [Windows Movie Maker](http://windows.microsoft.com/en-us/windows-live/movie-maker#t1=overview)
- [Cave Story](http://www.cavestory.org/downloads_game.php)
- [Steam](http://store.steampowered.com/)
- [FFXIV](http://www.finalfantasyxiv.com/playersdownload/na/)
- [Any Video Converter](http://www.any-video-converter.com/products/for_video_free/)
- [Silverlight (For Netflix)](http://www.microsoft.com/getsilverlight/Get-Started/Install/Default.aspx)

Install Development Software:

- [Visual Studio 2013](http://www.visualstudio.com/en-us/downloads)
- [Visual Studio Resharper](http://www.jetbrains.com/resharper/)

_The express copy of Visual Studio 2013 is free._


---

Turn CapsLock into Control key!

Open `regedt32` and go to the key at `[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout]`, and add a binary key named `Scancode Map` with the following values:

    00 00 00 00 00 00 00 00
    02 00 00 00 1D 00 3A 00
    00 00 00 00

The format is two 0-value byte headers in the first row, following by a byte with the size of the map (including the null-terminator), then we have 4-bit representation of keys where 1D is control and 3A is capslock, this remaps control to capslock.  Finally the null terminator, 8 empty bits indicating the end of the map.

---

Disabling "Folders" in "My Computer"!


Open `regedt32` and go to `[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\]`.  You will see the following hashes, simply delete them:

- Desktop Folder: {B4BFCC3A-DB2C-424C-B029-7FE99A87C641}
- Documents Folder: {A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}
- Downloads Folder: {374DE290-123F-4565-9164-39C4925E467B}
- Music Folder: {1CF1260C-4DD0-4ebb-811F-33C572699FDE}
- Pictures Folder: {3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}
- Videos Folder: {A0953C92-50DC-43bf-BE83-3742FED03C9C}


## final steps

Once all software has been installed, registered, configured, and tested, I generally use the system for roughly a month before making either a "Windows Image Backup" or (my preferred method) an image backup using `dd` from linux.

By creating a backup I ensure a restore point with everything registered and configured, allowing me to use my system free from worries of viral infection (generally), because restoration is fairly easy.  **I prefer the linux method because I can initiate it without a windows restore disk, and have found windows backups to often times be unreliable.**

It is worth noting that this does incur some risk of infection between the initial configuration and backup point, so if you are concerned that you may get an infection between those times you should make a backup immediately.

By giving the system a month to adjust, it will be able to more clearly identify your system usage, and will more appropriately allocate the resources in the machine to the tasks you perform more regularly.  If you make an immediate backup you loose that machine-learning data.

Also, the purpose for a good image backup is **not** simply for emergencies, it is effectively a mandatory part of the windows life-cycle that eventually the system will either get slower, or the inevitable infection will occur.
