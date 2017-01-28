
# openbox

This is my preferred desktop environment, or I should say "Window Manager".

It only has one function, providing X interaction for decorations and placement of windows, plus a context menu for easier application launching.

It is extremely light weight thus is fantastic for virtual machines, laptops, and productivity focused desktops.

It provides very simple, well documented, text configuration files with excellent flexibility.

Finally, since it does not handle every other facet of the interface, you are free to select exactly which tools you want to file browsing, taskbar, and extra visuals such as resource monitoring.


## hotkeys

I have hand-crafted my openbox configuration to offer the absolute best possible productivity boost, and they can be classified into two categories:

- launching applications
- window manipulation

Here are the hotkeys to launch applications:

-


Here are my choice of window manipulation hotkeys:

-


## theming

Since openbox itself is dead simple the only real changes you can modify are window decorations.

You can select from available options with `obconf`, or you can install a custom theme that meets your desired aesthetics.

I like the black-onyx theme, but I also enjoy numix:

	# install dark gtk theme
	git clone https://github.com/numixproject/numix-gtk-theme /tmp/numix
	safe_aptitude_install ruby libxml2-utils
	gem install sass
	pushd /tmp/numix
	make
	make install
	popd
	yes | gem uninstall sass
	aptitude purge -yq ruby libxml2-utils

While not a direct openbox feature, you can augment icons used by the file browser by installing and selecting them.  Here is the moka kit:

	# install custom icons
	git clone https://github.com/snwh/moka-icon-theme /tmp/moka
	pushd /tmp/moka
	./autogen.sh
	make install
	popd
	rm -rf /tmp/moka
