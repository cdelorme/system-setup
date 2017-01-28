
# osx documentation

My documentation to creating a great osx development environment, including all the tools and configuration I recommend.


## during installation

**Do not:**

- use a Case Sensative HFS+
- encrypt your drive with File Vault

Using a case sensative HFS+ partition will break a large amount of software (for example, adobe).

If you encrypt your drive prior to downloading the latest updates, you may need to unencrypt, update, then re-encrypt the drive.  This is quite time consuming, so to avoid that don't encrypt during installation.  Additionally, if you use a modern osx laptop, the hard drive is soldered onto the motherboard, making it much less desirable as a target for physical hijacking.

**Which leads us to the first post-install step:**

- open the app store and check for updates.


## system preferences

Here are some suggested changes to `System Preferences`:

- General
    - Appearance: `Graphite`
    - check `Use dark menu bar and Dock`
    - check `Automatically hide and show the menu bar`
    - Default web browser: `Google Chrome` (_requires installation_)
    - Recent Items: `None`
    - uncheck `Allow Handoff between this Mac and your iCloud devices`

_The `Handoff` functionality is really cool but still feels very disruptive so I choose to disable it on workstations._

- Desktop & Screen Saver
    - check `Change picture`: `Every 5 minutes`

_I generally rotate from `~/Pictures/wallpaper/`._

- Dock
    - Size: _smaller_
    - Magnification: _closer to min_
    - Position on screen: `Right`
    - Minimize windows using: `Scale effect`
    - check `Minimize windows into application icon`
    - check `Automatically hide and show the Dock`

- Mission Control
    - uncheck `Automatically rearrange Spaces based on most recent use`
    - uncheck `When switching to an application, switch to a Space with open windows for the application`
    - uncheck `Displays have separate Spaces`
    - Show Dashboard: `-` (_disable_)
    - Hot Corners...
        - Top Right: `Show Desktop`
        - Top Left: `Start Screen Saver`

_I use the hot corner with security settings to easily lock my system when I step away._  I also usually pre-emptively create at least two `Spaces`.

- Language & Region
    - Time Format: check `24-Hour Time`

_I spent a lot of time dealing with time conversion and UTC, for me military time is significantly easier to deal with._

- Security & Privacy
    - General
        - check `Require Password **1 Minute** after sleep or screen saver begins`
    - Firewall
        - Turn Firewall On
        - Firewall Options:
            - Stealth Mode
    - Advanced...
        - check `Log out after 60 minutes of inactivity`
        - check `Require an administrator password to access system-wide preferences`

_I generally wait until the system has been fully configured before turning on FileVault, which has become less beneficial with the latest drives being soldered to the motherboard._

- Spotlight
    - Search Results
        - uncheck `Bing Web Searches`
        - uncheck `Bookmarks and History`
        - uncheck `Calculator`
        - uncheck `Contacts`
        - uncheck `Conversion`
        - uncheck `Definition`
        - uncheck `Documents`
        - uncheck `Events and Reminders`
        - uncheck `Folders`
        - uncheck `Fonts`
        - uncheck `Images`
        - uncheck `Mail and Messages`
        - uncheck `Movies`
        - uncheck `Music`
        - uncheck `Other`
        - uncheck `PDF Documents`
        - uncheck `Presentations`
        - uncheck `Spotlight Suggestions`
        - uncheck `Spreadsheets`
        - uncheck `Allow Spotlight Suggetions in Spotlight and Look up`
    - Privacy
        - Add `~/`

_Some might find the above list convenient, I generally know where my stuff is and have a dozen other solutions that don't expose my file system to a search system that goes to the internet._

- Notifications
    - Safari
        - _disable all_
    - Game Center
        - _disable all_
    - Mail
        - _disable all_
    - Photos
        - _disable all_

_The updated notifications system is very well integrated with other mobile devices or even other laptops, but some notifications are totally unnecessary._

- Displays
    - uncheck `Automatically adjust brightness`

_The multimedia hotkeys to control brightness are often far more useful._

- Energy Saver
    - Battery
        - Turn display off after `15 min`
    - Power Adapter
        - Turn display off after `3 hrs`
        - check `Prevent computer from sleeping automatically when the display is off`
        - uncheck `Enable Power Nap while plugged into a power adapter`

_When I am plugged in but idle this is generally because I am watching a video or waiting for someone to contact me, so the display going to sleep is a nuisance._  This is also why the hot corner is useful when I step away and _want_ to sleep the display.

- Keyboard
    - Keyboard
        - Turn off when computer is not used for: `10 secs`
        - Modifier Keys...
            - Caps Lock > Control
    - Input Sources
        - Add Japanese
    - Shortcuts
        - Input Sources
            - check `Select the previous input source`
        - Launchpad & Dock
            - uncheck `Turn Dock Hiding On/Off`
        - Keyboard
            - uncheck `Change the way Tab moves focus`
            - uncheck `Turn keyboard access on or off`
        - Spotlight
            - uncheck `Show Finder search window`
        - Accessibility
            - uncheck `Turn VoiceOver on or off`
            - uncheck `Show Accessibility controls`
        - App Shortcuts
            - All Applications
                - `Zoom`: `cmd+alt+m`
            - Google Chrome
                - `Zoom`: `shift+cmd+m`
        - All Controls (_select_)

_Since I am still trying to learn the language, I add Japanese input and Input Sources to easily switch input modes when desired._  Apply makes the input switching absolutely beautiful with the latest release.

_A lot of hotkeys I disable to save me days spent confused as to why behavior changed after I accidentally fumbled the keyboard._

_The zoom hotkey for Chrome differs to force fill-screen, while for other applications it matches the [iterm2](http://iterm2.com/) shortcut._

- Trackpad
    - Point & Click
        - check `Tap to click`
        - Tracking Speed: _increase_
    - More Gestures
        - uncheck `Switch between pages`
        - check `App Expose`
        - uncheck `Launchpad`

_I find that browser controls to switch between pages are extra sensitive and often don't work as desired, especially if that page happened to be wider than my display._

- Sound
    - Sound Effects
        - Select an alert sound: `Tink`
        - Alert Volume: _reduced_
        - uncheck `Play user interface sound effects`

- iCloud
    - check `Keychain`

_I find keychain backups to be super useful, because copying my keychain files from `~/Library` and `/Library`, then importing them is often painful._

- Internet Accounts
    - Google

_For calendar synchronization, I generally like to connect my gmail account._

- Extensions
    - Share Menu: _disable everything_

_Nothing about this new feature appeals to me._

- Bluetooth
    - click `Turn Bluetooth Off`
    - check `Show Bluetooth in menu bar`

_I prefer to conserve battery, but if you have bluetooth devices re-entering isn't too difficult._

- Sharing
    - Computer Name: _anything short and simple_

_The default is generally a page and a half longer than it should be._

- App Store
    - check `Automatically check for updates`
    - Free Downloads: `Save Password`

_You might be prompted ahead of time to do so, but the new auto-update feature is by default not disruptive and I recommend it._  I also find it annoying to have to enter my password for free downloads.

- Accessibility
    - Display
        - uncheck `Shake mouse pointer to locate`

_This is confusing, but with this setting enabled if you move your mouse rapidly back and forth it will suddenly grow enormous, which I found distracting._


### safari configuration

I don't use safari, but I do modify the default configuration just in case I need to:

- General:
    - Safari opens with: `All windows from last session`
    - Homepage: `https://www.google.com`
    - Remove history items: `After one day`
    - Top Sites shows: `6 sites`
    - Remove download list items: `Upon successful download`
- Search:
    - uncheck `Include Safari Suggestions`
    - uncheck `Enable Quick Website Search`
    - uncheck `Preload Top Hit in the background`
    - uncheck `Show Favorites`
- Advanced:
    - check `Show full website address`
    - Default encoding: `Unicode (UTF-8)`
    - check `Show Develop menu in menu bar`


### finder configuration

Surprisingly, finder has **four** configuration screens, making it fairly complex to work with.

The first is the global configuration accessed via `cmd+,`:

- General
    - check `Hard Disks`
    - check `Connected Servers`
    - New Finder windows show: `~/` (_your user folder_)
- Sidebar
    - Favorites
        - uncheck `All My Files`
        - uncheck `iCloud Drive`
        - uncheck `AirDrop`
        - check `~/` (_your user folder_)
    - Shared
        - uncheck `Back to My Mac`
        - uncheck `Bonjour computers`
    - Devices
        - check `/` (the system drive)
    - Tags
        - uncheck `Recent Tags`
- Advanced
    - check `Show all filename extensions`
    - uncheck `Show warning before changing an extension`
    - uncheck `Show warning before emptying trash`
    - When performing a search: `Search the Current Folder`

Next, from the user home folder you can open general folder configuration via `cmd+j`:

- check `Always open in list view`
- check `Date Created`
- check `Calculate all sizes`
- check `Show Library Folder`

When finished click `Use as Defaults` to enforce these changes system-wide.  _If you wish to override in any particular folder you can use `cmd_+j` again from any other folder._

Finally, if you activate the desktop and use `cmd+j` you will have desktop settings.  **They finally did such a good job that I have no desire to change the defaults.**


## software

- [homebrew](http://brew.sh/)
- [Dash](https://itunes.apple.com/us/app/dash-docs-snippets/id458034879?mt=12)
- [Unarchiver](https://itunes.apple.com/us/app/the-unarchiver/id425424353?mt=12)
- [XCode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12)
- [Google Chrome](https://www.chromium.org/getting-involved/dev-channel)
- [Google Hangouts Plugin](https://www.google.com/tools/dlpage/hangoutplugin)
- [iTerm2](http://www.iterm2.com/#/section/home)
- [Sublime Text](http://www.sublimetext.com/3)
- [VirtualBox](https://www.virtualbox.org/)
- [VirtualBox Extensions](https://www.virtualbox.org/wiki/Downloads)
- [Transmission](http://www.transmissionbt.com/download/)
- [Adobe Flash Projector](http://www.adobe.com/support/flashplayer/downloads.html)
- [go version manager](https://github.com/creationix/nvm)
- [node version manager](https://github.com/moovweb/gvm)

The homebrew package manager saves the day when it comes to a myriad of support tools.

Dash and Sublime Text are not free, but come highly recommended.  **If you are a developer and can afford to buy a copy, you should.**

_Installing the entire XCode toolkit is entirely optional, most will settle on the command line tools installed during homebrew installation._

_While flash might cater to a dying industry, I still like the option of being able to run swf files locally without browser plugins as a dependency._

The version managers for go and node are for developers, and simplify installation of the latest versions of our favorite toys.


### [custom fonts](software/fonts.md)

Many of my configuration files depend on custom fonts added to `/Library/Fonts` or at least `~/Library/Fonts`.


### [sublime text](software/sublime-text.md)

Visit the shared document for steps and configuration file templates.

Afterwards, add the command line symlink:

    sudo ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl


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

Finally, import the [`Solarized High Contrast Dark`](https://gist.github.com/jvandellen/2892531) color scheme from the GUI from "Profiles" > "Colors".


### virtualbox

I recommend at least creating a Host-Only network with a predictable IP range, which you can later use to specify static IP's in your virtual machines for more convenient local communication.  _VirtualBox's aim is enterprise security, so by default it forces a NAT firewall around its networking solution._


## autoconfig

To help simplify some of the following steps, you can run this command to download and execute a script instead:

    curl -L "https://raw.githubusercontent.com/cdelorme/system-setup/master/osx.sh" | bash

_If you don't trust the script, or wish to perform the operations manually, I have provided some of the details here._


### dot-files

**I highly recommend installing [dot-files](https://github.com/cdelorme/dot-files/) to help make the command prompt more user friendly.**  Visit mine to learn more, or find out how to install them.


## youtube-dl

This utility has many uses, and the installation is fairly basic:

    sudo curl https://yt-dl.org/downloads/2016.03.06/youtube-dl -o /usr/local/bin/youtube-dl
    sudo chmod a+rx /usr/local/bin/youtube-dl

_Further it is self-updating when you use `youtube-dl -U`._


### ssh key generation

It is recommended that you generate an ssh key, which can be used for ssh tunneling, numerous encryption services, and version control software.

You can easily generate one with the following command:

    ssh-keygen -t rsa -b 4096
    ssh-add -K ~/.ssh/id_rsa

_Using the `-K` will store the passphrase in your keychain, allowing painless reloading on reboot._


### homebrew packages

Before installing homebrew packages, you should get a token with your github account to prevent rate-limiting when running homebrew operations.  _Setting the token to the `HOMEBREW_GITHUB_API_TOKEN` environment variable in your `~/.bash_profile` is the way to solve it._

If you are a developer, you probably want to install a number of these packages and their dependencies:

- vim (/w `--override-system-vi`)
- tmux
- git
- openssl
- wget
- Caskroom/cask/osxfuse
- Caskroom/cask/sshfs
- mplayer

There are also many multimedia utilities for video and audio enthusiasts:

- lame
- jpeg
- faac
- libvorbis
- x264
- openh264
- xvid
- theora
- graphicsmagick
- imagemagick
- swftools
- ffmpeg (/w `--with-tools`)
- sfml
- homebrew/versions/glfw3
- sdl2_gfx
- sdl2_image
- sdl2_mixer
- sdl2_net
- sdl2_ttf
- sdl_gfx
- sdl_image
- sdl_mixer
- sdl_net
- sdl_rtf
- sdl_sound
- sdl_ttf

Finally, for developer machines these are recommended:

- mercurial
- svn
- bzr
- awscli
- Caskroom/cask/vagrant
- docker-machine
- docker-compose
- terraform

_You can initialize docker-machine via `docker-machine create --driver virtualbox default`, which can then be automatically loaded for  `docker` command access from the host via `eval $(docker-machine env default)` in `~/.bash_profile`._


#### git configuration

After installing git with homebrew, you will want to set your name, email, and keychain helper globally to optimize behavior:

    git config --global credential.helper osxkeychain
    git config --global user.name <name>
    git config --global user.email <email>

_I generally create a `~/git/` folder to store my projects._

I highly recommend [Ralph Bean's Awesome Git Flow Tutorial](http://threebean.org/presentations/gitflow/#/step-1) and the [Git Bash Completion](https://github.com/git/git/blob/master/contrib/completion/git-completion.bash) script as well.  You may also want to download and install `~/.githelpers`, written by [Gary Bernhardt](https://github.com/garybernhardt/dotfiles/blob/master/.githelpers).


## markdown quicklook

To easily preview markdown files using the quick-look hotkey, you can install an open source generator from [here](https://github.com/toland/qlmarkdown).  Simply download the latest release, and move it to `/Library/QuickLook/`.  _You will be asked for "authenticate"._


## next restart

The next time you restart your system, feel free to uncheck `Remember open windows` to prevent the system from keeping track of that stuff.


## references

- [OS X Fonts](http://support.apple.com/kb/ht2435)
- [iTerm2 Config](https://code.google.com/p/iterm2/issues/detail?id=1052)
- [Remap Capslock](http://stackoverflow.com/questions/127591/using-caps-lock-as-esc-in-mac-os-x)
- [iTerm2 alt hotkeys](https://code.google.com/p/iterm2/issues/detail?id=1052)
- [iTerm2 unlimited history](http://stackoverflow.com/questions/12459755/zsh-iterm2-increase-number-of-lines-history)
