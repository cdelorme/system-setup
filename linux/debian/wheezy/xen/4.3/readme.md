
# Xen 4.3 ReadMe

I use Xen extensively as a primary control system.  This allows me to treat my single computer as several independently functioning machines.

Besides a segregation of duty I also get a significantly cleaner environment.

The primary objectives of this system are for it to be a clean and exceptionally functional platform with some degree of security precautions.

---

The documented procedure is quite long, having been known to take upwards of two days to perform.

If you would like to simplify the process, the script will take you from a fresh install of Debian Wheezy to a fully configured and ready to execute Xen server.

Here are the instructions for execution:

    aptitude install git
    mkdir -p /home/src
    cd /home/src
    git clone https://github.com/CDeLorme/system-setup.git
    cd system-setup/linux/debian/wheezy/xen/4.3/

You will want to modify the `xen-config` file first, but afterwards simply execute `./xen.sh` and you should be off to the races (if over ssh do so from screen or tmux in case of disconnection).

The xen-config file is mostly self-documenting, but if anything is questionable bring it to my attention in the github issue tracker and I will clarify it.

