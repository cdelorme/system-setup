
# system setup

This repository functions as a home for documentation and automation of system configuration.

Ideally documentation will either mirror or supplement the automated scripts.

Documentation that is modular or independent of a particular configuration will be separated, organized, and referenced.


## platforms

My primary systems are [osx](osx/readme.md) for laptops and [debian (jessie)](linux/debian/jessie.md) for desktops and servers; _as a result my linux automation and documentation have limited support for laptop and wireless tools._

The automation has been written purely to scratch my own itch.  However, I document almost everything I have configured; **for complex configuration check out my [extensive documentation](linux/) for instructions and code snippets.**

For mac optimizations, try this:

	curl -Lo osx.sh "https://raw.githubusercontent.com/cdelorme/system-setup/master/osx/el-capitan.sh" && bash osx.sh

For debian automation, give this a shot:

	wget --no-check-certificate -qO debian.sh "https://raw.githubusercontent.com/cdelorme/system-setup/master/linux/debian/jessie.sh" && bash debian.sh

_This script may ask for input, which can be preseeded with environment variables._

# references

These are just some of the many online resources I used during construction:

- [debian jessie preseed](https://www.debian.org/releases/stable/amd64/apbs04.html.en)
- [hyperlaunch](https://gameroomsolutions.com/setup-hyperspin-mame-hyperlaunch-full-guide/)
- [2015 howto setup](https://www.youtube.com/watch?v=PxigHfBUPiA)
- [jis config reference](http://okomestudio.net/biboroku/?p=1834)
- [scim console jis support ubuntu 8.x (old docs but relevant to my interests)](http://ubuntuforums.org/showthread.php?t=975144)
- [resource using xdg for icons?](https://wiki.archlinux.org/index.php/Xdg_user_directories)
- [python script for older ubuntu?](http://www.webupd8.org/2009/11/music-album-covers-and-picture-previews.html)
- [similar project](http://ubuntuforums.org/showthread.php?t=226199&page=3)
- [another project](https://www-user.tu-chemnitz.de/~klada/?site=projects&id=albumcover)
- [KDE implementation, worth investigating?](http://ppenz.blogspot.com/2009/04/directory-thumbnails.html)
- [this plus a patch](https://github.com/gcavallo/pcmanfm-covers)
- [the patch](https://sourceforge.net/p/pcmanfm/bugs/1020/)
- [setting user global hooks](https://coderwall.com/p/jp7d5q/create-a-global-git-commit-hook)
- [golang example](https://golang.org/misc/git/pre-commit)
- [automatically reload](http://superuser.com/questions/181377/auto-reloading-a-file-in-vim-as-soon-as-it-changes-on-disk)
- [more vim awareness](http://vim.wikia.com/wiki/Have_Vim_check_automatically_if_the_file_has_changed_externally)
- [automated installation](https://debian-handbook.info/browse/stable/sect.automated-installation.html)
- [extremely complicated parameterized debian uefi packer kit](https://github.com/tylert/packer-build)
- [Everything you need to know about conffiles: configuration files managed by dpkg](https://raphaelhertzog.com/2010/09/21/debian-conffile-configuration-file-managed-by-dpkg/)
- [sway (i3 for wayland)](http://swaywm.org/)
