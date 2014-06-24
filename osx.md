
# OS X Mavericks (10.9) Documentation
#### Updated 2014-3-22

This document will help to reproduce a fully functional development machine running OSX 10.9 (mavericks).


## Installation

**Avoid case sensative file systems, as this breaks numerous software, such as the entire Adobe suite.**

Do not setup drive encryption (eg. `File Vault`) during installation, instead wait intil you have installed and updated the system before encrypting the contents.  Otherwise you may have to reverse the encryption to account for updates to the system and re-encrypt the whole thing again after updating.

The first step after installing should then be checking for updates.


## Mythical Root User

The root user exists on osx, and its home dir is `/var/root`.  By default the root account on OSX uses the `/bin/sh` shell, which I would recommend switching to bash.

You can also install the same [dot-files](https://github.com/cdelorme/dot-files/) repository as root, provided you have finished installing xCode command line tools, homebrew, and homebrew packages.


##### Commands

_To set the root users shell:_

    sudo su
    chsh -s /bin/bash root

**I do not recommend this as it may affect other parts of your system.  Instead I recommend that if you must act as the root user on OSX that you then run `/bin/bash`.**


## Automatic Updates

This worries me by title alone, but the latest release now offers automatic updates.  _I have not used this long enough to claim to like it over manually updating_, as I am not sure whether this will result in the same forced reboot situation as Windows has.


## System Settings & Configuration

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
        - Advanced:
            - Disable Remote Receiver (_no infrared on newer models_)
    - File Vault
        - Turn On Filevault (**optional**)
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

_Obviously your settings are subject to your own discretion, mine are merely a guide for myself._

I usually add a second desktop by default to work with.  Then, from the battery in the menu bar select "Show Percentage".


## Custom Fonts

- [ForMateKonaVe](http://d.hatena.ne.jp/hetima/20061102/1162435711)
- [EPSON Kyoukashoutai](http://www.wazu.jp/gallery/Fonts_Japanese.html)

The EPSON font has been uploaded with skewed ASCII conversion, so while the font will work, its name is nearly impossible to type.  I recommend running it through a font editor simply to adjust the name to something sensible.

_The links for these fonts are externally hosted and may no-longer be valid.  A copy of these will be included in a later copy of this repository._

Installing fonts can be done by opening them and clicking the install button, or you can install them locally into `~/Library/Fonts/`, or globally `/Library/Fonts`.


## Disable Dashboard

I think the dashboard sucks, but if you use it you are welcome to skip this step.  I have never found it to be useful; Applications load fast enough off SSD's that having an always-open micro-application is not nearly as useful as it may have been several years ago.


##### Commands

_To stop the dashboard from starting by default:_

    defaults write com.apple.dashboard mcx-disabled -boolean YES
    killall Dock


## Finder Settings

Open the finder settings menu with command + j.  _The desktop has a separate menu, so be sure you have selected a finder window before using the hotkey._

I generally check the box to force `List View` as the default.  I also check the calculate size option, because it makes checking folder and file sizes fast and easy.

This release has provided a checkbox to **display the `~/Library` folder**, which saves us an extra step we previously had to do via command line.

**Be sure you select "Use as Defaults" at the bottom or it won't take globally.**  Afterwards you'll want to remove saved view settings (the `.DS_Store` hidden files) recursively and globally to ensure the new settings take and are not overwritten locally per directory.


##### Commands

_Run this to remove saved view settings and reload finder:_

    sudo find / -name ".DS_Store" -depth -exec rm {} \;
    killall Finder

_To fix the hidden `~/Library` via terminal, run this:_

    chflags nohidden ~/Library


## Set Hostname & Domain Name

You will want to set the machines host name, by default it will be your full name, which is often obnoxiously long for a network name.  You can set your hostname in `System Settings` under `Sharing`.  It can also be done via command line, but may not take affect globally until a reboot.

You can set your domain name via command line as well.


##### Command

_Run this command to set your hostname via terminal:_

    sudo scutil --set HostName mypc

_Full affects may not take place until rebooting._

_To set your domain name:_

    domainname example.loc


## Change Terminal Settings

I generally install and use [iTerm2](http://www.iterm2.com/#/section/home), but I also configure the default terminal just in case I need to use it.

I set the default color scheme to `Homebrew`, transparency to 40% with a 5% blur.  Besides that you can set the font family if desired.  I use a custom font (ForMateKonaVe).


## Install Java

OS X does not install Java by default, so if you want to run Java applications you will need to install it.  [Newer 64bit Jdk installers are now available directly](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html).


## Program Installation & Configuration

From the App store I can grab these applications:

- [Dash](https://itunes.apple.com/us/app/dash-docs-snippets/id458034879?mt=12)
- [Unarchiver](https://itunes.apple.com/us/app/the-unarchiver/id425424353?mt=12)
- [XCode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12)

_Dash is a pay-to-use application, but it is an exceptionally useful tool that gives you instant access to documentation for almost any language you can program in._

**Command Line tools no-longer require xCode and cannot be installed from xCode!**  Instead you can do so easily from command line by running `xcode-select --install`.  Unfortunately it takes nearly 2 hours to download and install the latest copy of xCode on a newer model MacBook Pro, so I cannot advocate even installing it if you don't plan on using it.

Next I gather and install the following applications:

- [Google Chrome Dev Channel](http://www.chromium.org/getting-involved/dev-channel)
- [Sublime Text 3](http://www.sublimetext.com/3)
- [RoboMongo](http://robomongo.org/)
- [Sequel Pro (aka Pancakes)](http://www.sequelpro.com/)
- [iTerm2](http://www.iterm2.com/#/section/home)
- [VirtualBox](https://www.virtualbox.org/)
- [Transmission](http://www.transmissionbt.com/download/)
- [VLC](http://www.videolan.org/vlc/download-macosx.html)
- [xQuartz](http://xquartz.macosforge.org/landing/)
- [MacTubes](http://macapps.sakura.ne.jp/mactubes/index_en.html)
- [Inkscape](http://inkscape.org/)
- [Adobe Flash Projector](http://www.adobe.com/support/flashplayer/downloads.html)

Sublime Text is one of the best text editors I have ever used, offering a consistent UI on Windows, Linux, and OS X.  Also the fastest launch times, and excellent plugin support.  It is also one of the first text editors to not suck with anti-aliased text on Windows, ever.  _Sublime text 3 in beta and is also nagware, but it will accept your Sublime Text 2 key until the release comes out._  Unfortunately it encrypts the license key, so I cannot say how to automate this process from command line.

Virtual Box has beaten Parallels and VMWare in terms of best available features and complete linux guest support.  Besides costing you nothing, it offers extremely good performance and is an open source cross-platform tool.

_You will need xQuartz installed to setup Inkscape, as well as other services._  It seems that Homebrew has begun adding a formula for Inkscape, but from my attempts thus far installation has not been successful.  I am hopeful that this will change in the future and eliminate the need for the xQuartz package.

Death to standard FTP, I no longer bother with normal FTP software.  You should only ever bother using SFTP to connect to a server for file sharing, and this can be done from command line or using `sshfs` tools.  The need for specialized FTP software has pretty much disappeared from my lineup entirely.

Adobe flash projector is a means of playing swf files locally on your machine.  It's super tiny and works good, but it's totally dependent on whether you expect to ever deal with swf files.


## Configuring Installed Software

### Dash

Let's start with some basic configuration options.

To validate your purchased copy you may have to visit the `Purchase` tab and pick the appropriate option.

I use the HUD mode with `alt + space` as the hotkey to pull it up.  It starts with my system, and turn off its dock icon.  I show the menubar icon, but tell clicking to open the menu (not the application).

Here is a list of documentation I generally select (there are tons more):

- AngularJS
- Bash
- Bootstrap 3
- C
- C++
- Emmet
- CSS
- GLib
- Go
- Jade
- HTML
- Java EE7
- jQuery
- JavaScript
- Man Pages
- Markdown
- Mongodb
- Nginx
- Node.js
- MySQL
- Python 3
- PHP

The latest release also offers Cheat Sheets, which I also downloaded a few from:

- Git
- HTML Entities
- Regular Expressions
- Sublime Text 3
- Vim

_I do not have every docset enabled, I generally uncheck any downloaded sets that are not in the language of the major project(s) I am working on._

One of the better parts of Dash lately is its optional integration with nearly **every** good OS X utility, things like Alfred, Sublime Text, xCode, and many more have a way of being connected.


### The Unarchiver

Modify settings:

- Always Extract to same folder
- Affiliation with all files (except iso's etc)
- Delete compressed file after extraction
- Second tab set Confidence level to 95% (optional)


### iTerm 2

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


### VirtualBox

VirtualBox offers USB 2.0 support, but you have to download and install the [Extension Pack](https://www.virtualbox.org/wiki/Downloads).

I also recommend creating a Host-Only network with a predictable IP range (I generally use 10.0.5.1).

_Unlike Parallels Desktop and VMware, VBox networking is a bit more complex.  They do not offer a simple "Internal network address with internet and open ports", because they firewall their NAT.  So you have to assign a NAT adapter, and a Host-Only adapter if you want to be able to predictably access the device and not setup a bunch of port forwards._


### Transmission

I rarely torrent from my Mac, but Transmission is among the best Mac/Linux torrent client I have used.  It has a great slim UI, and a vast level of customizability, as well as offering a cli version on linux (such as for headless torrent servers).  **Finally a decent competator for rtorrent.**

In the settings under "General" I tell it not to prompt when removing a torrent.  I also tell it to display the speeds in the "Badge" (viewed when alt + tabbing).

Under the "Transfers" tab I tell it to autoload `.torrent` files from `~/Downloads` and to save finished files there.  I tell it to keep the `.torrent` files inside `~/Downloads/.torrent/` and to keep partial downloads in `~/Downloads/.torrent/downloading/` and to append `.part` to the file names.  I tell it **not** to display confirmation when loading a torrent.

I setup a schedule under the "Bandwidth" tab to accomodate my access times.

Finally under the "Peers" tab I tell it to prefer encrypted peers **and** ignore unencrypted peers.  _This is a weak stop-gap against torrent scanners._


## [Homebrew](http://brew.sh/)

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


##### Commands

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


## Dot Files

**Next I recommend using my [dot-files repository](https://github.com/cdelorme/dot-files/) to enhance your prompt, vim configuration, and set a bunch of useful configuration defaults.**

Creating a set of useful dot-files is essential to enhancing your command line situation, but not everyone will find all of my settings to be useful.


## Configuring golang

I recommend installing [goconvey](https://github.com/smartystreets/goconvey) and [gin](https://github.com/codegangsta/gin).

The first is a test enhancer that will make it easier to read debug output.

The second allows you to run a project while watching for file changes and automatically rebuilding and running it.  This is very useful for web development, but not as much for run-time application development or command development.


##### Commands

_Run these lines to install the recommended go packages:_

    go get -t github.com/smartystreets/goconvey
    go get github.com/codegangsta/gin


### Installing `pip` & python packages

The python package manager should be installed if you intend to use python (and you probably will without realizing it).

If you develop in python you will want `pip` to add the `pep8` package for syntax support.  For interactive python debugging you should also install [bpython](https://pypi.python.org/pypi/bpython).

Additionally we want to install the virtual environment wrapper, such that we can have more finely tuned controls per application or environment as for what python version is to be used and packages are installed.


##### Commands

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


### nodejs Globals

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


##### Commands

_To install nodejs globals:_

    npm install -g csslint jshint csso uglify-js mocha jscoverage yo grunt grunt-contrib-watch markdown forever bower

_You may optionally add `mongo` and `mysql` as needed, but it may be wiser to use a local copy of those per project.  Same goes for bower and grunt packages, if you expect many projects to be using them at the same time._


### Creating a crontab

Ideally you should setup a script to automatically update your homebrew and npm packages.  One good option for this is your "crontab".


##### Commands

_You can put the script in `/usr/local/bin/autobrewnpm` and you can add these lines:_

    #!/bin/bash

    brew update
    brew upgrade
    npm update

_Make sure the script file you create is executable._

_You can run `crontab -e` to open your crontab (likely new/empty), and add this line:_

    0 2 * * * /usr/local/bin/autoupdate &> /dev/null

_This script should now execute everyday at 2AM._


### Path Modifications

Many of the packages you install with homebrew will already exist on the machine.  When you run a command it checks the paths in the order they appear in the PATH variable and stops as soon as it finds the command.  To use the new versions of same-named commands you have to change the `PATH` global variable to include the local bin first.  Be sure to add this to your `~/.bashrc`:

    export PATH=/usr/local/bin:/usr/local/sbin:$HOME/bin:$PATH

_This is one of the many modifications that is handled by my dot-files automatically._


### SSH Key Generation

It is recommended that you generate an ssh key, which can be used for ssh tunneling, numerous encryption services, and version control software.

**OS X should automatically remember and reload any keys you have added at reboot.**


##### Commands

_Create SSH key and add to ssh-agent:_

    ssh-keygen -t rsa -b 4096 -C "<youremail>"
    ssh-add -K ~/.ssh/id_rsa

_You will have to follow prompts when creating the key, and your email is an optional flag._



### Git Configuration

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


##### Commands

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


### Activate bash-completion

Even after installing it with homebrew, you may have to add a symlink for it to be loaded.  Additionally you may need to load it from command line by running that symlink.


##### Commands

_Run this to create the symlink:_

    ln -s "/usr/local/Library/Contributions/brew_bash_completion.sh" "/usr/local/etc/bash_completion"

_Add this to your `~/.bashrc` or `~/.profile`:_

    if [ -f $(brew --prefix)/etc/bash_completion ]; then
      . $(brew --prefix)/etc/bash_completion
    fi

_This is another configuration that I include in my dot-files repository._


### Sublime Text 3

Sublime Text 3 is still in beta, and while it will accept your Sublime Text 2 registration key to silence its nag-messages, it specifically states that Sublime Text 3 will be a paid upgrade (eg. when it launched you will get nagged again or have to make a new purchase/upgrade).

You can create a symlink to the package to create a `subl` command to launch sublime from the terminal.  This can be helpful when you need sudo privileges and want a GUI editor.

Next you will want to install [Package Control](https://sublime.wbond.net/installation#st3), in order to take advantage of all of the awesome packages in sublime text!

The following packages and package configuration are mostly compatible with both versions 2 and 3 of Sublime Text.

Install these plugins:

- [Markdown Preview](https://github.com/revolunet/sublimetext-markdown-preview)
- [SublimeCodeIntel](https://github.com/SublimeCodeIntel/SublimeCodeIntel)
- [Origami](https://github.com/SublimeText/Origami)
- [Emmet](https://github.com/sergeche/emmet-sublime)
- [Encoding Helper](https://github.com/SublimeText/EncodingHelper)
- [SublimeLinter](https://github.com/SublimeLinter/SublimeLinter)
- [SublimeLinter-json](https://github.com/SublimeLinter/SublimeLinter-json)
- [SublimeLinter-pep8](https://github.com/SublimeLinter/SublimeLinter-pep8)
- [SublimeLinter-phplint](https://github.com/SublimeLinter/SublimeLinter-phplint)
- [SublimeLinter-html-tidy](https://github.com/SublimeLinter/SublimeLinter-html-tidy)
- [SublimeLinter-jshint](https://github.com/SublimeLinter/SublimeLinter-jshint)
- [Xdebug Client](https://github.com/martomo/SublimeTextXdebug)

These packages depend on a mixture of homebrew, pip, and nodejs components, all of which are in the instructions you've already read.  Be sure to read each documentation if it is not working for you.

I find that `Emmet` confuses me with its code completion for css, so I disable css completion in my emmet user config, but whether you do the same is up to your preferences.

To get the linters to work you may have to set some custom paths.

The xdebug client is for php, and gives you access to IDE grade debugging capabilities.  It does have a few other dependencies I will cover later.

It may also be worth checking out the [SublimeText Crypto Package](https://github.com/mediaupstream/SublimeText-Crypto) if you like the idea of encrypting your notes for on-the-fly text document security, it's pretty sweet.


##### Commands

_Make the sublime terminal command:_

    sudo ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/bin/subl

_We can install package control with this line into the Sublime Text Console:_

    import urllib.request,os,hashlib; h = '7183a2d3e96f11eeadd761d777e62404e330c659d4bb41d3bdf022e94cab3cd0'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://sublime.wbond.net/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)

_Add these to your settings file:_

    {
        "auto_complete_commit_on_tab": true,
        "caret_style": "phase",
        "color_scheme": "Packages/Color Scheme - Default/Sunburst.tmTheme",
        "font_face": "ForMateKonaVe",
        "font_size": 16.0,
        "highlight_line": true,
        "highlight_modified_tabs": true,
        "match_brackets_angle": true,
        "scroll_past_end": true,
        "scroll_speed": 2.0,
        "translate_tabs_to_spaces": true,
        "trim_trailing_white_space_on_save": true
    }

_To disable `Emmet` code completion when editing css files add this to your `Emmet` config:_

    {
        "disable_tab_abbreviations_for_scopes": "source.css",
    }

_Here is my custom linters config to have it recognize the correct paths to my tools:_

    "paths": {
        "linux": [],
        "osx": [
            "/usr/local/bin"
        ],
        "windows": []
    },

_I also recommend these keyboard bindings (Preferences > Keyboard Bindings (User)):_

    [
        { "keys": ["ctrl+enter"], "command": "goto_python_definition"},
        { "keys": ["ctrl+tab"], "command": "next_view" },
        { "keys": ["ctrl+shift+tab"], "command": "prev_view" },
        { "keys": ["alt+m"], "command": "markdown_preview", "args":
            { "target": "browser", "parser": "markdown" }
        },
        { "keys": ["super+shift+r"], "command": "reindent" , "args": { "single_line": false } },
        { "keys": ["super+b"], "command": "markdown_preview",
            "args": { "target": "browser", "parser": "markdown" },
            "context": [{ "key": "selector", "operator": "equal", "operand": "text.html.markdown" }]
        }
    ]

_Note that these same options can be added to a linux or windows configuration, but you will want to swap `super` for `ctrl`.  The `super+b` hotkey is for markdown files and overrides the default build process which only builds the html file._

_For XDebug Client configuration you can use this as a base config and modify it or add paths as needed:_

    {
        "path_mapping": {
            "/path/to/remote": "/path/on/local",
        },
        "ide_key": "vagrant",
        "url": "bidstart.dev",
        "launch_browser": true,
        "break_on_exception": [
            "Fatal error",
            "Catchable fatal error",
            "Warning",
            "Parse error",
            "Xdebug",
            "Unknown error"
        ],
        "close_on_stop": true,
        "debug": false
    }


### PHP XDebug Configuration

If you want to add xDebug support (so you can get IDE level debugging for PHP), start by adding these lines to the servers `/etc/php5/mods-available/xdebug.ini`:

    zend_extension=/usr/lib/php5/20100525/xdebug.so
    xdebug.remote_enable = 1
    xdebug.remote_connect_back = 1
    xdebug.remote_host=10.0.5.5
    xdebug.idekey = "vagrant"
    xdebug.remote_log="/var/log/xdebug.log"
    xdebug.profiler_output_dir="/tmp"

_If the `zend_extension` value is different do not change it._

You can then simplify starting xdebug by installing [this google chrome extension](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc?hl=en).  If, for example, you have Sublime Text running with xdebug configured, and access a page on the remote (or local if configured) server it will open up and display environment information, and you can add break points as needed.


## Markdown Quicklook

I install this so I can easily preview markdown files, the [repository is here](https://github.com/toland/qlmarkdown), but you can [download a prebuilt file here](http://jamesmoss.co.uk/blog/support-for-markdown-in-osx-quicklook/) and toss them into `/Library/QuickLook`.

With this package you can use the space-bar like with images and pdf files, and it will display HTML rendered preview of a markdown file.


## Reorganize Dock

I remove any other software from my dock except the following list:

- Finder
- iTerm2
- Transmission
- Sublime Text 3
- Chrome
- Safari
- iTunes
- iBooks
- App Store
- System Preferences
- _Divider_
- Downloads
- Trash

I do use more software than is in this list, but I almost never use the dock to access it, I use spotlight because it is faster.  **This list is really here for drag-and-drop applications.**


## Sync Accounts

I no longer bother synchronizing my accounts, but if you choose to do so you can hook your gmail up to your `Mail`, `Contacts` and `Calendar` software on the system.

I do syncrhonize my google chrome, but because I use google chrome I do not need any of the other software configured.


## File Vault

I no longer bother encrypting my drive.  It has a small performance hit, and **may still be a good idea for mission critical business laptops**, but the hard drive is now soldered into the machine.  The new machines have soldered their drives in, so it's significantly less likely they will be able to hook it up to another machine running OS X.  It also has no CD drive.  This leaves only USB bootable media to access the drive contents, and to my recollection linux can't read journaled HFS+ drives.

As mentioned in my previous documentation, if you intend to encrypt your drive, wait until you have finished installing all system updates because patches to the encryption code will require you to decrypt, update, then re-encrypt; a process which can take many hours.


## Conclusion

Thus concludes my comprehensive OS X 10.9 setup and configuration process.  If you have configured your machine in the same way it will be ready for most development projects.

Note that despite how many tools I install on the system, I prefer, and often use, virtualization to offload a majority of testing to keep the main system running light and smooth.  Many services like a database or web server would consume resources if run while not in use, and add to the number of things my main system is then responsible for.

For that reason I recommend visiting my [debian documentation](../linux/debian) and setting up a virtual machine for web development or any code that can be offloaded and is not needed on your host.


## References

- [OS X Fonts](http://support.apple.com/kb/ht2435)
- [iTerm2 Config](https://code.google.com/p/iterm2/issues/detail?id=1052)
- [Remap Capslock](http://stackoverflow.com/questions/127591/using-caps-lock-as-esc-in-mac-os-x)
- [iTerm2 alt hotkeys](https://code.google.com/p/iterm2/issues/detail?id=1052)
- [iTerm2 unlimited history](http://stackoverflow.com/questions/12459755/zsh-iterm2-increase-number-of-lines-history)


## Future Goals

- I want to figure out how to modify plist files from command line so I can automate the configuration of various software, which can be done with lines similar to `defaults read com.apple.LaunchServices.plist`, but I have not yet experimented with it enough.
