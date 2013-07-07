
# Windows 8 Multimedia Documentation

The following is comprehensive start-to-finish set of instructions I use for setting up a brand new Windows 8 Multimedia system.


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


## Staging

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

I prepare the file system for changes by updating anything to do with the Libraries, and adding directories to `C:/` such as `C:/dev/software` and `C:/dev/projects` folders.  These allow me to coordinate installation of development software (python/java) and project files.

Ideally I will download all of my software right away, including the software with graphics dependencies, but I will only install the ones I can at the moment, in order.

**Starting with development software:**

- [MinGW](http://www.mingw.org/)
- [Go language](http://golang.org/)
- [Python](http://www.python.org/)
- [Tcl/TKinter](http://www.tcl.tk/)
    - or [here](http://www.activestate.com/activetcl/downloads)
- [Java JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
- [Android SDK](http://developer.android.com/sdk/index.html)
- [Apache ANT](http://ant.apache.org/)
- [Ouya Development Kit](https://devs.ouya.tv/developers)

I then make sure that I have added all development software folders to my PATH system variable.

_Development References:_

- [Follow instructions for building and compiling from command line](http://developer.android.com/tools/building/building-cmdline.html)

**Moving onto Productivity Software:**

- [Sublime Text 2](http://www.sublimetext.com/2)
- [Google Chrome Dev Channel](http://www.chromium.org/getting-involved/dev-channel)
- [Firefox](http://www.mozilla.org/en-US/firefox/new/)
- [Firefox Aurora](http://www.mozilla.org/en-US/firefox/aurora/)
- [Opera](http://www.opera.com/)
- [7zip](http://www.7-zip.org/)
- [SumatraPDF](http://blog.kowalczyk.info/software/sumatrapdf/free-pdf-reader.html)
- [Flash Projector](http://www.adobe.com/support/flashplayer/downloads.html)
- [CCleaner](http://www.piriform.com/ccleaner)
- [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)
- [Daemon Tools](http://www.daemon-tools.cc/downloads)
- [File Zilla](https://filezilla-project.org/)
- sothink swf decompiler
- Visual Studio 2012

I usually spend some time launching each application, and configuring it to ensure it is functional.  That concludes the pre-drivers stage.

**It would be wise to reboot the entire physical machine prior to moving onto the Drivers stage.**


### Backup

At this very point you should create a backup of the machine.  This is so that if something goes wrong in the next step you can quickly and easily restore to the state you reached prior to the driver stage.


### Drivers

The following drivers are for devices passed to the virtual machine, and to eliminate layers to devices such as from the virtual machine to te hard disk or network adapter.

In general they improve performance, but if the device state of the graphics card is not fresh it can lead to corrupted installation, which creates an unfixable (afaik) BSoD problem.  If you rebooted fresh and passed the devices live to ensure automatic driver installation did not occur, then you should be fine.

**List of Drivers:***

- [GPLPV](http://www.meadowcourt.org/downloads/)
- [AMD Drivers](http://support.amd.com/us/gpudownload/windows/Pages/radeonaiw_win8-64.aspx)
- [ASRock Z77 Extreme9](http://www.asrock.com/mb/Intel/Z77%20Extreme9/?cat=Download)
    - Grab the Motherboard, USB 2.0 & 3.0, and any other related drivers

**Do the installations one at a time, and if any of them request a reboot be sure to shutdown instead and reboot the physical machine before proceeding.**

The next stage is all the software that is dependent on these drivers or the results of these drivers being installed.


## Post-Drivers

After the drivers are installed, here is a list of new devices I may have connected:

- Logitech K810 Bluetooth Keyboard
-


I will generally shut down the virtual machine at this stage and boost its partition size to 160GB of space, this is to make room for all the additional software I am about to install.

Here is the list of software that I will want to install to accommodate these devices:

- [K-Lite Codec Packs](http://codecguide.com/download_kl.htm)
- [Logitech K810 Set Point Software](http://www.logitech.com/en-us/support/bluetooth-illuminated-keyboard-k810?crid=404)

I configure my Logitech K810 keyboard to use the Function keys by default instead of the enhanced media keys (hotkeys like F2 to rename a file are significantly harder without this).

Finally here is any software that I will want on the machine for multimedia:

- [iTunes](http://www.apple.com/itunes/)
- [Faststone Image Viewer](http://www.faststone.org/FSViewerDetail.htm)
- [Inkscape](http://inkscape.org/)
- [Fraps](http://www.fraps.com/)
- [Blender3D](http://www.blender.org/)
- [Windows Movie Maker](http://windows.microsoft.com/en-us/windows-live/movie-maker#t1=overview)
- [Cave Story](http://www.cavestory.org/downloads_game.php)
- [Steam](http://store.steampowered.com/)
    - The Last Remnant
- FF7
- FF8

---

**Special Instructions:**

For FF8's installation I use the FF8 Launcher, which can be found on the [Qhimm Forums](http://qhimm.com/).

For FF7 the process is entirely different, and made much more complex by the added "security" features in Windows 8.  I [posted the instructions](http://forums.qhimm.com/index.php?topic=13856.0), but just in case I have kept a local copy of them.

Most of the forum members currently recommend the bootleg program, but I found that process to be entirely too much work by comparison to running an installer and modifying some text files.  Granted, it does give you a greater degree of control, but "newer" is hardly a concern hen speaking of FF7 modifications.


First, when you install FF7 **do so to a local user path and not the program files** directory.  The recent security changes prevent the FF7 Remix installer from doing certain things inside the Program Files folders, which are what break the patch.

Next when you run the FF7 Remix patch, point it to the local install directory that you installed FF7 to.

Inside that folder you will find a file `tm20dec.ax`, which you will manually copy to `C:/windows/system32`.

Next you will want to modify several of the scripts.  Be sure that you swap out the correct paths according to your username and the local folder you installed FF7 to:

Move `movies/ff7movkeyC64.reg` to `ff7dirs.reg` and edited to contain:

    Windows Registry Editor Version 5.00

    [HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Square Soft, Inc.\Final Fantasy VII]
    "AppPath"="C:\\Users\\user\\Saved Games\\Final Fantasy VII\\"
    "DataPath"="C:\\Users\\user\\Saved Games\\Final Fantasy VII\\data\\"
    "MoviePath"="C:\\Users\\user\\Saved Games\\Final Fantasy VII\\movies\\"
    "FullInstall"=dword:00000001

Rename `64bitpostinstall.bat` to `postinstall.bat` and edited its contents:

    @ECHO Creating shortcuts...
    @START notepad "C:\Users\user\Saved Games\Final Fantasy VII\ff7_opengl.cfg"
    @ECHO Please configure OpenGL settings before continuing
    @ECHO (input optimal resolution and save)
    @PAUSE
    @ECHO Verifying presence of tm20dec.ax
    @IF NOT EXIST "C:\WINDOWS\SYSTEM32\tm20dec.ax" (
        @IF EXIST "C:\Users\user\Saved Games\Final Fantasy VII\tm20dec.ax" (
            @ECHO Placing Copy of tm20dec.ax codec into system32
            @COPY "C:\Users\user\Saved Games\Final Fantasy VII\tm20dec.ax" "C:\WINDOWS\SYSTEM32\"
        )
    )
    @ECHO Verifying OpenGL Registry Keys
    @IF EXIST "C:\Users\user\Saved Games\Final Fantasy VII\FF7OpenGL.reg" (
        @ECHO Setting OpenGL Registry Keys
        @"C:\Users\user\Saved Games\Final Fantasy VII\FF7OpenGL.reg"
    )
    @ECHO Verifying Folder Locations
    @IF EXIST "C:\Users\user\Saved Games\Final Fantasy VII\ff7dirs.reg" (
        @ECHO Setting Folder Locations in Registry
        @"C:\Users\user\Saved Games\Final Fantasy VII\ff7dirs.reg"
    )
    @ECHO Installation Completed
    @PAUSE

Rename `Run FFVII-Remix.bat` to `ff7.bat` and set contents to:

    @ECHO off
    @IF EXIST "n_ff7.exe" (
        @RENAME "C:\Users\user\Saved Games\Final Fantasy VII\ff7.exe" "C:\Users\user\Saved Games\Final Fantasy VII\h_ff7.exe"
        @RENAME "C:\Users\user\Saved Games\Final Fantasy VII\n_ff7.exe" "C:\Users\user\Saved Games\Final Fantasy VII\ff7.exe"
    )
    @IF EXIST "C:\Users\user\Saved Games\Final Fantasy VII\data\battle\n_scene.bin" (
        @RENAME "C:\Users\user\Saved Games\Final Fantasy VII\data\battle\scene.bin" "C:\Users\user\Saved Games\Final Fantasy VII\data\battle\h_scene.bin"
        @RENAME "C:\Users\user\Saved Games\Final Fantasy VII\data\battle\n_scene.bin" "C:\Users\user\Saved Games\Final Fantasy VII\data\battle\scene.bin"
    )
    @IF EXIST "C:\Users\user\Saved Games\Final Fantasy VII\data\battle\n_battle.lgp" (
        @RENAME "C:\Users\user\Saved Games\Final Fantasy VII\data\battle\battle.lgp" "C:\Users\user\Saved Games\Final Fantasy VII\data\battle\h_battle.lgp"
        @RENAME "C:\Users\user\Saved Games\Final Fantasy VII\data\battle\n_battle.lgp" "C:\Users\user\Saved Games\Final Fantasy VII\data\battle\battle.lgp"
    )
    @IF EXIST "C:\Users\user\Saved Games\Final Fantasy VII\data\kernel\n_kernel.bin" (
        @RENAME "C:\Users\user\Saved Games\Final Fantasy VII\data\kernel\kernel.bin" "C:\Users\user\Saved Games\Final Fantasy VII\data\kernel\h_kernel.bin"
        @RENAME "C:\Users\user\Saved Games\Final Fantasy VII\data\kernel\n_kernel.bin" "C:\Users\user\Saved Games\Final Fantasy VII\data\kernel\kernel.bin"
    )
    @IF EXIST "C:\Users\user\Saved Games\Final Fantasy VII\data\kernel\n_kernel2.bin" (
        @RENAME "C:\Users\user\Saved Games\Final Fantasy VII\data\kernel\kernel2.bin" "C:\Users\user\Saved Games\Final Fantasy VII\data\kernel\h_kernel2.bin"
        @RENAME "C:\Users\user\Saved Games\Final Fantasy VII\data\kernel\n_kernel2.bin" "C:\Users\user\Saved Games\Final Fantasy VII\data\kernel\kernel2.bin"
    )
    @IF EXIST "C:\Users\user\Saved Games\Final Fantasy VII\data\field\n_flevel.lgp" (
        @RENAME "C:\Users\user\Saved Games\Final Fantasy VII\data\field\flevel.lgp" "C:\Users\user\Saved Games\Final Fantasy VII\data\field\h_flevel.lgp"
        @RENAME "C:\Users\user\Saved Games\Final Fantasy VII\data\field\n_flevel.lgp" "C:\Users\user\Saved Games\Final Fantasy VII\data\field\flevel.lgp"
    )
    @IF EXIST "C:\Users\user\Saved Games\Final Fantasy VII\ficedula\ff7music.exe" (
        @START /min /d "C:\Users\user\Saved Games\Final Fantasy VII\ficedula\" ff7music.exe
        @IF EXIST "C:\Users\user\Saved Games\Final Fantasy VII\ff7.exe" (
            @SET __COMPAT_LAYER=Win98
            @START /wait /d "C:\Users\user\Saved Games\Final Fantasy VII\" ff7.exe
            @TASKKILL /im ff7music.exe
        )
    )
    @EXIT

Run the `postinstall.bat` script with administrative privileges, so it can plop files into the system32 directory.

Now create a shortcut to `ff7.bat` on your desktop, and execute it with administrative privileges to start the game.

**Summary of Problems & Solutions:**

The new protection will not allow scripts to copy the tm20dec.ax file into your `c:/windows/system32/` folder.  Thus you must copy the file manually.

Any scripts that change or move files around will not work properly (this is basically all of them).  To work around this, you must change the installation directory to a non-protected folder, such as any personal folder (Documents/Downloads/etc...).

The scripts are all hard coded, which means all of the paths expect your install to exist in c:/Program Files OR c:/Program Files (x86).  To fix that you must modify the paths and run the following files according to your version of windows (64 bit edit 64 bit files):

- `movies/ff7movkeyC64.reg` OR `movies/ff7movkeyC.reg`
- `64bitpostinstall.bat` OR `ff7remixpostinstall.bat`
- `OpenGLconfig.bat`
- `Run FFVII-Remix.bat`

_You can delete the remaining files.  I deleted the vbs files since I can make a shortcut myself, but you are welcome to try editing them._

The ff7music executable requires access to protected information, so yo have to run your launcher with administrative privileges.  This requires that ALL file names and executables are accessed by full paths, so when you edit the list of files you will have to add full paths.


## Finishing Touches & Conclusion

At this point I go through all the newly installed software and games, adding registration codes, configuring them, and making sure they are "ready to go".

Afterwards I make a second `dd` backup of this instance.

With Xen and a backup I can easily restore my system to this fresh state in about 20 minutes.  This is an enormous boon for me, and means my virus concerns are almost entirely gone.

With Xen and passthrough I also no-longer have any Windows dependencies that require me to run Windows as a host system.

That concludes all the steps to setting up my Windows machine.  I use it for development, multimedia, and gaming.

