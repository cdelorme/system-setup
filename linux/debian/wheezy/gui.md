
# Debian Wheezy GUI Documentation
#### Updated 2014-2-20

This is my desktop development configuration documentation, and continues where my template documention left off.


## Hardware

My template can run on 512MB of RAM, but for the GUI environment you will need at least 800MB, preferably 1GB or more if you want to use that environment.


## Troubleshooting

A graphics card will be required, though driver installation varies wildly and won't be covered here.  If you install the packages below and cannot run startx or telinit 3 into the gdm3 GUI, then you may have to look elsewhere for future guides.


## Configuration

This document discusses some generic tools and is not tied to any interface in particular.  It is a set of recommendations, not required to run a user interface.

Let's start with a set of generic tools and services:

    aptitude install -r -y gparted vlc gtk-recordmydesktop chromium ffmpeg lame ttf-freefont ttf-liberation ttf-droid ttf-mscorefonts-installer transmission transmission-cli openshot

For development I also recommend these packages:

    aptitude install -r -y bpython libguichan-dev libX11-dev libmcrypt-dev python-dev python3-dev python-pygame libperl-dev openjdk-6-jre


## Other Recommended Software

### Sublime Text

_These instructions vary slightly depending on whether you are using Sublime Text 2 or Sublime Text 3, though 3 is in beta it offers many improvements over the second version, and is moderately stable._

Let's start by downloading the latest copy off their website.

Grab the latest version off their website:

    # Download Sublime Text 3
    wget -O ~/sublime.tar.bz2 http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3059_x64.tar.bz2
    tar xf sublime.tar.bz2
    rm sublime.tar.bz2

    # Download Sublime Text 2
    wget -O ~/sublime.tar.bz2 http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.2%20x64.tar.bz2
    tar xf sublime.tar.bz2
    rm sublime.tar.bz2

You have a choice with sublime, you can install a system local copy, but I recommend a local copy per user to avoid version concerns.  It will create a settings folder per user automatically.

To install globally:

    mkdir /usr/local/applications
    mv Sublime* /usr/local/applications/sublime_text/
    ln -s /usr/bin/subl /usr/local/applications/sublime_text/sublime_text

To install locally:

    mkdir ~/applications
    mv Sublime* ~/applications/sublime_text/
    mkdir -p ~/bin
    ln -s ~/applications/sublime_text/sublime_text ~/bin/subl

_Copying with the asterisk may fail if there are multiple items that start with the first word._

I recommend these packages for the editor:

- [Package Control](https://sublime.wbond.net/)
- [Markdown Preview](https://github.com/revolunet/sublimetext-markdown-preview)
- [SublimeCodeIntel](https://github.com/SublimeCodeIntel/SublimeCodeIntel)
- [Origami](https://github.com/SublimeText/Origami)

My sublime text configuration appears as:

    {
        "auto_complete_commit_on_tab": true,
        "caret_style": "phase",
        "color_scheme": "Packages/Color Scheme - Default/Sunburst.tmTheme",
        "font_face": "ForMateKonaVe",
        "font_size": 16.5,
        "highlight_line": true,
        "highlight_modified_tabs": true,
        "match_brackets_angle": true,
        "scroll_past_end": true,
        "scroll_speed": 2.0,
        "translate_tabs_to_spaces": true,
        "trim_trailing_white_space_on_save": true
    }

_This does depend on the custom `ForMateKonaVe` font._

I add also modify the hotkeys for SublimeCodeIntel go-to-definition and Markdown Preview to build to browser:

    [
        { "keys": ["ctrl+enter"], "command": "goto_python_definition"},
        { "keys": ["ctrl+tab"], "command": "next_view" },
        { "keys": ["ctrl+shift+tab"], "command": "prev_view" },
        { "keys": ["alt+m"], "command": "markdown_preview", "args":
            { "target": "browser", "parser": "markdown" }
        }
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

_While this document is centric to debian, I feel it beneficial to share that fedora and ubuntu both work with the above configuration, however Arch does not read the PATH variable for the local `~/bin` folder, and does not expand the tilde into the home directory, requiring static paths._


# References

- [wallpapers wa](http://wallpaperswa.com/)
