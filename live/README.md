
# Debian Live Custom Intaller ReadMe

This section is dedicated to my project to create a custom Debian Installer, complete with a Live boot option.

The installer would come with an answer file, additional packages preferred by default, and be modifiable on a USB key for persistent state.

In addition a custom kernel configuration could be used to give us the latest and greatest features and hardware compatibility.

This would allow the packages to be updated keeping the Live boot up-to-date and reducing the installer process.

Ideally when loaded a menu should provide options for:

- Xen
- Web
- Comm
- Live

Where `Live` boots to the USB, and the other three run the custom installation, complete with a post-install script that automates further configuration for their respective purposes.


_This project is still in the planning phase._


---

**Reference Material:**

- [Debian Custom Reference](http://crunchbang.org/forums/viewtopic.php?id=25489)
