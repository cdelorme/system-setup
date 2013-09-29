
# OS X Mountain Lion (10.8) Documentation

The following steps take me from a fresh installation of OS X Mountain Lion 10.8 to a glorious development environment.

_Note: Never use a Case Sensative file system, it breaks tons of software._

_Note 2: Setup Drive Encryption / File Vault **after** the installation and updates, otherwise you will need to remove and re-encrypt the drive for updates to File Vault._

First step after the installation should be updating the system.

## System Settings & Configuration

During or after these updates, you can configure the system as follows from `System Preferences`:

- Dock
    - Smaller Size
    - Slight Maginification
    - Align Right
    - Scale effect
    - All checkboxes

- Mission Control
    - Remove Show Dashboard from F12
    - Hot Corners
        - Application Windows Top Left
        - Desktop Top Right

**Add a second desktop to Mission control by default**

- Language & Text
    - Input Sources
        - Check Kotoeri

- Privacy & Security
    - Require Password 1 Minute after Display Sleep
    - File Vault
        - Enable User Access to Encrypted Disk
    - Turn Firewall On
        - Stealth Mode
    - Advanced:
        - Disable Remote Receiver

_Note: Retina MBP's no longer have Infrared Sensors and no remote receiver settings will exist._

- Displays
    - Do not automatically adjust brightness

- Energy Saver
    - Battery Display Sleep after 10 Minutes

- Keyboard
    - Keyboard
        - Turn off key backlighting after 10 seconds of inactivity
    - Keyboard Shortcuts
        - Launchpad & Dock
            - Disable toggle dock hiding
        - Mission Control
            - Turn on control hotkey Switch to Desktops 1 & 2
        - Keyboard & Text
            - Disable Change the way Tab moves focus
            - Disable toggle keyboard access
            - Add/Enable Select next source in input menu (cmd+alt+space)
        - Spotlight
            - Disable show spotlight window hotkey
        - Accessibility
            - Disable Voiceover Toggle
            - Disable Show Accessibility Controls
        - Bottom Setting "All Controls" not just inputs

- Touchpad
    - Tap to Click
    - Tracking Speed Faster than default
    - More Gestures
        - App Expose
        - Turn off Launchpad

- Sound
    - Tink (Alert Sound)
    - Reduced Alert Volume
    - Do not play feedback when volume is changed

- Bluetooth Off (Conserves battery)

- Time Machine
    - Do not show menu bar icon


---

**Install my custom fonts:**

- [ForMateKonaVe](http://d.hatena.ne.jp/hetima/20061102/1162435711)
- [EPSON Kyoukashoutai](http://www.wazu.jp/gallery/Fonts_Japanese.html)

_The EPSON font can be downloaded but the font name will be skewed by ASCII conversion, and you may need to run a Font Editor to make the name sensible again._


---

**Disable the dashboard completely:**

In a terminal window use:

    defaults write com.apple.dashboard mcx-disabled -boolean YES
    killall Dock

The dock will restart and the dashboard will no longer be loaded.


---

**Force List View as Default:**

Open finder settings with Command + J and make sure the box is checked, also check calculate size.

Next run these commands to remove all saved view files & reload Finder:

    sudo find / -name ".DS_Store" -depth -exec rm {} \;
    killall Finder

---

**Change Terminal settings:**

Set terminal to use Homebrew color scheme, and transparency to 40% with 5% blur.

Add these lines to the end of the /etc/bashrc for global, or your users .bashrc:

    # Add Colors
    export CLICOLORS=1
    export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
    export GREP_OPTIONS='--color=auto'
    alias ls='ls -FGa'

Download & install the [sunburst](https://github.com/tangphillip/SunburstVIM/blob/master/colors/sunburst.vim) color scheme for vim.

Create a file at `~/.vimrc` and add the line `colorscheme sunburst`.


---

**Unhide User Library (Optional):**

Execute this from terminal:

    chflags nohidden ~/Library


---

**Install Java:**

OS X comes without Java by default, but you can install it by running this command:

    java --version

It will supply a prompt, agree to start the installation.


## Program Installation & Configuration

From the App store I can grab these applications:

- Dash
- Unarchiver
- XCode

Next I gather and install the following applications:

- [Google Chrome Dev Channel](http://www.chromium.org/getting-involved/dev-channel)
- [Opera](http://www.opera.com/)
- [Firefox Aurora](http://www.mozilla.org/en-US/firefox/aurora/)
- [Firefox](http://www.mozilla.org/en-US/firefox/new/)
- [Omnigraffle](http://www.omnigroup.com/products/omnigraffle/)
- [Sublime Text 2](http://www.sublimetext.com/2)
- [iTerm 2](http://www.iterm2.com/#/section/home)
- [Parallels Desktop 8](http://www.parallels.com/products/desktop/)
- [Transmit](http://panic.com/transmit/)
- [MacTubes](http://macapps.sakura.ne.jp/mactubes/index_en.html)
- [xQuartz](http://xquartz.macosforge.org/landing/)
- [Inkscape](http://inkscape.org/)
- [Dia](https://wiki.gnome.org/Dia)

_You will need xQuartz installed to setup Dia and Inkscape._


The following list may include registration keys, add them now or when we configure them:

- Omnigraffle
- Sublime Text 2
- Parallels Desktop 8
- Transmit


### Configuration of several applications proceeds:

**XCode**

Open up the program, go to the settings, and select downloads.

In the list select `Install XCode Command Line Tools`.


**Dash**

Open the settings:

- Validate your purchased copy by selecting Purchase then `Restore` at the bottom
- Use HUD mode with alt+space as the hotkey

Select and Install this list of documentation:

- C
- C++
- CSS
- GLib
- Go
- HTML
- JavaScript
- jQuery
- Java SE7
- Java SE6
- Node.js
- OpenGL 2
- MySQL
- OpenGL 4
- Perl
- PHP
- Python 2
- Python 3

Keep the following list enabled, and disable the others:

- C
- C++
- Go
- JavaScript
- Java SE6
- Node.js
- PHP
- Python 2


**The Unarchiver**

Modify settings:

- Always Extract to same folder
- Affiliation with all files (except iso's etc)
- Delete compressed file after extraction


**iTerm 2**

Settings:

- Size 14 Font
- ForMateKonaVE Font Family

Import the `Solarized High Contrast Dark` color scheme from the GUI, as it loads these into the programs plist and cannot be done through command line.


**Parallels Desktop**

- Enter Registration Key
- Connect USB devices to Mac by default.
- Turn off customer experience features.


## Homebrew Package Manager

OS X is running UNIX and so many of the programs available to Linux can be used here.  We can install both Homebrew and MacPorts, or choose our favorite, or whichever has the software we want.

I chose Homebrew, it's incredibly easy to install, has yet to cause my system problems, has all the software I want on my Mac, and I prefer their phylosophy of no password to install user software which includes keeping my user garbage in my user path.

Homebrew does depend on xCode Command Line Tools, so these must be installed before you can use Homebrew.

So, let's install [Homebrew](http://mxcl.github.io/homebrew/):

    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"

After installation it will ask you to run this command:

    brew doctor

Now we are all set to install some desirable software:

    brew install tmux
    brew install git
    brew install git-flow
    brew install cppcheck
    brew install bash-completion
    brew install mercurial
    brew install vim
    brew install python
    brew install go


---

**PATH modifications:**

Override defaults to brew components by adding to `~/.profile`:

    export PATH=/usr/local/bin:$PATH


**Install bpython with pip:**

_When you install python pip is installed._

    pip install bpython


**SSH Key Generation:**

Run this command to create a high bit rate encrypted rsa key, be sure to supply your emai:

    ssh-keygen -t rsa -b 4096 -C "<youremail>"

Follow the prompts for the defaults, and you will have a `~/.ssh` directory.  You can now add your id_rsa.pub contents to various services, in my case my github, bitbucket, and gitorious accounts, as well as any machines I ssh into.


**Git Configuration:**

Ideally these should be set:

    git config --global user.name "<yourname>"
    git config --global user.email "<youremail>"
    git config --global core.editor "vim"
    git config --global help.autocorrect 1
    git config --global color.ui true

I also setup a folder at `~/git/` to store my git projects.

Following [Ralph Bean's Awesome Git Flow Tutorial](http://threebean.org/presentations/gitflow/#/step-1) and the [Git Bash Completion](https://github.com/git/git/blob/master/contrib/completion/git-completion.bash) script, I would also move modified copies of git-completion, githelpers, and git-prompt as hidden files to my home folder.

First `~/.gitconfig` is my global configuration, let's add these lines:

    [alias]
        l = "!. ~/.githelpers && pretty_git_log"

Finally we can add git autocompletion and make our terminal prompt amazingly intelligent by creating or adding these lines to `~/.profile`:

    . ~/.git-completion
    . ~/.git-prompt

Everything from here onward in terminal is going to look and feel pretty amazing.


**Bash completion:**

To add bash completion run this command:

    ln -s "/usr/local/Library/Contributions/brew_bash_completion.sh" "/usr/local/etc/bash_completion.d"


## Finishing Touches & Conclusion

**Sublime Text 2:**

Some of the steps here are dependent on other configurations, thus why it is last on this list, but it does not have to be.

If you have a license you should register your copy.

Add shortcut after installing and set default environment variable:

    sudo ln -s "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" /usr/bin/subl
    export EDITOR='subl -w'


Load these settings:

    // Settings in here override those in "Default/Preferences.sublime-settings", and
    // are overridden in turn by file type specific settings.
    {
        "color_scheme": "Packages/Color Scheme - Default/Sunburst.tmTheme",
        "font_face": "ForMateKonaVe",
        "font_size": 16,
        "translate_tabs_to_spaces": true,
        "highlight_line": true,
        "caret_style": "phase",
        "match_brackets_angle": true,
        "trim_trailing_white_space_on_save": true,
        "auto_complete_commit_on_tab": true,
        "scroll_speed": 2.0,
        "highlight_modified_tabs": true
    }


Install [Package Control](http://wbond.net/sublime_packages/package_control):

    import urllib2,os; pf='Package Control.sublime-package'; ipp=sublime.installed_packages_path(); os.makedirs(ipp) if not os.path.exists(ipp) else None; urllib2.install_opener(urllib2.build_opener(urllib2.ProxyHandler())); open(os.path.join(ipp,pf),'wb').write(urllib2.urlopen('http://sublime.wbond.net/'+pf.replace(' ','%20')).read()); print('Please restart Sublime Text to finish installation')


Install these plugins:

- [MarkdownBuild](https://github.com/erinata/SublimeMarkdownBuild)
- [Encoding Helper](https://github.com/SublimeText/EncodingHelper)
- [JSLint](https://github.com/fbzhong/sublime-jslint)
- [SublimeLinter](https://github.com/SublimeLinter/SublimeLinter)
- [SublimeCodeIntel](https://github.com/Kronuz/SublimeCodeIntel)
- [Git](https://github.com/kemayo/sublime-text-2-git/wiki)
- [DayleReese Color Schemes](https://github.com/daylerees/colour-schemes)
- [DashDoc](https://github.com/farcaller/DashDoc#readme)


**OS X Markdown QuickLook**

You can find the [source repository here](https://github.com/toland/qlmarkdown)

[Download the files](http://jamesmoss.co.uk/blog/support-for-markdown-in-osx-quicklook/), extract them, and copy the quickview to `/Libary/QuickLook`.

You will now be able to use spacebar to preview markdown files.


**Reorganize Dock**

Here is what my dock looks like when I am finished:

- Finder
- iTerm2
- Sublime Text 2
- xCode
- Transmit
- mnigraffle
- Dia
- Inkscape
- Chrome
- Safari
- Aurora
- Firefox
- Opera
- Parallels Desktop
- iTunes
- FaceTime
- Photobooth
- iPhoto
- iCal
- App Store
- System Preferences

I make sure to remove anything not in that list.


**Synchronize Accounts:**

Open system preferences and select the `Mail, Contacts & Calendars option` to add my GMail account.  This should handle setting up my mail and calendar.

I also synchronize Google Chrome dev channel with my gmail account.


**File Vault**

After everything has been configured I generally encrypy my drive from System Preferences > Security, using File Vault.  This wraps the drive contents in a password protected layer, and the encryption process itself can take a few hours.


---

Thus concludes my OS X setup process.  In the end I have a fully configured machine ready for development of any project I am interested in.

Note that a large number of development tools and tasks I do not do directly on my MBP.  I prefer a light-weight system to keep it running smooth.  Most services that would eat resources I shift off to virtual machines, which allow me to turn entire environments on and off.

