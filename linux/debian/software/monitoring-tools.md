
# monitoring tools

There are plenty of tools you can add to monitor traffic.  These are mostly useful when you run into trouble and need to identify the cause.

For more advanced monitoring than `top` try `htop`.

For more detailed CPU information try `cpufrequtils`.

If you want to check HDD temperatures then `hddtemp` is fantastic.

For rudimentary benchmarking you may like `hdparm`.

For active network monitoring try these:

- `nload`
- `iptraf`
- `nethogs`

If you want to copy data while monitoring the progress you can use `pv`.

For hard drive management and safety the `smartmontools` package can be very useful.

With the right hardware or by loading the `softdog` module, the `watchdog` package can help recover your system by rebooting when various problems occur.  _Having used tools like `monit` which has since been replaced by `systemd`, I find this to be less helpful generally unless you are running a server._
