
# nvidia

While the onboard GPU's in most modern CPU's are more than enough to handle 1080p resolutions, video playback, and even games at low specifications, a discrete graphics card is still leagues ahead of onboard.

_For my case, I find nvidia has much better drivers on linux making them my preference._

While debian recommends using their `nvidia-driver` package, sadly I always end up with newer cards and debians 2-year update cycle is just not acceptable for that.  _Installing the graphics driver does mean that an upgraded kernel also requires a rebuild of the nvidia drivers, but I find that to be an amusing problem since debian also almost never releases new kernels._

In general these are the three steps for my automation:

- check for the device
- download and execute the nvidia driver
- apply `nomodeset` to grub configuration

**If you are using a newer nvidia card during installation of debian, you may get a black screen or even less useful a screen that appears to have locked up leaving partial boot text.**  Simply reboot to the grub menu and use `e` to edit and add `nomodeset` to the end of the `linux ` line then press F10 to start.


## black screen

You may encounter a black screen if you reboot after installing the nvidia driver.

To address this problem, you have to add `nomodeset` to `GRUB_CMDLINE_LINUX_DEFAULT` inside `/etc/default/grub` and then run `update-grub` before restarting.

_To get video back temporarily, you can press `e` at the grub boot menu, then use `F10` after manually adding the line._


## installing latest nvidia driver

If your card is too new to be supported by the package managers `nvidia-driver`, then you may have to download the latest off the manufacturers website.

I found these flags worked best for the installation:

    NVIDIA-linux.run  -a -q -s -n --install-compat32-libs --compat32-libdir=/usr/lib/i386-linux-gnu --dkms -X -Z

_The flag order may matter, so be careful if typing it by hand._

Quite a few applications depend on the 32bit libraries (`steam` for example).  Make sure the path specified is loaded by a file in `/etc/ld.so.conf.d/`.

Make sure you run `ldconfig` before rebooting to ensure the new files are correctly added.

Finally make sure that `nouveau` was added to a blacklist file somewhere in `/etc/modprobe*` before you reboot.
