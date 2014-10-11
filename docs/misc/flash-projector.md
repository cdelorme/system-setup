
# flash projector

You can find the linux flash projector here:

- [Download Linux Flash Projector](http://www.adobe.com/support/flashplayer/downloads.html)

##### commands

_Extract and move it, then install dependencies:_

    tar xf flash*.tar.gz
    mv flashplayer /usr/bin/flashplayer
    rm *.tar.gz
    dpkg --add-architecture i386
    aptitude install ia32-lib libgtk-3-0:i386 libgtk2.0-0:i386 libasound2-plugins:i386

