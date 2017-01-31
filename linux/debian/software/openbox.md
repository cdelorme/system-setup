
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

The `Super` key is the linux-centric term used to describe what is also called the `Windows` key, `Start` key, `Command` key (on OSX), and a few other names.

Here are the hotkeys to launch applications:

- Super + Tab: show openbox menu
- Super + b: launch file browser (pcmanfm)
- Super + w: launch web browser (google chrome)
- Super + t: launch new terminal (urxvt)
- Super + e: launch text editor (sublime text)
- Super + x: exit openbox to terminal or login screen
- Super + `: toggle display of a persistent terminal (urxvt)
- Alt + F2 _or_ Super + Space: Run Dialog (gmrun)
- Super + Shift + 3: take a screenshot
- Super + Shift + 4: take a screenshot of the current application

_Screenshots have a significant delay and can be somewhat buggy._

There are also builtin controls to support volume and keyboard backlighting, assuming these exist on your keyboard.


Here are my choice of window manipulation hotkeys:

- Alt + Space: show window menu
- Alt + Escape: push focus to bottom
- Alt + Tab: cycle windows
- Alt + S + Tab: reverse cycle windows
- Control + Alt + Right: go to next virtual desktop
- Control + Alt + Left: go to previous virtual desktop
- Super + Up _or_ Super + Control + Up: toggle maximize
- Super + Right: send active window to next monitor
- Super + Left: send active window to previous monitor
- Super + Control + Right: set width to 50%, maximize height, and align right on the current monitor
- Super + Control + Left: set width to 50%, maximize height, and align left on the current monitor
- Control + Alt + Right: carry the active window to the next desktop
- Control + Alt + Left: carry the active window to the previous desktop

With these hot keys you can traverse all desktops and monitors, dragging all application windows kicking and screaming into a select group of very useful and common configurations.


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


## multihead

There are some quirks with openbox, one being how it handles multihead (eg. multi-monitor).

By default it only runs a single X instance, which treats multiple monitors like a single canvas.  _This on its own can yield some strange behaviors depending on how you configure your monitors._

It also treats all monitors as a single virtual desktop, which means changing desktops will effect all monitors at once.  _This is generally easy to reason about with pinning applications to all desktops._

The only "bug" I have encountered is the `ToggleMaximize` and `MoveResizeTo` behavior.  To send the currently active application to another monitor the `MoveResizeTo` operation can be called.  I have been unable to get `Unmaximize` behavior to correctly remain on the current monitor if `Maximize` was applied on another.  _I can only assume that `ToggleMaximize` saves the current dimensions and coordinates that are not updated by `MoveResizeTo`._
