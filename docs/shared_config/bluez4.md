
# bluez4

In some cases installing bluez5 may not be an option.  For those cases I have included a limited set of bluez4 instructions.

You will need to install these packages:

- bluez
- bluez-utils
- bluez-tools
- bluez-hcidump (for debugging)
- rfkill

Start by making sure your bluetooth adapter is functioning.  You can check usb devices with `lsusb` and if you see one with `hci` after it then you are good.  You can further inspect the device with `hciconfig` to display available adapters, and `hciconfig up` to up a device (generally `hci0`).

If you are still having trouble the `rfkill` tool can be used to block and unblock bluetooth adapters, make sure no hard or soft block is on them.

Finally, to connect a device you will need to run `hcitool scan`, then using the mac address it finds you can run `bluez-simple-agent hci0 ##:##:##:##:##` to request a connection to that device (swapping `hci0` with your hci device name).

For non-input devices you may receive a passkey to enter, if you are connecting a keyboard you may receive no passkey and be given an input prompt.  For those scenarios you enter a passkey of your choosing, then do the same from the remote device to authorize it.

To finish connecting the device you have to run `bluez-test-device trusted ##:##:##:##:## yes` to trust the device going forward, and then `bluez-test-input connect ##:##:##:##:##`.

**After rebooting your system the device may require a keystroke to wake the device and a few seconds to reconnect.**


##### commands

_Install the packages:_

    aptitude install bluez bluez-utils bluez-tools bluez-hcidump rfkill

_Start bluetooth service:_



_Unblock & up the adapter (assumes hci0 is bluetooth device):_

    rfkill
    hciconfig up hci0


