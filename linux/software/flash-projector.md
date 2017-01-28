
# flash projector

I often run old flash files on my system, and would rather do so without the overhead of the web-browser or forcing the insecurity and risks onto the web browser.

**To solve this adobe supplies the [flash projector](https://www.adobe.com/support/flashplayer/downloads.html).**

This can be downloaded, extracted, and installed into `/usr/local/bin/`, but does have some dependencies you may need to work through.

For ease of access you should create a launcher in `~/.local/share/applications/flash.desktop` and add these lines to `~/.local/share/applications/mimeapps.list`:

    application/x-shockwave-flash=flash.desktop;
    application/vnd.adobe.flash.movie=flash.desktop;

_You may have to reload the desktop database for the change to take effect,_ but you can now launch flash locally on your desktop.
