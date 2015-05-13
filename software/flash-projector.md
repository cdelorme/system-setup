
# flash projector

I often run across old flash files and would like to see what they contained without loading them into a browser.

This process is relatively simple.  Download the [flash projector](https://www.adobe.com/support/flashplayer/downloads.html) for linux, then install these packages:

- `libnss3:i386`
- `libgtk2.0-0:i386`
- `libcurl3:i386`

You can extract the gz with `flashplayer` and move that to some location in `PATH` like `/usr/local/bin/`.

For convenience you may want to create a `~/.local/share/applications/flash.desktop` file like this:

    [Desktop Entry]
    Name=Flash Projector
    Comment=Run swf files locally
    Exec=flashplayer
    Type=Application
    Categories=Multimedia;AudioVideo;Player;
    MimeType=application/x-shockwave-flash;

Finally, you can add these lines to `~/.local/share/applications/mimeapps.list`:

    application/x-shockwave-flash=flash.desktop;
    application/vnd.adobe.flash.movie=flash.desktop;

_Don't forget to reload the desktop preferences (`update-desktop-database` with root privileges)_
