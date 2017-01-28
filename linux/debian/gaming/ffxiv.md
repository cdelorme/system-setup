
# ffxiv arr

The latest iterations of wine in playonlinux run ffxiv arr just fine.

Here is what I verified:

- installer works
- client / updater works
- game runs and is playable even with high settings
- full-screen works
- **controller is recognized, but incorrectly mapped and unusable for gameplay**


## installation

I initially followed [the latest guide](https://appdb.winehq.org/objectManager.php?sClass=version&iId=28853), but there was a newer wine (`1.8-rc2`), and I found that `winhttp` and `wininet` were borked and I had to use `built-in first` from winecfg (I believe I could have omitted them).


## problems

Two problems encountered:

- first-login security issues
- xboxdrv & xbox360 wireless & wired controllers did not work


First login was met with:

	Based upon recent suspicious activity, we have identified that your account may potentially be at risk. For your protection, we have temporarily suspended login access to this account.
	Instructions for lifting this restriction have been sent to the email address registered to your Square Enix Account.
	For more information about the login restriction, please refer to the following page:
	http://support.na.square-enix.com/j/lbna

_I assume that logging in from a linux host caused this._  Amusingly I had literally just reset earlier that day, so this will probably be a regular problem when logging in since SE sucks dicks.


**While the controller is detected, it does not work.**

It sees both an event and js controller (eg. /dev/input/eventX and /dev/input/jsX).  I can select either, and both send input.

The mapping is super odd, start and select map to the LB/RB, besides the dpad none of the axis's work (eg. not even detected at all, LT/RT and both joysticks).

The A,B,X,Y are inverted and flipped, such that X was confirm and Y was cancel, so navigation through the menu was possible.

The joystick buttons R3/L3 mapped to back & R3 respectively (very strange).

So far I have tried:

- switching to xpad and back to xboxdrv
- rebooting, numerous times
- installing `dinput` and attempting to install `xinput`
	- xinput fails to install
	- both prevented controllers from even being detected
		- to regain controller detection I changed them back to `builtin` from `winecfg`
- some janky 3rd party tool called x360ce, which did not work whatsoever
- opening `control` in wine and verifying the controller there
- building the latest xboxdrv (1.8.8) and upgrading from 1.8.5
- reconfiguring and force remapping xboxdrv

I saw no difference switching to `xpad` and didn't spend long using it.

I tried rebooting before switching back to `xboxdrv`, and after.

I tried installing `dinput`, and then `xinput`.  The `xinput` installer threw an error screen.  Suddenly controller detection stopped working altogether, so I unset their dll's in `winecfg`.

I spent more than a few hours playing with `x360ce`.  I tried placing the output files with every game executable, and even in `system32`.  I don't know if the problem was that the game gets launched from a client, but the controller behavior never once changed.

The joystick mapper from `control` in wine actually saw the same two devices, but it registered all the buttons and axis's/joysticks.  Therefore my conclusion is that whatever translation ffxiv is relying on is neither the same as the configuration utility and is probably incomplete.

Since I was using debian I considered that maybe I had an older `xboxdrv`, turns out they hadn't updated in nearly 2 years, even still I downloaded the very latest source and built and tried the latest with no changes.

I tried about a dozen alternative settings, and completely remapping the entire controller to see if it would work correctly, but it still behaved the same.

**It is completely impossible to play the game with the controller in the state it exists currently.**  This makes me sad, but the game running is a miracle on its own.
