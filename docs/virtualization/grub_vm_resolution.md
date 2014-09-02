
#### Grub VM Resolution

First, open up `/etc/default/grub` and find the line with `#GRUB_GFXMODE=640x480` and change it to `GRUB_GFXMODE=1024x768` or a resolution of your choice.

Next open up `/etc/grub.d/00_header`, and find the line with `set gfxmode=${GRUB_GFXMODE}` and add `set gfxpayload=keep` below it before `load_video`.

Now run `update-grub` and reboot your system.  Your terminal will now be sized better for working directly instead of over SSH if desired.  _Be careful_, as a larger resolution can render the text unreadable.
