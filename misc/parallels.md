
#### Parallels Desktop Mods

To install parallels tools you will need to mount the iso with execution options:

    mount -o exec /dev/cdrom /media/cdrom
    /media/cdrom/install

The install script must be executed with root permissions.

Parallels Desktop 8 broke when installing parallels tools, and the 3D driver never loaded.  To resolve this you have to modify the init file post install.

**As of Parallels Desktop 9 the install process is fixed, but the drivers will still fail to load and in most cases a GUI is unusable.  I have since given up on using this platform and use VirtualBox instead.**

Post-installation you may encounter a video problem if the `/etc/initd/prl-x11` script does not contain the correct insserv headers, but you can easily add them to the top and re-run the script before rebooting:

    # Add LSB insserv Compatibility
    ### BEGIN INIT INFO
    # Provides:          prl-x11
    # Required-Start:    $remote_fs
    # Required-Stop:     $remote_fs
    # Default-Start:     2 3 4 5
    # Default-Stop:      0 1 6
    # Short-Description: x11 guest driver extension
    # Description:       prl-x11 is a parallels service that configures X11
    #                    for guest virtual machines.
    ### END INIT INFO


**Grub Configuration:**

First, open up `/etc/default/grub` and find the line with `#GRUB_GFXMODE=640x480` and change it to `GRUB_GFXMODE=1024x768` or a resolution of your choice.

Next open up `/etc/grub.d/00_header`, and find the line with `set gfxmode=${GRUB_GFXMODE}` and add `set gfxpayload=keep` below it before `load_video`.

Now run `update-grub` and reboot your system.  Your terminal will now be sized better for working directly instead of over SSH if desired.  _Be careful_, as a larger resolution can render the text unreadable.
