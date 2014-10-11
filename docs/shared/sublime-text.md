
# [sublime text](http://www.sublimetext.com/)

Sublime Text is a fabulous editor with plugins that support nearly everything any IDE can do.  It loads lightning fast, renders near-identically cross all major operating systems, and is one of the first **good** light-weight editors I've found with font anti-aliasing on windows.  It is nagware so if you want to avoid an occasional popup then buy it, it is well worth the cost.

_Worth noting, the Sublime Text 2 keys work for Sublime Text 3 while it is in beta, and also Sublime Text 3 encrypts the keys now so you cannot simply copy them to the install folder._

The first step would be to download it off their website!

Next we want to install [package control](https://sublime.wbond.net/installation) for sublime text, which will give us the ability to effortlessly install any package and update it going forward.

I recommend these packages for the editor:

- [Package Control](https://sublime.wbond.net/)
- [Markdown Preview](https://github.com/revolunet/sublimetext-markdown-preview)
- [SublimeCodeIntel](https://github.com/SublimeCodeIntel/SublimeCodeIntel)
- [Origami](https://github.com/SublimeText/Origami)
- [EncodingHelper](https://github.com/SublimeText/EncodingHelper)
- [GoSublime](https://github.com/DisposaBoy/GoSublime)

It may also be worth checking out the [SublimeText Crypto Package](https://github.com/mediaupstream/SublimeText-Crypto) if you like the idea of encrypting your notes for on-the-fly text document security, it's pretty sweet.

Packages either have to be downloaded from their remote repositories, or the preferred approach is to install them using Package Control.  Package Control will keep your other packages updated as more content is released, hence it is preferred.

All sublime text configuration files are raw text, and can be easily modified.  Additionally they are mostly portable between platforms.


##### generic commands

_Install package control, run this inside sublime text console:_

    import urllib.request,os,hashlib; h = '7183a2d3e96f11eeadd761d777e62404' + 'e330c659d4bb41d3bdf022e94cab3cd0'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://sublime.wbond.net/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)

_User configuration file (assumes `ForMateKonaVe` font is installed):_

    {
        "auto_complete_commit_on_tab": true,
        "caret_style": "phase",
        "color_scheme": "Packages/Color Scheme - Default/Sunburst.tmTheme",
        "font_face": "ForMateKonaVe",
        "font_size": 14,
        "highlight_line": true,
        "highlight_modified_tabs": true,
        "match_brackets_angle": true,
        "scroll_past_end": true,
        "scroll_speed": 2.0,
        "translate_tabs_to_spaces": true,
        "trim_trailing_white_space_on_save": true
    }

_Custom hotkeys `~/.config/sublime-text-3/Packages/User/Default (Linux).sublime-keymap`:_

    [
        { "keys": ["ctrl+enter"], "command": "goto_python_definition"},
        { "keys": ["ctrl+tab"], "command": "next_view" },
        { "keys": ["ctrl+shift+tab"], "command": "prev_view" },
        { "keys": ["alt+m"], "command": "markdown_preview", "args":
            { "target": "browser", "parser": "markdown" }
        }
    ]


## linux

Linux installation is nice, since it's almost entirely file based.  The exception is packages.  I have yet to find a way to install them "easily" from command line using package control (as opposed to downloading their latest git repositories).

The user configuration file can be placed into `~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings` on linux.


##### linux commands

_Grab the latest version off their website, and install it locally (asterisk `cp` mail fail if multiple items start with the same characters):_

    # Download Sublime Text 3
    curl -o ~/sublime.tar.bz2 http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3059_x64.tar.bz2
    tar xf sublime.tar.bz2
    rm sublime.tar.bz2
    mkdir ~/applications
    mv Sublime* ~/applications/sublime_text/
    mkdir -p ~/bin
    ln -s ~/applications/sublime_text/sublime_text ~/bin/subl

_Optional desktop launcher `~/.local/share/applications/subl.desktop`:_

    [Desktop Entry]
    Name=Sublime Text
    Comment=The World's best text editor!
    TryExec=subl
    Exec=subl
    Icon=~/applications/sublime_text/Icon/256x256/sublime_text.png
    Type=Application
    Categories=Utility;TerminalEmulator;Office;


## mac

The mac version of sublime text acts the same as the rest, but exists inside of a .app package.  The `subl` command can be symlinked from inside that package.

Some packages will depend on tools to be installed from homebrew.  Be sure to review the dependencies of a package on its repository readme.

The user configuration file can be placed into `~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings` on osx.


##### osx commands

_Symlink the sublime terminal command:_

    sudo ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/bin/subl


## windows

There are no shortcuts or unique ways to automate editing your configuration files in Windows, just use the menu to open the files and configure them via copy and paste.

