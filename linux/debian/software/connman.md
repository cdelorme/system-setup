
# connman

A user-interface for a connection manager, which covers wired and wireless connections **and** bluetooth!

This is absolutely essential for laptop users, and was a convenient tool for a desktop to toggle the devices on and off.

There is one problem, if the taskbar is at the bottom of the screen then the ui package breaks.  To fix it, you can move the taskbar to the top of the screen, or compile the software yourself.

It depends on three packages:

- `libdbus-1-dev`
- `libglib2.0-dev`
- `libgtk-3-dev`
- `connman`

_The UI package is merely a frontend to the daemon, so the `connman` package must be installed._

Compilation can be safely automated as follows:

	# build connman-ui
	if ! which connman-ui &>/dev/null; then
		rm -rf /tmp/connman-ui
		git clone https://github.com/tbursztyka/connman-ui.git /tmp/connman-ui
		pushd /tmp/connman-ui
		./autogen.sh
		./configure --prefix=/usr
		make
		make install
		popd
	fi
