
# [sublime text](http://www.sublimetext.com/)

Sublime Text is a fabulous editor with plugins that support nearly everything any IDE can do.  It loads lightning fast, renders near-identically cross all major operating systems, and is one of the first **good** light-weight editors I've found with font anti-aliasing (even on windows).  It is "nagware" so if you want to avoid an occasional popup then buy it, it is well worth the cost.

_Worth noting, the Sublime Text 2 keys work for Sublime Text 3 while it is in beta, and also Sublime Text 3 encrypts the keys now so you cannot simply copy them to the install folder in an automated fashion._


## [download](www.sublimetext.com/3)

The first step would be to download it off their website!

Next we want to install [package control](https://sublime.wbond.net/installation) for sublime text, which will give us the ability to effortlessly install any package and update it going forward.

I recommend these packages for the editor:

- [Package Control](https://sublime.wbond.net/)
- [Markdown Preview](https://github.com/revolunet/sublimetext-markdown-preview)
- [SublimeCodeIntel](https://github.com/SublimeCodeIntel/SublimeCodeIntel)
- [DefaultFileType](https://github.com/spadgos/sublime-DefaultFileType)
- [GoSublime](https://github.com/DisposaBoy/GoSublime)
- [Origami](https://github.com/SublimeText/Origami)
- [EncodingHelper](https://github.com/SublimeText/EncodingHelper)

_Unfortunately there is no cli to automate sublime package management.  The next-best alternative is to download and install the packages manually from their repositories._  Package control is preferred as it will keep the source updated as new content is released.

With few exceptions (such as the license file), sublime text configuration is handled a as raw json files, allowing them to be easily modified.  Additionally they makes them portably cross platform!


## shared configuration

While all platforms share sublime text configurations, the install path varies:

- windows: `~/AppData/Roaming/Sublime Text 3/`
- linux: `~/.config/sublime-text-3/`
- osx: `~/Library/Application\ Support/Sublime\ Text\ 3/`

Here is a set of configuration files, assuming a starting at the parent paths by platform above, which link to my preferenced configurations:

- [`Packages/User/Preferences.sublime-settings`](../data/etc/skel/.config/sublime-text-3/Packages/User/Preferences.sublime-settings)
- [`Packages/User/Default (Linux).sublime-keymap`](../data/etc/skel/.config/sublime-text-3/Packages/User/Default (Linux).sublime-keymap)
- [`Packages/User/Default (OSX).sublime-keymap`](../data/etc/skel/.config/sublime-text-3/Packages/User/Default (OSX).sublime-keymap)
- [`Packages/User/default_file_type.sublime-settings`](../data/etc/skel/.config/sublime-text-3/Packages/User/default_file_type.sublime-settings)
- [`Packages/User/MarkdownPreview.sublime-settings`](../data/etc/skel/.config/sublime-text-3/Packages/User/MarkdownPreview.sublime-settings)


## platform specific tuning

Some platforms are more... privileged than others.  These platforms give you additional enhancements, such as terminal commands to launch the software.


### osx

You can add a symbolic link to the sublime text application container:

    sudo ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/bin/subl


### linux

For linux, you get to choose where to install sublime text, and can simply create a symbolic link to the executable path for short-hand access (to match the `subl` osx command).

You can also create a `.desktop` launcher at [`~/.local/share/application/subl.desktop`](../data/usr/share/applications/subl.desktop).  _My example assumes an install path for grabbing the sublime text icons._
