
# dev environment documentation
#### updated 2014-8-17

This document consists of configuration steps that will extend gui and comm system configuration.

It will install additional development packages, and configure them as well as modify some system configuration defaults.


## install packages

- gd
- imagemagick
- graphicsmagic




## xorg framerate limiting

By default, xorg will restrict framerates to 60fps.  This limit is generally useful as it can prevent choppy video and tearing problems in video or poorly built video code.

However, if you are running performance tests, for example trying to test code speed via fps, then it becomes a hindrance on any modern machine.

For development, you should disable this feature by creating, and then modifying the xorg config file.


##### commands

_Create the config file:_

    TODO

_Modify the line that restricts higher FPS:_

    TODO
