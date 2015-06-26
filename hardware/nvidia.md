
# nvidia

I use an nvidia graphics card in my gaming rig.  In any other system the integrated gpu's in modern CPU's are more than enough to handle everday workloads, including high definition video playback and even gaming with lower graphics settings.

However, when you need to pull out the big guns to handle intense processing of effects and 3D animation, or if you happen to work in a field that produces those things, then you'll probably need a discrete graphics card.

Unfortunately, that's where behavior necessitates a guide.

## black screens at boot

At boot time the screen went black.

Turns out adding `nomodeset` to the kernel boot line in grub fixes this.  _This can be done by pressing `e` at the grub boot menu and editing the line, then hitting F10 to continue,_ or by pressing `f6` if running a live usb.  Once you add it to `/etc/default/grub` be sure you run `update_grub`.


## installing latest nvidia driver

I had a card that was too new for the package manager driver version, so I had to download it off the website.  Installing it that way leaves a lot to be desired.  I ran the command with these arguments:

    -q -a -n -X -s -Z --install-compat32-libs --dkms

_The first time it didn't create the nouveau blacklist and I had to make one myself:_

    echo "nouveau" >> /etc/modprobe.d/nouveau-blacklist.conf

However, with the flags the second time it asked and I was able to say "yes", which seemed to work.

While it installed the lib32 files, it put them into `/usr/lib/i386-linux-gnu/`, which is non-standard.  _This might be fixable by adding more flags to the install process_, because software like steam can't find the 32 bit libGL it crashes.  The temporary fix is to add these lines to `/etc/ld.so.conf.d/steam.conf`:

    /usr/lib32
    /usr/lib32/i386-linux-gnu

Finally, run this command to rebuild the ld cache:

    ldconfig

_Obviously it may cause new issues loading from that folder, but so far it's running fine and I can't tell if the nvidia installer even listened to the flags I provided._
