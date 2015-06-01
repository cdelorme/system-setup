
# flash projector

I often run across old flash files and would like to see what they contained without loading them into a browser.

This process is relatively simple.  Download the [flash projector](https://www.adobe.com/support/flashplayer/downloads.html) for linux, install the dependencies, decompress and place it somewhere accessible (eg. `/usr/local/bin/`):

	aptitude install -ryq libgtk-3-0:i386 libgtk2.0-0:i386 libasound2-plugins:i386 libxt-dev:i386 libnss3 libnss3:i386
	curl -Lso /tmp/flash.tar.gz http://fpdownload.macromedia.com/pub/flashplayer/updaters/11/flashplayer_11_sa.i386.tar.gz
	tar xf /tmp/flash.tar.gz -C /tmp
	rm /tmp/flash.tar.gz
	mv /tmp/flashplayer /usr/local/bin/flashplayer

Finally, you can add these lines to `~/.local/share/applications/mimeapps.list`:

    application/x-shockwave-flash=flash.desktop;
    application/vnd.adobe.flash.movie=flash.desktop;

An option for convenience would be to create a [`~/.local/share/applications/flash.desktop`](../data/usr/share/applications/flash.desktop) file.  _Don't forget to reload the desktop preferences (`update-desktop-database` with root privileges)_
