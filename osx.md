
# osx documentation

My documentation to creating a great osx development environment, including all the tools and configuration I recommend.


## during installation

**Do not:**

- use a Case Sensative HFS+
- encrypt your drive with File Vault

Using a case sensative HFS+ partition will break a large amount of software (for example, adobe).

If you encrypt your drive prior to downloading the latest updates, you may need to unencrypt, update, then re-encrypt the drive.  This is quite time consuming, so to avoid that don't encrypt during installation.  Additionally, if you use a modern osx laptop, the hard drive is soldered onto the motherboard, making it much less desirable as a target for physical hijacking.

**Which leads us to the first post-install step:**

- check for updates.


## firewall

I highly recommend turning the firewall on by default, and setting stealth mode.

![firewall system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/firewall-system-preferences.png)
![advanced firewall system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/advanced-firewall-system-preferences.png)

In certain cases, when software self-updates it may ask for permissions again from the firewall.  This is a fairly new feature, and may be improved as time passes.


## system preferences

Here are some suggested changes to `System Preferences`:

- General
    - Graphite Color-scheme
    - Recent Items: None

![general system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/general-system-preferences.png)

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

![dock system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/dock-system-preferences.png)

- Mission Control
    - Do Not "Show Dashboard from F12" (checkbox)
    - Do Not "Automatically rearrange Spaces based on most recent use" (checkbox)
    - _I prefer not to switch to a Space with open windows, but most users will probably find that helpful_
    - Check the remaining boxes
    - Hot Corners
        - Show Desktop (top right)

_I generally activate mission control and manually add one desktop for a total of 2 available by default._

![mission control system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/mission-control-system-preferences.png)
![mission control hot corners system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/hot-corners-mission-control-system-preferences.png)

- Language & Region
    - 24-Hour Time (checkbox)

![language & region system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/region-and-language-system-preferences.png)

- Security & Privacy
    - General
        - Require Password 1 Minute after Display Sleep
    - Firewall
        - Turn Firewall On
        - Firewall Options:
            - Stealth Mode

![general security & privacy system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/general-security-and-privacy-system-preferences.png)
![firewall system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/firewall-system-preferences.png)
![advanced firewall system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/advanced-firewall-system-preferences.png)

- Spotlight
    - Uncheck all but `Applications` and `System Preferences`
    - Privacy tab: Add user home folder (you will have a dialog to confirm)

![spotlight system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/spotlight-system-preferences.png)
![spotlight privacy system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/spotlight-privacy-system-preferences.png)

- Display
    - Disable "Automatically adjust brightness"

![display system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/display-system-preferences.png)

- Energy Saver
    - Battery Display Sleep after 5 Minutes (slider)
    - Computer sleep after 10 minutes (slider)

_I usually select the battery from the top menu to change it to display its percent._

![energy saver system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/energy-saver-system-preferences.png)

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
            - De-select personal folders
        - Accessibility
            - Disable "Turn VoiceOver on or off" (checkbox)
            - Disable "Show Accessibility controls" (checkbox)
        - App Shortcuts
            - All Applications: `Zoom` via `cmd+alt+m`
            - Google Chrome: `Zoom` via `shift+cmd+m`
        - Select "All controls" at bottom (radio)
    - Input Sources
        - Add Japanese
        - Show in menu bar (checkbox)

_The zoom hotkey comes from the [iterm2](http://iterm2.com/) shortcut, and is a very helpful addition for those who like applications to fill-the-screen.  However, google chrome's default assumption for `Zoom` is to adjust the height and not fill the screen.  However, they interpret shift as a desire to fill vs full-height, thus if the hotkey contains the shift key it will do a proper fill, and needs its own special-case._

![keyboard system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/keyboard-system-preferences.png)
![keyboard modifiers system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/keymoard-modifiers-system-preferences.png)
![keyboard shortcuts system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/keyboard-shortcuts-system-preferences.png)
![keyboard mission control shortcuts system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/keyboard-shortcuts-mission-control-system-preferences.png)
![keyboard input source shortcuts system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/keyboard-shortcuts-input-system-preferences.png)
![keyboard launchpad & dock shortcuts system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/keyboard-shortcuts-launchpad-system-preferences.png)
![keyboard application shortcuts system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/keyboard-shortcuts-custom-system-preferences.png)
![input sources system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/keyboard-input-sources-system-preferences.png)

- Trackpad
    - Point & Click
        - Enable "Tap to Click" (checkbox)
        - Disable "Look Up" 3 finger tap
        - Increase "Tracking Speed" (slider)
    - More Gestures
        - Enable App Expose (three finger down)
        - Disable Launchpad
        - Disable "Swipe between pages"

![point & click trackpad system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/trackpad-point-and-click-system-preferences.png)
![Scroll & Zoom trackpad system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/trackpad-scroll-and-zoom-system-preferences.png)
![More Gestures trackpad system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/trackpad-more-gestures-system-preferences.png)

- Sound
    - Tink (Alert Sound)
    - Reduced Alert Volume
    - Disable "Play feedback when volume is changed" (checkbox)

![sound system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/sound-effects-system-preferences.png)

- Bluetooth
    - "Turn Bluetooth Off" (conserves battery)

![bluetooth system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/bluetooth-system-preferences.png)

- Sharing
    - Set your hostname to something less obnoxiously long (usually "full first & lastname's macbook")

![sharing system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/sharing-system-preferences.png)

- Time Machine
    - Do not show menu bar icon

![time machine system preferences](https://d2xxklvztqk0jd.cloudfront.net/images/git/time-machine-system-preferences.png)


## spotlight cache

If you end up with a problem with spotlight you can clear it's cache from command line:

    sudo mdutil -E /

_Be aware, this can take quite a while to rebuild._


## [custom fonts](shared/custom-fonts.md)

Review the referenced document, and you can optionally download and install them onto OSX.

Installing fonts can be done by opening them and clicking the install button, or you can install them locally into `~/Library/Fonts/`, or globally `/Library/Fonts`.


## disable dashboard

I think the dashboard is a waste of space and resources and elect to disable it.  Applications load fast enough on SSD's that micro-applications are not nearly as useful as they may have been years back.

To stop the dashboard from starting by default:

    defaults write com.apple.dashboard mcx-disabled -boolean YES
    killall Dock

_This may not even be necessary with the latest release, yosemite._


## finder settings

Finder has two sections for configuration.  Starting with preferences (accessed via "command + ,") I generally use the following:

- General
    - All Checkboxes for "Show on Desktop"
    - New Finder windows show my user home folder
    - uncheck Springload animation
- Tags
    - I uncheck all tags, I don't use them
- Sidebar
    - Favorites
        - uncheck "All my Files", "AirDrop", "Movies", "Music", and "Pictures"
        - Check "Applications", "Desktop", "Documents", "Downloads", and user home folder
    - Shared
        - uncheck all
    - Devices
        - check all
    - tags
        - unchecked
- Advanced
    - Check all boxes
    - Search using current folder

![general finder settings](https://d2xxklvztqk0jd.cloudfront.net/images/git/finder-general-settings.png)
![tags finder settings](https://d2xxklvztqk0jd.cloudfront.net/images/git/finder-tags-settings.png)
![sidebar finder settings](https://d2xxklvztqk0jd.cloudfront.net/images/git/finder-sidebar-settings.png)
![advanced finder settings](https://d2xxklvztqk0jd.cloudfront.net/images/git/finder-advanced-settings.png)

You can open the finder settings menu with "command + j".  _The desktop has a separate menu, so be sure you have opened a finder window and that it is in focus before using the hotkey._

![folder finder settings](https://d2xxklvztqk0jd.cloudfront.net/images/git/finder-folder-settings.png)
![desktop finder settings](https://d2xxklvztqk0jd.cloudfront.net/images/git/finder-desktop-settings.png)

I generally check the box to force `List View` as the default.  I make sure to check all four of these options:

- Use relative dates
- Calculate all sizes
- Show icon preview
- Show Library Folder

While it was wonderful that this is now a setting, you can always use the `chflags nohidden ~/Library` command from terminal as well.

**Be sure you select "Use as Defaults" at the bottom or it won't take globally.**  Afterwards you'll want to remove saved view settings (the `.DS_Store` hidden files) recursively and globally to ensure the new settings take and are not overwritten locally per directory.

After making all of these changes to settings you can wipe out the previously cached view settings with two commands:

    sudo find / -name ".DS_Store" -depth -exec rm {} \;
    killall Finder


## set hostname & domain name

You will want to set the machines host name, by default it will be your full name, which is often obnoxiously long for a network name.  You can set your hostname in `System Settings` under `Sharing`.  It can also be done via command line, but may not take affect globally until a reboot.

You can set your hostname and domain name via command line as well:

    sudo scutil --set HostName mypc
    domainname example.loc

_Effects may not be complete until rebooting, so the gui is preferred._


## configure terminal

I generally install and use [iTerm2](http://www.iterm2.com/#/section/home), but I also configure the default terminal just in case I need to use it.

I set the default color scheme to `Homebrew` with my choice of custom font (ForMateKonaVe) size 14.  I also go to the window tab and click the color & background button to set opacity to 40% with a 5% blur.


## app store

Here are some items I always grab from the App Store:

- [Dash](https://itunes.apple.com/us/app/dash-docs-snippets/id458034879?mt=12)
- [Unarchiver](https://itunes.apple.com/us/app/the-unarchiver/id425424353?mt=12)
- [XCode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12)

_Dash is a mac only software that costs money, but it is a worth-while purchase.  It gives you a complete comprehensive local copy of documentation for multiple languages.  This is awesome for travel purposes, or even just quick-checks on object types or method arguments.  I highly recommend it._

I would consider XCode optional.  If you do not plan to be developing for Mac using their specific libraries and Objective-C, then you probably don't need it.  _Also it cane take upwards of two hours to download on moderately fast internet connections._


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
- [Adobe Flash Projector](http://www.adobe.com/support/flashplayer/downloads.html)
- [Java JDK](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)

VirtualBox is a free Virtual Machine software with better linux guest support than leading commercial software such as Parallels and VMWare.  It is also cross platform, allowing you to create a virtual machine and transfer it anywhere with no major changes to interface or drivers.  _If you need 3D capabilities you will want to look at [Parallels Desktop]()._

In spite of the fact that flash is a dying industry, I often find myself in need of the ability to run an swf file, and the Flash Projector comes in a debug flavor, which makes it super easy to have a tiny executable that can run and test flash files without browser concerns.


## configuring installed software

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

You will also want to register a quick-display hotkey.  I generally go with `alt+space`.


### the unarchiver

Preferred Settings:

- Select all archive formats for affiliation
- Select to always extract to the same folder as the archive is
- Create a new folder if there is more than one top-level item
- Move the archive to the trash after extraction
- Under advanced set automatic detection confidence level to 100%


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

_Color schemes in iterm are loaded into a plist file and so doing so from command line is not as easy.  I may document the process in the future if I ever have time._


### virtualbox

VirtualBox offers USB 2.0 support, but you have to download and install the [Extension Pack](https://www.virtualbox.org/wiki/Downloads).

I also recommend creating a Host-Only network with a predictable IP range, which you can then specify static ip's in your virtual machines.

_Unfortunately VirtualBox caters towards the enterprise crowd and focuses on security at the cost of convenience and usability.  There is no "Shared Adapter" that allows virtual machines to have both internet access and local access, due to a built-in firewall on their NAT.  To gain local access you need a second host-only network device._


### transmission

Transmission is among my favorite software list now.  They provide a client and command line controls, for unix & linux platforms.  So far they have the best customizability, greatest cross platform support (minus windows) and most sensible configuration I've seen for what could operate as a torrent server software.

In the settings under "General" I tell it not to prompt when removing a torrent.  I also tell it to display the speeds in the "Badge" (viewed when alt + tabbing).

Under the "Transfers" tab I tell it to autoload `.torrent` files from `~/Downloads` and to save finished files there.  I tell it to keep the `.torrent` files inside `~/Downloads/.torrent/` and to keep partial downloads in `~/Downloads/.torrent/downloading/` and to append `.part` to the file names.  I tell it **not** to display confirmation when loading a torrent.

I setup a schedule under the "Bandwidth" tab to accomodate my access times.

Finally under the "Peers" tab I tell it to prefer encrypted peers **and** ignore unencrypted peers.  _This is a weak stop-gap against torrent scanners._


## [homebrew](http://brew.sh/)

OSX lacks a package manager to install additional software without going to the web like you would on Windows.  Fortuntely, because it runs UNIX it is capable of supporting a package manager, and a few have come into being.

I favor homebrew for its user-local approach, which generally does not require sudo operations.  The [macports](http://www.macports.org/) alternative has more packages but tends to **"sudo-all-the-things"**.

_A newer package manager has recently come into being called [nix](https://nixos.org/nix/), which works on linux as well as osx.  It does not have great traction on OSX yet, but may be worth checking out in the future._

**Homebrew depends on Command Line Tools, but this should automatically prompt to install on newer versions of OSX.**

For a well-rounded terminal experience with plenty of options, these are the packages I install:

- wget
- tmux
- openssl
- git
- git-flow
- mercurial
- svn
- bzr
- go
- youtube-dl
- awscli
- swftools
- graphicsmagick
- vim
- weechat
- sshfs
- ffmpeg
- sfml
- sdl2
- sdl2_image
- sdl2_mixer
- sdl2_ttf
- sdl
- sdl_image
- sdl_mixer
- sdl_ttf
- mplayer
- node

Some of these packages have special flags for installation.  They should automatically install dependencies, but depending on the package there may be more to it than that.

To check package information prior to installing, you can use `brew info`.

_The first time you attempt to use `sshfs` you will get a warning popup notifying you of an untrusted kext.  The software will still work, but you need to permit it once._


##### commands

_Let's start by adding this line (with your own token) to your dot-files such as `~/.profile` or `~/.bashrc` or `~/.bash_profile` to bypass github API traffic limits:_

    export HOMEBREW_GITHUB_API_TOKEN=YOURTOKEN

_If you are using my [dot-files repository](https://github.com/cdelorme/dot-files/), the install script accepts your github username and password, and will auto-detect that you are using OS X and get you a fresh token on install._

_This will install homebrew and my list of packages:_

    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    brew doctor
    brew tap homebrew/versions
    brew update
    brew install wget
    brew install tmux
    brew install openssl
    brew install --with-gettext --with-pcre --with-blk-sha1 git
    brew install git-flow
    brew install mercurial
    brew install bzr
    brew install --with-python svn
    brew install --with-cc-all go
    brew install --with-rtmpdump youtube-dl
    brew install awscli
    brew install --with-fftw --with-jpeg --with-giflib --with-lame swftools
    brew install --with-lua --with-python3 --override-system-vi vim
    brew install --with-lua --with-python --with-guile --with-perl weechat
    brew install Caskroom/cask/osxfuse
    brew install sshfs
    brew install --with-faac --with-fdk-aac --with-ffplay --with-fontconfig --with-freetype --with-libass --with-libbluray --with-libcaca --with-libvorbis --with-libssh --with-libvidstab --with-libvpx --with-openjpeg --with-openssl --with-rtmpdump --with-speex --with-theora --with-tools --with-webp --with-x265 ffmpeg
    brew install sfml
    brew install --static glfw3
    brew install sdl2
    brew install sdl2_image
    brew install sdl2_mixer
    brew install sdl2_ttf
    brew install sdl
    brew install sdl_image
    brew install sdl_mixer
    brew install sdl_ttf
    brew install --with-libtiff --with-libwmf --with-little-cms2 --with-webp graphicsmagick
    brew install mplayer
    brew install node
    sudo /bin/cp -RfX /usr/local/opt/osxfuse/Library/Filesystems/osxfusefs.fs /Library/Filesystems/
    sudo chmod +s /Library/Filesystems/osxfusefs.fs/Support/load_osxfusefs
    aws configure
    pip3 install --upgrade pip
    sudo youtube-dl -U

_I recommend creating a file at `/usr/local/bin/brewgrade` with these lines:_

    #!/bin/bash
    brew clean
    brew update
    brew upgrade
    brew doctor

_Then adding a command to a crontab to automate running it:_

    chmod +x /usr/local/bin/brewgrade
    echo "@daily /usr/local/bin/brewgrade" >> ~/.crontab
    crontab ~/.crontab

_OSX effectively stopped supporting crontab and is pushing towards its own ctl-style configs with 20+ lines of XML instead of a single line to run a scheduled operation.  As a result it won't let you easily modify the crontab; thus far my experience shows that if you want to change the file you will have to edit it manually with `vim` (or any editor), then reload the file via `crontab ~/.crontab`.  If you attempt to use `crontab -e` it will not save changes or throw errors to indicate why._


## dot-files

**Next I recommend using my [dot-files repository](https://github.com/cdelorme/dot-files/) to enhance your prompt, vim configuration, and set a bunch of useful configuration defaults.**

Creating a set of useful dot-files is essential to enhancing your command line situation, but not everyone will find all of my settings to be useful.


### ssh key generation

It is recommended that you generate an ssh key, which can be used for ssh tunneling, numerous encryption services, and version control software.

You can easily generate one with the following command:

    ssh-keygen -t rsa -b 4096
    ssh-add -K ~/.ssh/id_rsa

**OS X should automatically remember and reload any keys you have added at reboot.**


### git configuration

You will want to set your name, email, and keychain helper using git's global configuration commands:

    git config --global credential.helper osxkeychain
    git config --global user.name <name>
    git config --global user.email <email>

I generally create a `~/git/` folder to store my projects.

I highly recommend [Ralph Bean's Awesome Git Flow Tutorial](http://threebean.org/presentations/gitflow/#/step-1) and the [Git Bash Completion](https://github.com/git/git/blob/master/contrib/completion/git-completion.bash) script as well.  You may also want to download and install `~/.githelpers`, written by [Gary Bernhardt](https://github.com/garybernhardt/dotfiles/blob/master/.githelpers).


### [sublime text](software/sublime_text.md)

Visit the shared document for steps and configuration file templates.


## markdown quicklook

I install this so I can easily preview markdown files, the [repository is here](https://github.com/toland/qlmarkdown), but you can [download a prebuilt file here](http://jamesmoss.co.uk/blog/support-for-markdown-in-osx-quicklook/) and toss them into `/Library/QuickLook`.

With this package you can use the space-bar like with images and pdf files, and it will display HTML rendered preview of a markdown file.


## conclusion

Thus concludes my comprehensive OS X 10.9 setup and configuration process.

Despite my preferences and installed packages here, a majority of the work I do is done through virtual machines.  If you found this in any way useful, I highly recommend you visit my debian/linux documentation.


## references

- [OS X Fonts](http://support.apple.com/kb/ht2435)
- [iTerm2 Config](https://code.google.com/p/iterm2/issues/detail?id=1052)
- [Remap Capslock](http://stackoverflow.com/questions/127591/using-caps-lock-as-esc-in-mac-os-x)
- [iTerm2 alt hotkeys](https://code.google.com/p/iterm2/issues/detail?id=1052)
- [iTerm2 unlimited history](http://stackoverflow.com/questions/12459755/zsh-iterm2-increase-number-of-lines-history)
