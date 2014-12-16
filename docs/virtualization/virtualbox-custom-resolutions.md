
# virtualbox custom resolutions

You can add custom resolutions of a size of your choice to a virtualbox machine using VBoxManage.

_Assuming your vm name is `debian`_, the following command will supply a video resolution hint at runtime:

    VBoxManage controlvm debian setvideomodehint 1120 630 32

From there you may need to relaunch the graphical environment, or use system builtin menus to change to that resolution.


Another option which will work while the box is offline is:

    VBoxManage setextradata debian CustomVideoMode1 1120x630x32

Upon rebooting it should assume the first available video mode.

**Both methods are valid, but some systems will only recognize one of the two settings.**
