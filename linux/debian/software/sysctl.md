
# sysctl

Apparently the kernel now prints warnings about devices into the console.

This will even be printed to the console before a login.

The only documented way to deal with this is to add `kernel.printk = 3 4 1 3` to `/etc/sysctl.conf`, _but this comes at the cost of not seeing potentially important warnings in the console when needed._
