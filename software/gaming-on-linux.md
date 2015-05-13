
# gaming on linux

I am trying to move away from Windows forever, and am finally willing to give up a number of modern games to do so.


## games list

These are all of the games I'd like to play, although I am fully aware that some may never run in linux:

- 100% Orange Juice
- And Yet It Moves
- Bastion
- Borderlands
- Borderlands 2
- Bunny Must Die!
- Caster
- Coixleur Sigma
- Diablo 2
- Diablo 3
- doukutsu
- Dust: An Elysian Tail
- Dustforce
- The Elder Scrolls V: Skyrim
- Final Fantasy VII
- Final Fantasy VIII
- Fortune Summoners: Secret of the Elemental Stone
- FTL: Faster Than Light
- Guacamelee! Gold Edition
- Kerbel Space Program
- The Last Remnant
- Portal
- Portal 2
- Project Root
- Recettear: An Item Shop's Tale
- SCP: Containment Breach
- Skullgirls
- Strike Suit Zero Director's Cut
- Transistor
- Valdis Story Abyssal City
- Ys I
- Ys II
- Ys Origin
- Ys: The Oath in Felghana

Of this list so far, only "Project Root" fails to run.  I have not yet tried to install Diablo 3, but others have already claimed to have it working on linux so I have no concerns that it will be unavailable.


## steam & PlayOnLinux

The linux version of steam on Debian Jessie runs perfectly fine.

If you are running steam under WINE or PlayOnLinux, then you will want to add the `-no-dwrite` argument; without that argument no text will be visible.


### 100% Orange Juice

Steam game, not linux-native.

Install steam in PlayOnLinux.

The game installs but it depends on `dotnet35sp1` which depends on `dotnet35`, and requires a "reboot" between.  Installing 3.5 then shutting down playonlinux and restarting it appears to work fine, but it locked up several times during the install attempts prior to attempting the reboot-step.

Also during the first-run a cmd prompt opens and continues to state something about ".Net Runtime Optimization Service".  This eventually disappears and the game launcher is displayed.

_It appeared to experience noticeable delay between accepting mouse input, which could just be me._


### And Yet It Moves

Steam game with a linux native port.


### Bastion

Steam game with a linux native port.


### Borderlands

Steam game, not linux-native.

Install PlayOnLinux Steam, then download the game.

Runs fine with full-screen mode at smaller and higher resolutions.


### Borderlands 2

Steam game with a linux native port.


### Bunny Must Die!

Steam game, not linux-native.

Install PlayOnLinux Steam, then download and run the game.  It works out-of-the-box (at least windowed mode does).


### Caster

Steam game, not linux-native.

Install steam in PlayOnLinux.

Installs and runs, but the game itself is super-glitchy.  The character gets stuck in the floor constantly and hit-detection fails regularly.


### Coixleur Sigma

Steam game, not linux-native.

Install steam in PlayOnLinux.

The game installs, and begins to run but crashes with an unknown error:

    AddSourceFilter()

Subsequent attempts to run this game appear to have worked just fine.

_If you have no initialized controller, but the `xboxdrv` is running the input detects invalid data and assumes a locked-position causing the menu to spin wildly._  Turning off the `xboxdrv` service, or turning on a controller, both appear to resolve the issues.


### Diablo 2

Third Party, no linux-native release.

Runs perfectly fine in PlayOnLinux with some [specific modifications](http://www.gamersonlinux.com/forum/threads/diablo-ii-expansion-guide.217/).

- 32 bit (stable) wine release
- Wine Configuration:
    - Graphics Tab:
        - automatically capture mouse
        - allow window manager to decorate windows
        - allow window manager to control windows
        - emulate a virtual desktop (1024x768)
- Install Components:
    - Microsoft Core Fonts
    - d3dx9
- Run the downloaded installer

_Assuming you are using the non-CD based installer you shouldn't have any hassle with cdroms._

_There may be a missing step to resolve the updater.  If I find my documented instructions I will append to this list._


### Diablo 3

Third party, non-linux native.

Several posts have shown this to be working through Wine, I just need to download and install its dependencies.


### doukutsu

This game has a [linux port](http://www.cavestory.org/download/cave-story.php).  Simply download and extract the zip, and play.

There is supposedly a 1.2 patch, but I have not figured out how to apply it or what it "fixes".


### Dust: An Elysian Tail

Steam game with a linux native port.


### Dustforce

Steam game with a linux native port.


### The Elder Scrolls V: Skyrim

Steam game, not linux-native.

Install PlayOnLinux Steam, then download the game.

First-attempt to run the game tries installing .NET which fails.

Two possible ways to attempt to fix this:

- install `vcruntime2008` component
- install .NET 3.5 component
- disable lines in the `installscript.vdf` in the path for the game (`steamapps/common/Skyrim/`) and try again

It seems some combination thereof worked well enough to get the game started without further trouble.



### Final Fantasy VII

Steam game, not linux-native.

Install PlayOnLinux Steam, then download the game.

First attempt to run failed with a random error.  The second attempt the launcher came up fine.

Tempting fate I enabled the "Cloud Sync" option, which locked up the launcher permanently.  Even after rebooting the system I still could not get it to run, so I deleted local content and began the download again.

_The game runs, but the cloud sync appears to be busted.  So do not enable that feature if you want the game to run._  It seems the first attempt to run also fails regularly, subsequent attempts should succeed.


### Final Fantasy VIII

Steam game, not linux-native.

Install PlayOnLinux Steam, then download the game.

The save-data synchronization works fine, and the game also launches as well.

_There was a crash on exit where the launcher would not close, which took a moment before it was forced to exit._  This did not interfere with the ability to run/play the game.


### Fortune Summoners: Secret of the Elemental Stone

Steam game, not linux-native.

Install PlayOnLinux Steam, then download the game.

_Currently fails to play music._  However, sound effects work.  **Use "Zoom Mode" for full-screen gameplay.**

Fix for Music; Suggestion is to install three components:

- directmusic
- dsound
- wmp10

_These do work to get audio running, and as in the winehq referenced solution there is a very mild static behind the music, perhaps simply due to the playback volume._


### FTL: Faster Than Light

Steam game with a linux native port.


### Guacamelee! Gold Edition

Steam game with a linux native port.


### Kerbel Space Program

Steam game with a linux native port.


### The Last Remnant

Steam game, not linux-native.

Install PlayOnLinux Steam, then download the game.

You may have to install the `vcrun2005` component in order to run this game.

The game runs beautifully even at the highest settings.


### Portal

Steam game with a linux native port.


### Portal 2

Steam game with a linux native port.


### Project Root

**DOES NOT RUN**

Steam game, not linux-native.

It seems to come with vcrun2010 and DirectX June2010 software.

Crashes with two dialogs, starting with `CGfxSystem::CreateEx` which yields absolutely no google search results.  Oddly enough I could find nothing to debug this further with.


### Recettear: An Item Shop's Tale

Steam game, not linux-native.

Install PlayOnLinux Steam, download the game, and launch.

_If you have no initialized controller, but the `xboxdrv` is running the input detects invalid data and assumes a locked-position causing the menu to spin wildly._  Turning off the `xboxdrv` service, or turning on a controller, both appear to resolve the issues.


### SCP: Containment Breach

Third Party Game, no linux-native release.

Supposedly works fine in WINE with linux, should just be a matter of installing with dependencies.


### Skullgirls

Steam game, not linux-native.

Install PlayOnLinux Steam, download the game, then run it.

**This game worked out-of-the-box for me, but it may have required one of the other installed components.**  In the future I may test from a blank slate every one of these games to make sure shared-dependencies are not a concern.


### Strike Suit Zero Director's Cut

Steam game with a linux native port.


### Transistor

Steam game with a linux native port.


### Valdis Story Abyssal City

Steam game, not linux-native.

Install PlayOnLinux Steam, download and run the game.

_If you have no initialized controller, but the `xboxdrv` is running the input detects invalid data and assumes a locked-position causing the menu to spin wildly, or be locked in-place._  Turning off the `xboxdrv` service, or turning on a controller, both appear to resolve the issues.


### Ys I

Steam game, not linux-native.

Install PlayOnLinux Steam, download and run the game.

The game runs flawlessly in full-screen mode.  You can choose to configure it so the graphics are not horrifically minified.


### Ys II

Steam game, not linux-native.

Install PlayOnLinux Steam, download and run the game.

The game runs flawlessly in full-screen mode.  You can choose to configure it so the graphics are not horrifically minified.

It also offers an option to connect to the Ys I data.  I do not know what effects this will have on the game itself.


### Ys Origin

Steam game, not linux-native.

Install PlayOnLinux Steam, download and run the game.

The game configuration must be set to match the window manager's resolution, otherwise the game may crash and cause residual resolution changes to be forced upon the window manager.  _This required me to relaunch openbox._

When set to a matching resolution, the game and audio loaded just fine.  (Though it is possible that the components needed for Fortune Summoners are also required for the audio here since I did not test in a clean environment)


### Ys: The Oath in Felghana

Steam game, not linux-native.

Install PlayOnLinux Steam, download and run the game.

I performed the same resolution-matching as I did with Ys Origin, and the game loaded just fine.  It may, or may not, require the same Fortune Summoner packages for audio, or the same resolution-matching as Ys Origin to launch.

In any event, this game runs fine.


# references

- [steam]()
- [wine]()
- [PlayOnLinux]()
