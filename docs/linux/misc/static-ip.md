
# static ip

On most of my desktop systems inside a local network I assign a static IP.  I do this to make SSH access simpler, and to reduce routing traffic.  While it is possible to do from the host, it is often wiser to do so from your router with reserved-addresses.

These instructions are primarily for wired connections and may require significant changes to be useful for wireless connections.

The configuration file to address is `/etc/network/interfaces`.  By default it should have the loopback and one or more `eth#` addresses.

Configuring a static ip requires replacing the `dhcp` line with something akin to:

    iface eth0 inet static
        address 10.0.5.8
        gateway 10.0.5.1
        netmask 255.255.255.0
        dns-nameservers 10.0.5.1

Your network device name, address, and gateway will depend on your routers address range.

The use of `dns-nameservers` requires the `resolvconf` package.  With the `resolvconf` package the `/etc/resolv.conf` file will be automatically populated, which is helpful when switching between dhcp and static.
