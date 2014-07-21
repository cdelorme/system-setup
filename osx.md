
# OS X Mavericks (10.9) Documentation
#### Updated 2014-7-20

For me this document is an aid to help reproduce my OSX Mavericks (10.9) development environment.

For anyone else it's a comprehensive guide to optional configuration for OSX.


## installation

**Do not:**

- use a Case Sensative HFS+, this breaks software like the entire Adobe suite.
- encrypt your drive (eg. `File Vault`), it may need re-encryption after updates.

Which leads us to the first post-install step:

- check for updates.


## mythical root user

The root user exists on osx, and its `$HOME` is `/var/root`.  By default the root account on OSX uses the `/bin/sh` shell.

I tested switching it to `/bin/bash` and configuring the environment a bit, but the end result involved some undesirable performance issues.  So I do not recommend tampering with it.


## automatic updates

The latest release of OSX features automatic updates!  While this worries me, it is not at the level of "Windows Updates" and will not force a reboot.  However it will pop open a notification if an update requires a reboot.

Having now used it for a few months, it seems to be very reliable.  More importantly it has not interfered with or hindered my productivity.


## updated firewall

This is something I was not aware of when I first updated, but the latest firewall is extra awkward at responding to updated applications.  Anytime an application replaces itself during an update, your firewall will ask again if you want to allow it.

I have found this feature to be incredibly annoying, to the point of nearly wanting to disable the firewall.  If I allow a software, all versions of that software should be allowed.  I don't expect the firewall should have to store the file signature and bother me everytime it changes, but this is a "feature" of OSX now and I'll have to deal with it.


## system preferences

These are the changes I make to my `System Preferences`, and are listed by the main section, then each sub-option:

- General
    - Graphite Color-scheme
    - Recent Items: None

- Dock
    - Smaller Size (slider)
    - Slight Maginification (slider)
    - Align Right (radio)
    - Scale effect (dropdown)
    - All checkboxes
        - Double-click a window's title bar to minimize
        - Minimize windows into application icon
        - Animate opening applications
        - Autmatically hide and show the dock
        - Show indicator lights for open applications

- Mission Control
    - Do Not "Show Dashboard from F12" (checkbox)
    - Do Not "Automatically rearrange Spaces based on most recent use" (checkbox)
    - Check the remaining boxes
    - Hot Corners
        - Show Desktop (top right)

- Language & Region
    - 24-Hour Time (checkbox)

- Security & Privacy
    - General
        - Require Password 1 Minute after Display Sleep
    - Firewall
        - Turn Firewall On
        - Firewall Options:
            - Stealth Mode

- Display
    - Disable "Automatically adjust brightness"

- Energy Saver
    - Battery Display Sleep after 5 Minutes (slider)
    - Computer sleep after 10 minutes (slider)
    - Do Not "Put hard disks to sleep when possible" (checkbox)

- Keyboard
    - Keyboard
        - Turn off key backlighting after 10 seconds of inactivity
        - Modifier Keys:
            - Caps Lock > Control
    - Shortcuts
        - Launchpad & Dock
            - Disable toggle dock hiding
        - Mission Control
            - Disable "Show Dashboard" (F12)
            - Enable "Show Desktop" (F11) (checkbox)
            - Turn on control hotkey Switch to Desktops 1 & 2
        - Keyboard
            - Disable "Turn keyboard access on or off" (checkbox)
            - Disable "Change the way Tab moves focus" (checkbox)
        - Input Sources
            - Enable "Select next source in Input menu" (cmd+alt+space) (checkbox)
        - Spotlight
            - Disable "Show spotlight window" (checkbox)
        - Accessibility
            - Disable "Turn VoiceOver on or off" (checkbox)
            - Disable "Show Accessibility controls" (checkbox)
        - Select "All controls" at bottom (radio)
    - Input Sources
        - Add Kotoeri (for Japanese Inputs)
        - Show in menu bar (checkbox)

- Trackpad
    - Point & Click
        - Enable "Tap to Click" (checkbox)
        - Disable "Look Up" 3 finger tap
        - Increase "Tracking Speed" (slider)
    - More Gestures
        - Enable App Expose (three finger down)
        - Disable Launchpad

- Sound
    - Tink (Alert Sound)
    - Reduced Alert Volume
    - Disable "Play feedback when volume is changed" (checkbox)

- Bluetooth
    - "Turn Bluetooth Off" (conserves battery)

- Sharing
    - Set your hostname to something less obnoxiously long (usually "full first & lastname's macbook")

- Time Machine
    - Do not show menu bar icon

Other minor tweaks include adding at least one extra desktop to Mission Control by default, and from the battery menu I have it "Show Percentage".

_These are my preferences, obviously your settings are subject to your own discretion._


## custom fonts

- [ForMateKonaVe](http://d.hatena.ne.jp/hetima/20061102/1162435711)
- [EPSON Kyoukashoutai](http://www.wazu.jp/gallery/Fonts_Japanese.html)

The EPSON font has been uploaded with skewed ASCII conversion, so while the font will work, its name is nearly impossible to type.  I recommend running it through a font editor simply to adjust the name to something sensible.

_The links for these fonts are externally hosted and may no-longer be valid, and I have decided to include a copy of each in this repository._

Installing fonts can be done by opening them and clicking the install button, or you can install them locally into `~/Library/Fonts/`, or globally `/Library/Fonts`.


## disable dashboard

I think the dashboard is a waste of space and resources and elect to disable it.  Applications load fast enough on SSD's that micro-applications are not nearly as useful as they may have been years back.


##### commands

_To stop the dashboard from starting by default:_

    defaults write com.apple.dashboard mcx-disabled -boolean YES
    killall Dock


## finder settings

Open the finder settings menu with command + j.  _The desktop has a separate menu, so be sure you have selected a finder window before using the hotkey._

I generally check the box to force `List View` as the default.  I also check the calculate size option, because it makes checking folder and file sizes fast and easy.

This release has provided a checkbox to **display the `~/Library` folder**, which saves us an extra step we previously had to do via command line.

**Be sure you select "Use as Defaults" at the bottom or it won't take globally.**  Afterwards you'll want to remove saved view settings (the `.DS_Store` hidden files) recursively and globally to ensure the new settings take and are not overwritten locally per directory.


##### commands

_Run this to remove saved view settings and reload finder:_

    sudo find / -name ".DS_Store" -depth -exec rm {} \;
    killall Finder

_To fix the hidden `~/Library` via terminal, run this:_

    chflags nohidden ~/Library


## set hostname & domain name

You will want to set the machines host name, by default it will be your full name, which is often obnoxiously long for a network name.  You can set your hostname in `System Settings` under `Sharing`.  It can also be done via command line, but may not take affect globally until a reboot.

You can set your domain name via command line as well.


##### commands

_Run this command to set your hostname via terminal:_

    sudo scutil --set HostName mypc

_Full affects may not take place until rebooting._

_To set your domain name:_

    domainname example.loc


## configure terminal

I generally install and use [iTerm2](http://www.iterm2.com/#/section/home), but I also configure the default terminal just in case I need to use it.

I set the default color scheme to `Homebrew` with my choice of custom font (ForMateKonaVe) size 14.  I also go to the window tab and click the color & background button to set opacity to 40% with a 5% blur.


## app store

Here are some items I always grab from the App Store:

- [Dash](https://itunes.apple.com/us/app/dash-docs-snippets/id458034879?mt=12)
- [Unarchiver](https://itunes.apple.com/us/app/the-unarchiver/id425424353?mt=12)
- [XCode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12)

_Dash is a mac only software that costs money, but it is a worth-while purchase.  It gives you a complete comprehensive local copy of documentation for multiple languages.  This is awesome for travel purposes, or even just quick-checks on object types or method arguments.  I highly recommend it._

I would consider XCode optional.  If you do not plan to be developing for Mac using their specific libraries and Objective-C, then you probably don't need it.  I still install it, but I never use it.  Also it cane take upwards of two hours to download.


## software

Here is a list of software I install:

- [Google Chrome Dev Channel](http://www.chromium.org/getting-involved/dev-channel)
- [Google Hangouts Plugin](https://www.google.com/tools/dlpage/hangoutplugin)
- [Sublime Text](http://www.sublimetext.com/3)
- [RoboMongo](http://robomongo.org/)
- [Sequel Pro (aka Pancakes)](http://www.sequelpro.com/)
- [iTerm2](http://www.iterm2.com/#/section/home)
- [VirtualBox](https://www.virtualbox.org/)
- [Transmission](http://www.transmissionbt.com/download/)
- [VLC](http://www.videolan.org/vlc/download-macosx.html)
- [xQuartz](http://xquartz.macosforge.org/landing/)
- [Adobe Flash Projector](http://www.adobe.com/support/flashplayer/downloads.html)
- [Java JDK](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)

VirtualBox is a free Virtual Machine software that has better linux guest support and more up-to-date features (like efi booting) that VMWare and Parallels.  It is also cross platform, so you can use the same software on any machine.  These combined benefits make it my preferred (type 2) VM software of choice.

The xQuartz package is a necessary evil for certain packages we'll install later.

In spite of the fact that flash is a dying industry, I often find myself in need of the ability to run an swf file, and the Flash Projector comes in a debug flavor, which makes it super easy to have a tiny executable that can run and test flash files without browser concerns.


## sonfiguring installed software

### dash

Let's start with some basic configuration options.

To validate your purchased copy you may have to visit the `Purchase` tab and pick the appropriate option.

I use the HUD mode with `alt + space` as the hotkey to pull it up.  It starts with my system, and turn off its dock icon.  I show the menubar icon, but tell clicking to open the menu (not the application).

Here is a list of documentation I generally select (there are tons more):

- Bash
- Bootstrap 3
- C
- C++
- Cmake
- CSS
- Emmet
- GLib
- Go
- HTML
- Java EE7
- JavaScript
- jQuery
- Man Pages
- Markdown
- Mongodb
- MySQL
- Nginx
- Node.js
- OpenGL 3
- OpenGL 4
- Python 2
- Python 3

The latest release also offers Cheat Sheets, which I also downloaded a few from:

- Git
- Git Flow
- HTML Entities
- Regular Expressions
- Sublime Text
- Tmux
- Vim

While I install a large number of docsets, I generally only enable the docsets related to the things I am working on.  So as I switch between projects I may tweek what docs are displayed when I search for things.

There are also many integration options for Dash.  For example you can configure it to run directly inside of tools like Sublime Text and XCode.


### the unarchiver

Preferred Settings:

- Select all archive formats for affiliation
- Select to always extract to the same folder as the archive is
- Create a new folder if there is more than one top-level item
- Move the archive to the trash after extraction
- Under advanced set automatic detection confidence level to 100%

_It is highly unlikely that the archiver won't know an encoding that a user would be able to pick from that giant list._


### iterm2

Open the configuration and go to "Profiles" > "Text", then change the font settings (for regular font):

- Size 14 Font
- ForMateKonaVE Font Family

Next select "Profiles" > "Terminal" and click the checkbox for "Unlimited scrollback".

Now go to "Profiles" > "Keys" and add these key combinations:

- alt + delete: HEX 0x17
- alt + left arrow: escape sequence + b
- alt + right arrow: escape sequence + f

This will allow you to use alt to jump between words while in iTerm2 (eg delete whole word, go back a word, go forward a word).

Finally, import the [`Solarized High Contrast Dark`](https://github.com/mariozaizar/dotfiles/blob/master/themes/iTerm2/Solarized%20High%20Contrast%20Dark.itermcolors) color scheme from the GUI.

_Color schemes in iterm are loaded into a plist file and so doing so from command line is not as easy.  Someday I will document how to, if I ever figure it out myself._


### virtualbox

VirtualBox offers USB 2.0 support, but you have to download and install the [Extension Pack](https://www.virtualbox.org/wiki/Downloads).

I also recommend creating a Host-Only network with a predictable IP range (I generally use 10.0.5.1).

_VirtualBox networking is a bit complex.  There are built-in firewalls around their NAT, so you can't simply access ports, you have to have an internal "unsafe" network adapter, and then an internet access network adapter.  The combination generally tends to be NAT + Host-Only._


### transmission

Transmission is among my favorite software list now.  They provide a client and command line controls, for unix & linux platforms.  So far they have the best customizability, greatest cross platform support (minus windows) and most sensible configuration I've seen for what could operate as a torrent server software.

In the settings under "General" I tell it not to prompt when removing a torrent.  I also tell it to display the speeds in the "Badge" (viewed when alt + tabbing).

Under the "Transfers" tab I tell it to autoload `.torrent` files from `~/Downloads` and to save finished files there.  I tell it to keep the `.torrent` files inside `~/Downloads/.torrent/` and to keep partial downloads in `~/Downloads/.torrent/downloading/` and to append `.part` to the file names.  I tell it **not** to display confirmation when loading a torrent.

I setup a schedule under the "Bandwidth" tab to accomodate my access times.

Finally under the "Peers" tab I tell it to prefer encrypted peers **and** ignore unencrypted peers.  _This is a weak stop-gap against torrent scanners._


## [homebrew](http://brew.sh/)

This process has changed since OSX 10.8 and there are many steps past installing it to cover.

OS X is running UNIX, but it does not come with a package manager by default.  As such two have been created.  There is [macports](http://www.macports.org/) if you would rpefer, but I use homebrew.  You can use both if you want to get software that each provides.  I prefer the homebrew `no-password` phylosophy towards installing user-local software.

**Homebrew depends on Command Line Tools, but the latest version of the install script will ask you to install the command line tools automatically.**

Here is my comprehensive list of recommended homebrew packages, including all dependent packages:

- readline
- apple-gcc42
- pkg-config
- intltool
- cmake
- autoconf
- gmp4
- bash-completion
- libexif
- watch
- gmp
- d-bus
- cabextract
- libffi
- openssl
- git-flow
- mercurial
- node
- go
- phplint
- libunistring
- aspell
- ilmbase
- openexr
- jbig2dec
- fftw
- hicolor-icon-theme
- boost-build
- glew
- mpfr
- isl
- scons
- bzr
- awscli
- fop
- nspr
- xz
- gettext
- libevent
- libgpg-error
- pcre
- jpeg
- nasm
- jpeg9
- libpng
- libusb
- libtool
- libgsm
- gettext
- gdbm
- libtasn1
- bdw-gc
- icu4c
- giflib
- lame
- gsl
- boost
- popt
- libxml2
- lame
- libogg
- sdl2
- unixodbc
- mpfr2
- isl011
- tmux
- automake
- jpeg-turbo
- winetricks
- cppcheck
- git
- wget
- nettle
- guile
- swftools
- libsigc++
- libmpc
- cloog
- rtmpdump
- lua
- libgcrypt
- libtiff
- freetype
- libusb-compat
- jasper
- glib
- sqlite
- pixman
- p11-kit
- webp
- flac
- libvorbis
- glfw3
- osxfuse
- libmpc08
- cloog018
- gnutls
- liblqr
- sshfs
- tidy
- glibmm
- youtube-dl
- wxmac
- gd
- little-cms2
- libicns
- sane-backends
- python3
- fontconfig
- gobject-introspection
- little-cms
- libsndfile
- gcc48
- vim
- weechat
- libwmf
- ghostscript
- openjpeg
- erlang
- spidermonkey
- libgphoto2
- cairo
- gdk-pixbuf
- atk
- wine
- imagemagick
- graphicsmagick
- at-spi2-core
- harfbuzz
- cairomm
- atkmm
- poppler
- couchdb
- py2cairo
- py3cairo
- at-spi2-atk
- pango
- pygobject3
- gtk+
- gtk+3
- pangomm
- gtkmm
- zenity
- php54

Originally I had grouped packages by type, but I realized during this latest installation that dependencies were a big concern if you are running something like `wine` which needs the 32 bit "universal" build.  As such I now list them in dependency order.

Many packages have custom build options, dependencies, and post-installation instructions.  To check for this information you can run `brew info package`.

_Note that on your first execution of the `sshfs` command (or mount type) you will get a warning popup notifying you of an untrusted kext, it'll still work but you'll have to click the ok the first time._

_During my last tests there was an `inkscape` package in brew that did not yet work, and the pygobject3 package is also broken due to an issue with python3 copy of gi-repository not existing._


##### commands

_Let's start by adding this line (with your own token) to your dot-files such as `~/.profile` or `~/.bashrc` or `~/.bash_profile` to bypass github API traffic limits:_

    export HOMEBREW_GITHUB_API_TOKEN=YOURTOKEN

_If you are using my [dot-files repository](https://github.com/cdelorme/dot-files/), the install script accepts your github username and password, and will auto-detect that you are using OS X and get you a fresh token on install._

_Run these commands to install homebrew and all of my packages:_

    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

_If you have not already installed the OSX Command Line Tools, brew's install script will automatically launch the installer prompt, which is awesome since we don't need to spend two hours downloading xCode anymore.  Next we want to run a few commands as a pre-amble to our package installation:_

    brew doctor
    brew tap homebrew/versions
    brew tap homebrew/dupes
    brew tap josegonzalez/php
    brew update

_This is my complete set of packages, and all the options I use to install them:_

    # no dependencies
    brew install readline
    brew install apple-gcc42
    brew install pkg-config
    brew install intltool
    brew install cmake
    brew install autoconf
    brew install gmp4
    brew install bash-completion
    brew install libexif
    brew install watch
    brew install gmp
    brew install d-bus
    brew install cabextract
    brew install libffi
    brew install openssl
    brew install git-flow
    brew install mercurial
    brew install node
    brew install --cross-compile-all go
    brew install phplint
    brew install libunistring
    brew install aspell
    brew install ilmbase
    brew install openexr
    brew install jbig2dec
    brew install fftw
    brew install hicolor-icon-theme
    brew install boost-build
    brew install glew
    brew install mpfr
    brew install isl
    brew install scons
    brew install bzr
    brew install awscli
    brew install fop
    brew install nspr

    # universals no dependencies
    brew install --universal xz
    brew install --universal gettext
    brew install --universal libevent
    brew install --universal libgpg-error
    brew install --universal pcre
    brew install --universal jpeg
    brew install --universal nasm
    brew install --universal jpeg9
    brew install --universal libpng
    brew install --universal libusb
    brew install --universal libtool
    brew install --universal libgsm
    brew install --universal gettext
    brew install --universal gdbm
    brew install --universal libtasn1
    brew install --universal bdw-gc
    brew install --universal icu4c
    brew install --universal giflib
    brew install --universal lame
    brew install --universal gsl
    brew install --universal --c++11 boost
    brew install --universal popt
    brew install --universal libxml2
    brew install --universal lame
    brew install --universal libogg
    brew install --universal sdl2
    brew install unixodbc --universal

    # dependency chain level 1
    brew install mpfr2
    brew install isl011
    brew install tmux
    brew install automake
    brew install jpeg-turbo
    brew install winetricks
    brew install cppcheck
    brew install --with-gettext --with-pcre git
    brew install wget
    brew install nettle
    brew install guile
    brew install --with-fftw --with-jpeg --with-giflib --with-lame --with-xpdf swftools
    brew install libsigc++
    brew install libmpc
    brew install cloog
    brew install rtmpdump

    # universal, dependency chain level 1
    brew install --with-completion --universal lua
    brew install --universal libgcrypt
    brew install --universal libtiff
    brew install --universal freetype
    brew install --universal libusb-compat
    brew install --universal jasper
    brew install --universal glib
    brew install --universal sqlite
    brew install --universal pixman
    brew install --universal p11-kit
    brew install --universal webp
    brew install --with-libogg --universal flac
    brew install --universal libvorbis
    brew install --universal glfw3

    # dependency chain level 2
    brew install osxfuse
    brew install libmpc08
    brew install cloog018
    brew install --with-guile gnutls
    brew install liblqr
    brew install sshfs
    brew install --HEAD homebrew/dupes/tidy
    brew install glibmm
    brew install --with-rtmpdump youtube-dl
    brew install wxmac

    # universal, dependency chain level 2
    brew install --universal --with-freetype --with-libtiff gd
    brew install --universal little-cms2
    brew install --universal libicns
    brew install --universal sane-backends
    brew install --universal --with-brewed-openssl python3
    brew install --universal fontconfig
    brew install --universal gobject-introspection
    brew install --universal --with-python little-cms
    brew install --universal libsndfile

    # dependency chain level 3
    brew install --enable-multilib gcc48
    brew install --with-lua --with-python3 --override-system-vi vim
    brew install --with-aspell --with-lua --with-python --with-guile --with-perl weechat
    brew install libwmf
    brew install ghostscript
    brew install openjpeg
    brew install erlang
    brew install spidermonkey

    # universal, dependency chain level 3
    brew install --universal --with-libexif libgphoto2
    brew install --universal cairo
    brew install --universal gdk-pixbuf
    brew install --universal atk
    brew install --universal --with-python svn

    # dependency chain level 4
    brew install --with-libgsm wine
    brew install --with-fontconfig --with-ghostscript --with-jasper --with-liblqr --with-libtiff --with-libwmf --with-little-cms2 --with-openexr --with-perl --with-webp imagemagick
    brew install --with-ghostscript --with-libtiff --with-jasper --with-libwmf --with-little-cms2 --with-perl graphicsmagick
    brew install at-spi2-core
    brew install harfbuzz
    brew install cairomm
    brew install atkmm
    brew install --with-glib --with-lcms2 poppler
    brew install couchdb

    # universal, dependency chain level 4
    brew install --universal py2cairo
    brew install --universal py3cairo || brew install py3cairo

    # dependency chain level 5
    brew install at-spi2-atk
    brew install pango

    # dependency chain level 6
    brew install --with-jasper gtk+
    brew install --with-jasper gtk+3
    brew install pangomm

    # dependency chain level 7
    brew install gtkmm
    brew install zenity
    brew install --universal --with-python3 --with-libffi pygobject3
    brew install php54 --with-intl --with-tidy --without-apache

_The gobject-introspection, python3, and pygobject3 packages are finally working properly, the caveat being that you must install both python2 and python3 for the pygobject3 to build for python3 (odd I know)._

_Finally, here is a set of cleanup tasks to run, if you look at the output for the related packages they contain the instructions telling you to run these commands:_

    brew link --overwrite jpeg9
    ln -s /usr/local/bin/gcc-4.8 /usr/local/bin/gcc
    ln -s /usr/local/bin/g++-4.8 /usr/local/bin/g++
    mkdir -p ~/Library/LaunchAgents
    LDBUSFOLDER=""
    for DBUSFOLDER in /usr/local/Cellar/d-bus/*
    do
        LDBUSFOLDER=$DBUSFOLDER
    done
    mkdir -p ~/go/{bin,src,pkg}
    cp "/usr/local/Cellar/d-bus/${LDBUSFOLDER}/org.freedesktop.dbus-session.plist" ~/Library/LaunchAgents/
    launchctl load -w ~/Library/LaunchAgents/org.freedesktop.dbus-session.plist
    brew doctor
    LOSXFUSEFOLDER=""
    for OSXFUSEFOLDER in /usr/local/Cellar/osxfuse/*
    do
        LOSXFUSEFOLDER=$OSXFUSEFOLDER
    done
    sudo /bin/cp -RfX "/usr/local/Cellar/osxfuse/${LOSXFUSEFOLDER}/Library/Filesystems/osxfusefs.fs" /Library/Filesystems
    sudo chmod +s /Library/Filesystems/osxfusefs.fs/Support/load_osxfusefs
    sudo youtube-dl -U


## dot-files

**Next I recommend using my [dot-files repository](https://github.com/cdelorme/dot-files/) to enhance your prompt, vim configuration, and set a bunch of useful configuration defaults.**

Creating a set of useful dot-files is essential to enhancing your command line situation, but not everyone will find all of my settings to be useful.


## configuring golang

I recommend installing [goconvey](https://github.com/smartystreets/goconvey) and [gin](https://github.com/codegangsta/gin).

The first is a test enhancer that will make it easier to read debug output.

The second allows you to run a project while watching for file changes and automatically rebuilding and running it.  This is very useful for web development, but not as much for run-time application development or command development.


##### commands

_Run these lines to install the recommended go packages:_

    go get -t github.com/smartystreets/goconvey
    go get github.com/codegangsta/gin


### installing `pip` & python packages

The python package manager should be installed if you intend to use python (and you probably will without realizing it).

If you develop in python you will want `pip` to add the `pep8` package for syntax support.  For interactive python debugging you should also install [bpython](https://pypi.python.org/pypi/bpython).

Additionally we want to install the virtual environment wrapper, such that we can have more finely tuned controls per application or environment as for what python version is to be used and packages are installed.


##### commands

_If you did not use brew to install python, or for whatever reason brew did not install `pip`, then you will want to run this first:_

    sudo easy_install pip3

_Then you can run this to install and update related packages:_

    sudo pip install virtualenvwrapper
    pip3 install --upgrade setuptools
    pip3 install --upgrade pip
    pip3 install bpython
    pip3 install pep8
    pip install virtualenv
    pip3 install virtualenv

_You can omit the 3.3 and use just pip if you program in the 2.x version of python._


### nodejs globals

For nodejs development, I recommend installing some tools globally.  Here is my recommended list:

- csslint
- jshint
- csso
- yo
- grunt
- grunt-watch
- markdown
- forever
- mocha
- jscoverage
- uglify-js


##### commands

_To install nodejs globals:_

    npm install -g csslint jshint csso uglify-js mocha jscoverage yo grunt grunt-contrib-watch markdown forever bower

_You may optionally add `mongo` and `mysql` as needed, but it may be wiser to use a local copy of those per project.  Same goes for bower and grunt packages, if you expect many projects to be using them at the same time._


### creating a crontab

Ideally you should setup a script to automatically update your homebrew and npm packages.  One good option for this is your "crontab".


##### commands

_You can put the script in `/usr/local/bin/autobrewnpm` and you can add these lines:_

    #!/bin/bash

    brew update
    brew upgrade
    npm update

_Make sure the script file you create is executable._

_You can run `crontab -e` to open your crontab (likely new/empty), and add this line:_

    0 2 * * * /usr/local/bin/autoupdate &> /dev/null

_This script should now execute everyday at 2AM._


### path modifications

Many of the packages you install with homebrew will already exist on the machine.  When you run a command it checks the paths in the order they appear in the PATH variable and stops as soon as it finds the command.  To use the new versions of same-named commands you have to change the `PATH` global variable to include the local bin first.  Be sure to add this to your `~/.bashrc`:

    export PATH=/usr/local/bin:/usr/local/sbin:$HOME/bin:$PATH

_This is one of the many modifications that is handled by my dot-files automatically._


### ssh key generation

It is recommended that you generate an ssh key, which can be used for ssh tunneling, numerous encryption services, and version control software.

**OS X should automatically remember and reload any keys you have added at reboot.**


##### commands

_Create SSH key and add to ssh-agent:_

    ssh-keygen -t rsa -b 4096 -C "<youremail>"
    ssh-add -K ~/.ssh/id_rsa

_You will have to follow prompts when creating the key, and your email is an optional flag._



### git configuration

I usually set a number of defaults in my `~/.gitconfig`:

- username
- email
- editor
- auto-correction
- color ui
- push auto-match branch
- several aliases

The `~/.githelpers` file was written by [Gary Bernhardt](https://github.com/garybernhardt/dotfiles/blob/master/.githelpers), and is also included with my dot-files repo.

I generally create a `~/git/` folder to store my projects.

I highly recommend [Ralph Bean's Awesome Git Flow Tutorial](http://threebean.org/presentations/gitflow/#/step-1) and the [Git Bash Completion](https://github.com/git/git/blob/master/contrib/completion/git-completion.bash) script (included with my `dot-files`).


##### commands

_Run these and optionally fill in the blanks:_

    git config --global user.name "<yourname>"
    git config --global user.email "<youremail>"
    git config --global core.editor "vim"
    git config --global help.autocorrect 1
    git config --global color.ui true
    git config --global push.default matching
    git config --global alias.a add
    git config --global alias.s 'status -suall'
    git config --global alias.c commit
    git config --global alias.st stash
    git config --global alias.sa 'stash apply'
    git config --global alias.l '!. ~/.githelpers && pretty_git_log'
    git config --global alias.pp '!git pull && git push'


### activate bash-completion

Even after installing it with homebrew, you may have to add a symlink for it to be loaded.  Additionally you may need to load it from command line by running that symlink.


##### commands

_Run this to create the symlink:_

    ln -s "/usr/local/Library/Contributions/brew_bash_completion.sh" "/usr/local/etc/bash_completion"

_Add this to your `~/.bashrc` or `~/.profile`:_

    if [ -f $(brew --prefix)/etc/bash_completion ]; then
      . $(brew --prefix)/etc/bash_completion
    fi

_This is another configuration that I include in my dot-files repository._


### [sublime text](https://github.com/cdelorme/system-setup/tree/master/shared_config/sublime_text.md)

Since installing and configuring sublime text is nearly identical between platforms I've moved its instructions to a more centralized location.  Click the header link to read it!


## markdown quicklook

I install this so I can easily preview markdown files, the [repository is here](https://github.com/toland/qlmarkdown), but you can [download a prebuilt file here](http://jamesmoss.co.uk/blog/support-for-markdown-in-osx-quicklook/) and toss them into `/Library/QuickLook`.

With this package you can use the space-bar like with images and pdf files, and it will display HTML rendered preview of a markdown file.


## reorganize dock

I remove any other software from my dock except the following list:

- finder
- chrome
- safari
- sublime text
- iterm2
- virtualbox
- transmission
- robomongo
- sql pro
- itunes
- ibooks
- app store
- system preferences
- _divider_
- downloads
- trash

I do use more software than is in this list, but I almost never use the dock to access it, I use spotlight because it is faster.  **This list is really here for drag-and-drop applications.**


## sync accounts

I no longer bother synchronizing my accounts, but if you choose to do so you can hook your gmail up to your `Mail`, `Contacts` and `Calendar` software on the system.

I do syncrhonize my google chrome, but because I use google chrome I do not need any of the other software configured.


## file vault

I no longer bother encrypting my drive.  It has a small performance hit, and **may still be a good idea for mission critical business laptops**, but the hard drive is now soldered into the machine.  The new machines have soldered their drives in, so it's significantly less likely they will be able to hook it up to another machine running OS X.  It also has no CD drive.  This leaves only USB bootable media to access the drive contents, and to my recollection linux can't read journaled HFS+ drives.

As mentioned in my previous documentation, if you intend to encrypt your drive, wait until you have finished installing all system updates because patches to the encryption code will require you to decrypt, update, then re-encrypt; a process which can take many hours.


## conclusion

Thus concludes my comprehensive OS X 10.9 setup and configuration process.  If you have configured your machine in the same way it will be ready for most development projects.

Note that despite how many tools I install on the system, I prefer, and often use, virtualization to offload a majority of testing to keep the main system running light and smooth.  Many services like a database or web server would consume resources if run while not in use, and add to the number of things my main system is then responsible for.

For that reason I recommend visiting my [debian documentation](../linux/debian) and setting up a virtual machine for web development or any code that can be offloaded and is not needed on your host.


## references

- [OS X Fonts](http://support.apple.com/kb/ht2435)
- [iTerm2 Config](https://code.google.com/p/iterm2/issues/detail?id=1052)
- [Remap Capslock](http://stackoverflow.com/questions/127591/using-caps-lock-as-esc-in-mac-os-x)
- [iTerm2 alt hotkeys](https://code.google.com/p/iterm2/issues/detail?id=1052)
- [iTerm2 unlimited history](http://stackoverflow.com/questions/12459755/zsh-iterm2-increase-number-of-lines-history)


## future goals

- I want to figure out how to modify plist files from command line so I can automate the configuration of various software, which can be done with lines similar to `defaults read com.apple.LaunchServices.plist`, but I have not yet experimented with it enough.
