
# logitech k810

I use a logitech k810 bluetooth keyboard, because it's an awsome small form-factor chiclet style keyboard with multimedia keys, excellent functionality, and best of all up to three bluetooth connections can be saved.

As the owner of several consoles and computers, this is a hugely beneficial feature (I still wish it were possible to have an infinite number, but 3 is a great start).

In any event, connecting it via bluetoothctl was super easy, but the problem is configurability is at a limit.  The keyboards multimedia keys make working it a pain sometimes, because I use the function keys as function keys usually.  Fortunately [I was not the only, nor the first](http://www.trial-n-error.de/posts/2012/12/31/logitech-k810-keyboard-configurator/), and they already fixed it by creating a small C program to augment the keycode for this keyboard.

Build it, test it, create a shell script to run it, add them to `/usr/local/bin`, then add a udev rule so when it connects it automatically runs, and everything is golden.
