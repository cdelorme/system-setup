
# IPFire Proxy Cache Router Firewall
#### Updated 9-29-2013

**Actual Configuration Details Are Private**

I will share some specific tips on configuration that are not a security problem.

- Enabling Proxy/Cache
- WAP Configuration


## Enabling Proxy Cache

A proxy will eat a small amount of CPU, and cache will consume a considerable chunk of RAM when configured properly.

However, these can both dramatically improve performance while reducing bandwidth and even completely eliminating web advertisements for all users inside your network.

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


## WAP Configuration

You can configure a wireless device during the installation, however you may not be given the options to create a Wireless Access Point.

To add WAP capabilities you will want to go to the web interface, and access `pakfire` and install the `hostapd` package.  This will add a WLanAP page, where you can configure the security options and logging for your WAP.

Finally, for the wireless to access internet you will want to bridge blue and green networks.  Alternatively you can try to configure a DMZ, but I have never found this to be an easy task.

You can easily bridge green and blue networks following [This Guide](http://wiki.ipfire.org/en/configuration/network/bridge-green-blue).
