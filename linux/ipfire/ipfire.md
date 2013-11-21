
# IPFire Proxy Cache Router Firewall WAP Documentation
#### Updated 11-20-2013

Things I have noted for future reference:

- Enabling Proxy/Cache
- WAP Configuration


## Enabling Proxy Cache

A proxy will eat a small amount of CPU, and cache will consume a considerable chunk of RAM when configured properly (that is the intention, not a _problem_).

However, these can both dramatically improve performance by reducing bandwidth and even completely eliminating web advertisements for all users inside your network.

Start by logging into the web interface and going to "Network".

From here you can enable the web proxy.  **If you are also creating a WAP, and using the blue/green bridge, you do not want to enable the proxy on the blue since it will be running through the green network.**

You will want to make it transparent, as in always-in-use, otherwise users have to add it with their own settings.

Further down you can enable cache management and assign both the method to handle caching, as well as RAM and hard disk space to allow for stored content.

You will want to add a whitelist of sites never to cache if you intend to allow users multimedia access, such as youtube or music services.  Here is an example of sites that you may consider adding:

- googleusercontent.com
- video.google.com
- play.google.com
- netflix.com
- nflximg.com
- youtube.com

Finally you can save and restart at the bottom, and next use the side menu to access "Content Filter".

This is where you can tell your proxy to eliminate ads among other content.  At the bottom you'll have a choice between a variety of externally maintained lists, a general purpose list such as MESD tends to be enough.

Run the updates and the list up at the top should change.  Add check boxes to whichever ones you want to block.

If you find sites that you want to access that are blocked you can add them to the custom whitelist, but remember to enable it before saving and restarting.


**Clearing the Cache on a Schedule:**

Ideally you will want to clear the cache regularly, but there is no "built-in" way to do this.

Instead you can enter the terminal and add a cron-job to `/etc/fcron.weekly` (or any other folder you'd prefer), and create a file (ex. `/etc/fcron.weekly/clean_squid`) with:

    #!/bin/sh
    squid -k shutdown
    mkdir /var/log/tmp
    mv /var/log/cache/* /var/log/tmp/
    squid
    rm -rf /var/log/tmp

Make sure to add executable rights `chmod +x /etc/fcron.weekly/clean_squid`, and you'll be all set.  Every week this job will wipe the cache, which can eliminate stale or stagnated contents from piling up.

_Probably a good idea to make sure that fcron has been set to load at boot time, in `/etc/rc.d/rc3.d/S40fcron` or similar._


## WAP Configuration

You can configure a wireless device during the installation, however you may not be given the options to create a Wireless Access Point.

To add WAP capabilities you will want to go to the web interface, and access `pakfire` and install the `hostapd` package.  This will add a WLanAP page, where you can configure the security options and logging for your WAP.

While this will give you a wireless access point, it will not lead anywhere because by default this device is separated from the "main" network.  To resolve this there are two options.

The first, and apparently more common (but completely undocumented) way is to create a DMZ Network.

However, I have chosen to follow [wiki instructions](http://wiki.ipfire.org/en/configuration/network/bridge-green-blue) to bridge blue and green networks.  I have no particular reason for them to be separated, and in fact that becomes a hindrance if I want my laptop and desktop to communicate.

We start by creating a bridge file at `/etc/init.d/bridge`:

    #!/bin/sh
    ########################################################################
    # Begin $rc_base/init.d/bridge
    #
    # Description : Skript to use more than one NIC's as green net
    #
    # Authors     : Arne Fitzenreiter - arne_f@ipfire.org
    #
    # Version     : 01.00
    #
    # Notes       :
    #
    ########################################################################

    . /etc/sysconfig/rc
    . ${rc_functions}

    case "${1}" in
        start)
            boot_mesg "Create bridge for green net..."
            # down green0
            ip link set green0 down
            # rename green0 to green1
            ip link set green0 name green1
            # create new bridge green0
            brctl addbr green0
            # wait 2 seconds because udev try to rename the nics
            # if the real green nic was added to fast...
            sleep 2
            # Add real green nic
            brctl addif green0 green1
            # Add other nic's here ...
            brctl addif green0 blue0
            # brctl addif green0 eth1
            # Bring nic's up
            ip link set green1 up
            #ip link set wlan0 up
            #ip link set eth1 up
            ;;

        stop)
            boot_mesg "Remove bridge for green net......"
            # Bring nic's down
            ip link set green1 down
            #ip link set eth1 down
            #ip link set wlan0 down
            # Bring bridge down
            ip link set green0 down
            # Delete Bridge
            brctl delbr green0
            # rename green1 to green0
            ip link set green1 name green0
            ;;
        *)
            echo "Usage: ${0} {start|stop}"
            exit 1
            ;;
    esac

    # End $rc_base/init.d/bridge

Keep in mind the bridge file must be executable:

    chmod 754 /etc/init.d/bridge

After this file has been created, we want to symlink it to ensure it loads and unloads:

    ln -s /etc/init.d/bridge /etc/rc.d/rc3.d/S19bridge
    ln -s /etc/init.d/bridge /etc/rc.d/rc0.d/K82bridge
    ln -s /etc/init.d/bridge /etc/rc.d/rc6.d/K82bridge

_Keep in mind the wiki page does not always get updated with every ipfire iteration, so this documentation may need minor tweaks now and then._
