
# dpi

This is not an OS specific concept, but how each OS handles it is important.

## osx

One of the smarter OS's with DPI and has been applying specific customizations since they released the iPhone.  These same customizations to DPI are how Retina displays don't make everything super tiny.


## linux

_I have not experienced any dpi related settings or situations yet with linux, and cannot speak towards it._


## [windows](https://www.youtube.com/watch?v=wGSKmy3JUns)

Windows has had DPI settings even back in XP, but it has not attempted to automate them ever.

The setting worked great, by rendering things at larger scale.  This is what made it possible to use an HDTV properly.

Windows 8.1 Super Sketchy DPI problems, and the header links to a demonstration of them:

I continue to experience erratic behavior with my DPI in Windows 8.1

They decided that the operating system can make a better decision than the user, and as a result it creates all kinds of hassle's for me.

The problem I encountered was that even after setting the desktop screen size to "Smaller", which should equal 96dpi or 100% size, every few reboots one of my two monitors (in extended display) would have extra large context menus on the desktop but totally normal menus on the taskbar.

So, the settings for DPI are now 3-fold, 1 obvious, 2 hidden:

- Settings from Personalize/Display
- From "PC Settings" in Metro to `PC & Devices` > `Display` > More Options (may have to scroll) select "Smaller" or "Default".
- Registry Editor (If erratic behavior begins go to the source right?) under anyplace you find a `Control Panel` > `Desktop` make sure the `LogPixels` DWord is set to 96 (Decimal) and `Win8DpiScaling` DWord is set to 1.

Without the regedit changes I found that I would erratically get a single screen showing a large context menu and properties windows.  When duplicated it would apply to both screens, and that's a real nuisance.  Anyways I may want to create a short video to demonstrate it (provided my changes hold the test of time).

Known Locations:

- Your account (probably has the correct settings in config): `[HKEY_CURRENT_USER/Control Panel/Desktop]`
- Some set of unknowns that I think are causing the problem and may be missing the DWords: `[HKEY_USERS/*/Control Panel/Desktop]`
