
# windows

This document covers Windows 8.1; I am genuinly excited for Windows 10 but praying they don't kill it with high prices or monthly billing...

As a game player I have no choice but to install Windows on bare metal (**there are exceptions but they are no more convenient than this currently**).  In some cases it is superior due to graphics drivers being maintained for windows by GPU companies, but usually game companies just don't deliver cross platform.  In other cases it's terribly bad due to driver corruption (this has happened to me a lot since Windows 7, never before that though).

In some cases I do small amounts of development; usually for work, not pleasure.

If you are curious as to viable alternatives to running Windows on bare metal, checkout my [xen documentation](windows/xen.md).


## installation

While there is not much you can "customize", you can end up in locking buggy situations during installation.

When you get to the drive selection screen, be sure you select the disk, and click the buttons to partition **and format** the drive.  If you do not format, it will claim to do so for you, but when you leave it to the installer it sometimes chokes and can either sit idle indefinetally or spend hours doing what would have taken minutes.


## post-installation configuration

Always set a password, even if you choose to login automatically having a password can protect your files from other users on the system.  It adds just one extra layer of security.

The first thing to do after installing, is run windows updates.  Continue running windows updates until you no longer get anything.  **This process will very likely involve many reboots, and never always click the "check for updates" link manually to ensure it looks before assuming there are none.**

Now I disable User Access Control, as this feature is absolutely useless as a security feature, it only prevents the user from accidentally doing something they may not want to.  Most of the time it just adds an extra step to performing an action.

I disable Windows Defender, I don't want to waste CPU cycles on something that is inevitable.  **Windows will get viruses.  That's why I make an image backup.**

I set the system clock to sync to a public UTP server, and display in 24-hour time.

I adjust indexing options, removing everything except the start menu.  I don't want the search to look through my files and folders, I don't use it for that.

I set the taskbar to auto-hide, check the new "use the desktop by default instead of metro" checkbox, and don't have it keep track of recent files per program.

I disable action center alerts for most things, except troubleshooting and updates.

By this point if windows has not already I will run the activation process.

Next I uninstall all of the worthless metro applications that I will never use.  _I didn't buy an 8 core CPU so I can look at one program at a time; I plan to multitask... a lot._

After that, any drivers for hardware on the system should be installed.  Doing so one at a time and rebooting when asked so as to avoid driver corruption.

I usually try to set the display settings, as I often have multiple monitors.  Unfortunately [Windows 8.1 has serious dpi issues which can cause all sorts of unpredictable behavior including inaccurate mouse detection and randomly enlarged components](shared/dpi.md).  This sucks, and it doesn't look like they plan to patch it.

Finally, depending on which version of windows, I may want to enable specific features, such as Legacy>DirectPlay and .Net3.5/2.0, as necessary for many games.  For whatever reason Microsoft decided nobody was using these.


### jis input

I generally prefer [adding JIS IME for japanese input](windows/jis.md).  While the input management in Windows 8 and Windows 8.1 continues to get better and better, it still acts erratic at times.

_At some point I managed to install the JIS IME and default to english input, remove the original english keyboard (reducing the number of hotkeys necessary to switch input modes), and without breaking at the login screen.  Unfortunately I have yet to be able to reproduce this, and anytime I've tried it has entirely broken the login screen by defaulting to japanese character inputs.  As a result I had to get the onscreen keyboard to enter my password._


### [custom fonts](shared/custom-fonts.md)

I install custom fonts, and set them as defaults in other tools later.


### turning capslock into control

I don't use capslock, ever.  It annoys me that it's such a large key, and in such a commonly traversed location.  So my solution is to turn it into something useful!

Open `regedt32` and go to the key at `[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout]`, and add a binary key named `Scancode Map` with the following values:

    00 00 00 00 00 00 00 00
    02 00 00 00 1D 00 3A 00
    00 00 00 00

The format is two 0-value byte headers in the first row, following by a byte with the size of the map (including the null-terminator), then we have 4-bit representation of keys where 1D is control and 3A is capslock, this remaps control to capslock.  Finally the null terminator, 8 empty bits indicating the end of the map.


### disabling "folders" in my computer

I'm plenty annoyed by the windows "Library" feature, given how useless a utility that is for a power user it was equally distressing when all the folders were suddenly added to my computer.  I don't use the mouse if I can help it, which means many more buttons to reach my destination (almost always a hard drive, iso, or network drive).  _I have my user folder on the desktop, why would I can about "Folders"?_

In any event, this too can be disabled.  Open `regedt32` and go to `[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\]`.  You will see the following hashes, simply delete them:

- Desktop Folder: {B4BFCC3A-DB2C-424C-B029-7FE99A87C641}
- Documents Folder: {A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}
- Downloads Folder: {374DE290-123F-4565-9164-39C4925E467B}
- Music Folder: {1CF1260C-4DD0-4ebb-811F-33C572699FDE}
- Pictures Folder: {3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}
- Videos Folder: {A0953C92-50DC-43bf-BE83-3742FED03C9C}


## software

**Utilities & Development:**

- [Google Chrome Dev Channel](http://www.chromium.org/getting-involved/dev-channel)
- [7zip](http://www.7-zip.org/)
- [SumatraPDF](http://blog.kowalczyk.info/software/sumatrapdf/free-pdf-reader.html)
- [Sublime Text](shared/sublime-text.md)
- [Silverlight (For Netflix)](http://www.microsoft.com/getsilverlight/Get-Started/Install/Default.aspx)
- [Visual Studio 2013](http://www.visualstudio.com/en-us/downloads)
- [golang](http://golang.org/)
- [git](http://git-scm.com/)
- [Flash Projector](shared/flash-projector.md)
- [jdk7](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
- [CCleaner](http://www.piriform.com/ccleaner)
- [Daemon Tools](http://www.daemon-tools.cc/downloads)

I prefer the google chrome browser, and generally opt for the dev channel install to get the latest features.  If you are more concerned with stability then feel free to pick the stable release or go with an alternative.

Utilities like 7zip and sumatrapdf are lightweight and incredibly well built.

I use sublime text regularly for note taking, and development.

_The express copy of Visual Studio 2013 is free._  Thought the professional version likely has more to offer.

I use ccleaner to cleanup my mess post-install, but usually never after.  Feel free to either not install it, or remove it after.

I don't have a dvd drive anymore, so anything I've had on disc is now an iso.  If I intend to use any of them, daemon tools is a great software for that.  I usually go with the lite version, as I only need mount support.


**Multimedia & Gaming:**

- [Steam](http://store.steampowered.com/)
- [K-Lite Codec Packs](http://codecguide.com/download_kl.htm)
- [ffsplit](http://www.ffsplit.com/)
- [Transmission-QT](http://trqtw.sourceforge.net/blog/)
- [Windows Movie Maker](http://windows.microsoft.com/en-us/windows-live/movie-maker)
- [Any Video Converter](http://www.any-video-converter.com/products/for_video_free/)
- [games](games/)

No modern gaming system would be complete without steam.  It's an excelent digital distribution platform, and has solved many of my game installation woes over the years.

I want lots of videos, and install the k-lite codec pack so I can continue using the builtin windows media player.  _In my personally opinion, the Windows Media Player is one of the best products that comes with their operating system, and in spite of my experiences with things like media player classic and VLC I have never really found them preferable._

The ffsplit software is an absolutely fantastic screen-capture, recording, and video merging software that is for Windows only.  It works out-of-the-box, allows you to easily specify capture devices and move them around on a display.  Setting the hotkeys, recording settings like resolution etc are simple too.  I use this with an HD Avermedia Capture Card and lay a webcam video ontop.  It took 5 minutes to get it ready for the first recording.

If you like to torrent, I recommend transmission-qt, it's the transmission client for windows with a QT interface, and is fairly robust.  It's leagues better than the corrupted [mutorrent](http://www.utorrent.com/).

Windows Movie Maker is a nice simple video clip editor, and I find it useful on occasion.  **It's part of the Windows Essentials, of which I only ever want this one, so I don't install the rest.**

Finally, the any-video-converter is a nice, free, video file format converter that can help when formats are not supported by windows media player or windows movie maker.

I suspect my choice of games will vary from most everyone else.  I have a set of documents on specific games that have quirks to get them working right.


_I recommend launching each program after installation to ensure it is functional.  Anything that asks for you to restart you should do so before proceeding to another installer._


### extension association game~

After installing all of these, we will want to set a number of file extensions to be associated with our system.  This is like a ritualistic song-and-dance for me, so here's the list:

Google Chrome:

- .gif
- .htm
- .html

Flash Projector:

- .swf

Sublime Text:

- .bash
- .bat
- .c
- .c++
- .cfg
- .conf
- .config
- .cpp
- .cs
- .css
- .csv
- .go
- .h
- .inf
- .ini
- .js
- .json
- .log
- .markdown
- .md
- .mkd
- .mkdown
- .php
- .ps1
- .py
- .sh
- .txt
- .zsh

Windows Photo Viewer:

- .bmp
- .jpg
- .png
- .tiff

Windows Media Player:

- .avi
- .flac
- .flv
- .midi
- .mkv
- .mp3
- .mp4
- .mpeg
- .mpg
- .ogg
- .ogm
- .rmvb
- .ts
- .wav

_Your preferences may vary._

Sadly, there is no "easy" way to do this in an automated fashion that I'm aware of, so I create a folder and fill it with empty files with those extensions.  Because windows is too dumb to figure out that they're all empty files, it'll assume the type associations, allowing us to right click and change association, and apply the change to all.


# references

Drivers for my own devices:

- [ASRock Z77 Extreme9](http://www.asrock.com/mb/Intel/Z77%20Extreme9/?cat=Download&os=Win8a64)
- [Logitech K810 Bluetooth Keyboard](http://www.logitech.com/en-us/support/bluetooth-illuminated-keyboard-k810?section=downloads&bit=&osid=23)
- [Microsoft XBox 360 Wireless Driver](http://www.microsoft.com/hardware/en-us/d/xbox-360-wireless-controller-for-windows)

Downloadable games I like:

- [Cave Story](http://www.cavestory.org/downloads_game.php)
- [SCP Containment Breach](http://www.scpcbgame.com/)
- [FFXIV](http://www.finalfantasyxiv.com/playersdownload/na/)

Personalized aesthetics:

- [FFXIV Theme](http://www.finalfantasyxiv.com/alliance/na/dl/)
