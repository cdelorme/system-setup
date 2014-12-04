
# [flash projector](http://www.adobe.com/support/flashplayer/downloads.html)

It is a stand-alone flash player that can be run locally on any system, including linux.

I find this to occassionally be useful when I find a resource online that is only available in flash (rare, but it happens).


##### linux commands

_Extract and move it, then install dependencies:_

    tar xf flash*.tar.gz
    mv flashplayer /usr/bin/flashplayer
    rm *.tar.gz
    dpkg --add-architecture i386
    aptitude install ia32-lib libgtk-3-0:i386 libgtk2.0-0:i386 libasound2-plugins:i386

