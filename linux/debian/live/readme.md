
# Debian Live Custom Intaller ReadMe

I wanted to find a way to fully automate an entire installation, as well as provide updatable live-run support.

This would involve a heavily modified debian installer image, with a special set of boot options.

---

It should be compatible with both UEFI and BIOS boot methods, and specifically be burnable to a USB drive (not an ISO).

It should provide menu options for:

- Live
- Manual Install
- Template
- Web
- Comm
- Xen

The live system would effectively be a USB installed copy of debian, but tailored to run primarily in memory.  However, it would be able to retain state using the USB and a writable partition.  This would allow the "Live" system to be updated over time.

The manual installation should take the user to an expert install mode.

The other options would be fully automated using a preseed, and then post-install running my system-setup scripts to finish configuring the entire system for a specific use.


---

A single USB that can be used for live boot, testing, or quick work environment setup, including fully automated configuration.

It would be like bringing my computer with me.

---

**Reference Material:**

- [Debian Custom Reference](http://crunchbang.org/forums/viewtopic.php?id=25489)
- [Debian Installer](https://wiki.debian.org/DebianInstaller)
- [Debian Preseed Docs](http://www.debian.org/releases/stable/i386/apb.html)
