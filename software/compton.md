
# [compton](https://github.com/chjj/compton)

This compositor is a great improvement over the older packages, and highly performance.

Building it from source is your only option on debian wheezy, but in jessie it comes packaged.

While it can be run without any configuration, to resolve screen tearing issues you will likely want a modified configuration file.  Configuration files are stored at [`~/.compton.conf`](../data/etc/skel/.compton.conf), and are automatically loaded.  The alternative is to supply all the options as flags to the command.

For my situation, I load it at boot time with openbox via the autostart script.

The `vsync = "opengl-swc"` and `glx-no-rebind-pixmap = true` settings work well with nvidia and intel integrated graphics (I have not tested with amd/ati yet), but do not work well in virtualbox.
