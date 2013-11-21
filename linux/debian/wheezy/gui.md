
# Debian Wheezy GUI Documentation
#### Updated 11-20-2013

This is my desktop development configuration documentation, and continues where my template documention left off.


## Hardware

My template can run on 512MB of RAM, but for the GUI environment you will need at least 800MB, preferably 1GB or more if you want to use that environment.


## Troubleshooting

A graphics card will be required, though driver installation varies wildly and won't be covered here.  If you install the packages below and cannot run startx or telinit 3 into the gdm3 GUI, then you may have to look elsewhere for future guides.


## Gui Configuration

Minimalist Gnome3 Packages:

    aptitude install -y gnome-session gnome-terminal gnome-disk-utility gnome-screenshot gnome-screensaver desktop-base gksu gdm3 xorg-dev ia32-libs-gtk binfmt-support xdg-user-dirs-gtk xdg-utils network-manager eog gparted guake gnash vlc gtk-recordmydesktop chromium

Development Tools:

    aptitude install -y glib-devel glibc-devel gnome-libs-devel gstream-devel gtk3-devel guichan-devel libX11-devel libmcrypt-devel qt3-devel qt-devel pythonqt-devel python-devel python3-devel pygame-devel perl-devel nodejs-devel ncurses-devel pygobject2-devel pygobject3-devel gobject-introspection-devel guichan bpython

_These development tools may significantly affect the size of the install, make sure you have the space on your root partition before proceeding._


**Adjust Boot Services:**

With the GUI installed we now have bluetooth and network-manager services we don't need, and GUI at run-level 2 which we want to turn off:

    update-rc.d network-manager disable 2
    update-rc.d network-manager disable 3
    update-rc.d network-manager disable 4
    update-rc.d network-manager disable 5
    update-rc.d bluetooth disable 2
    update-rc.d bluetooth disable 3
    update-rc.d bluetooth disable 4
    update-rc.d bluetooth disable 5
    update-rc.d gdm3 disable 2

This stops the network-manager from interfering with our interfaces network devices, and since we don't have bluetooth devices we eliminate a running daemon.

We can use `telinit 3` to start the GUI, or `startx` if preferred, allowing us to reduce consumed resources at boot time since we don't always need the GUI.


**Patch Guake:**

Guake has a known bug that has yet to be fixed where it prevents execution at login due to `notification.show()` commands not able to be processed.

    sed -i 's/notification.show()/try:\n                notification.show()\n            except Exception:\n                pass/' /usr/bin/guake
    rm /etc/xdg/autostart/guake.desktop

I create a new .desktop file in `~/.local/share/applications/guake.desktop` containing:

    [Desktop Entry]
    Name=Guake Terminal
    Comment=Use the command line in a Quake-like terminal
    TryExec=guake
    Exec=guake
    Icon=/usr/share/pixmaps/guake/guake.png
    Type=Application
    Categories=GNOME;GTK;Utility;TerminalEmulator;

Then I can easily setuo local autostart in `~/.config/autostart` and symlink the new .desktop:

    mkdir -p ~/.config/autostart
    ln -s ~/.local/share/applications/guake.desktop ~/.config/autostart/guake.desktop


**Setup Sublime Text:**

_I am using Sublime Text 2, but Sublime Text 3 may soon be replacing it, so these instructions are subject to change._

Installing a copy per-user is probably the best way to separate the application, but you can decide whether to put it someplace more global.

Grab the latest version off their website:

    wget -O ~/sublime.tar.bz2 http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.2%20x64.tar.bz2
    tar xf sublime.tar.bz2
    rm sublime.tar.bz2
    mkdir ~/applications
    mv Sublime* ~/applications/sublime_text/

With the formerly configured `~/bin` folder I create a symlink to `subl`:

    ln -s ~/applications/sublime_text/sublime_text ~/bin/subl

_An alternative would be to create a shell script file that runs `sublime_text &` to put the process in the background after launching._

I use these Sublime Text plugins:

- [Package Control](https://sublime.wbond.net/)
- [Markdown Preview](https://github.com/revolunet/sublimetext-markdown-preview)
- [SublimeCodeIntel](https://github.com/SublimeCodeIntel/SublimeCodeIntel)

I configure sublime text with:

    {
        "auto_complete_commit_on_tab": true,
        "caret_style": "phase",
        "color_scheme": "Packages/Color Scheme - Default/Sunburst.tmTheme",
        "font_face": "ForMateKonaVe",
        "font_size": 16.0,
        "highlight_line": true,
        "highlight_modified_tabs": true,
        "ignored_packages":
        "match_brackets_angle": true,
        "scroll_past_end": true,
        "scroll_speed": 2.0,
        "translate_tabs_to_spaces": true,
        "trim_trailing_white_space_on_save": true
    }

I add also modify the hotkeys for SublimeCodeIntel go-to-definition and Markdown Preview to build to browser:

    [
        { "keys": ["ctrl+tab"], "command": "next_view" },
        { "keys": ["ctrl+shift+tab"], "command": "prev_view" }
        { "keys": ["alt+m"], "command": "markdown_preview", "args":
            { "target": "browser", "parser": "markdown" }
        },
    ]

I create a desktop launcher using `~/.local/share/applications/subl.desktop` containing:

    [Desktop Entry]
    Name=Sublime Text
    Comment=The World's best text editor!
    TryExec=subl
    Exec=subl
    Icon=~/applications/sublime_text/Icon/256x256/sublime_text.png
    Type=Application
    Categories=GNOME;GTK;Utility;TerminalEmulator;Office;


**Enable GDM Login as Root:**

This is entirely optional, but I like having it in the event that I have to debug.

By default debian's pam is configured to disallow root gui login, but we can resolve this simply with:

    sed -i "s/user != root//" /etc/pam.d/gdm3
