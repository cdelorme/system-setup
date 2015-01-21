
# template

These are template instructions, including initial installation, that will prepare a base image.  That image is ready for use as a server, workstation, development machine, etc.  It's intended use is to be a "starting point", by making the system more usable from the start.


## installation

Applications vary wildly, but this machine will run sufficiently on 512MB of RAM, but I tend to use 1GB or more.

I don't create an additional user besides the root account during the initial installation.

I use Logical Volumes for partitioning.  My **preferred partitioning schema** [is in my parted documentation](../shared/parted.md)

For a lightweight installation I only select `system utilities` and deselect the desktop environment and any other combined packages.


### packages

Since this is just a templte system that should extend to fit many use cases my goal is to limit installed utilities to utilities and services that are important in all cases, or which improve usability.

To speed up package installation I generally install `netselect-apt` first and attempt to determine the best mirrors.  _Due to a bug that can yield "-" as a mirror, this is not always reliable._  Either way, this is one package in my list:

- netselect-apt

Of course, following the `netselect-apt` execution I would move onto the rest of the packages.  The lightweight set of utilities I install includes the following:

- screen
- tmux
- vim
- git
- mercurial
- bzr
- subversion
- command-not-found
- bash-completion
- unzip
- monit
- ntp
- resolvconf
- watchdog
- ssh
- sudo
- whois
- rsync
- curl
- e2fsprogs
- parted
- os-prober
- smartmontools

While debian comes with some of these, some are not included by default, and all of them are very useful regardless of the final intended purpose of your system.  All systems should have basic version control; at least the four core (`bazaar`, `subversion`, `git`, and `mercural`).  A good set of network utilities like `rsync`, `curl`, and `whois` are pretty commonly useful.

While I aim for a lightweight system, too often I find that recommended packages are actually very necessary to do many of the things I had intended.  To avoid problems with missing dependencies in a deep path I always include the `-r` flag for automatically adding recommended packages to the install list.


## cron jobs

I generally prepare few cron jobs to automate updates and general maintenance:

- [daily system updates](../../data/etc/cron.daily/system-updates)
- [weekly disk maintenance](../../data/etc/cron.weekly/disk-maintenance)

_If there is any reason you cannot run updates on a stable distro then you should use the `hold` command on key pacakges._


## optimizations & permissions

This optimization is for LVM with Solid State Drives.  In the `/etc/lvm/lvm.conf` file find the `issue_discards` flag, and set it to `1` to turn it on.

Next I prefer setting the default umask to `002` to allow group read and write by default.  This used to be a problem because users did not have personal groups, but that has long since been addressed and every user is in their own group by default, making it hard to "accidentally" share files.

To make these change we have to modify two files.  First we want to add `session optional pam_umask.so umask=002` to `/etc/pam.d/common-session`.  Second we want to set `UMASK 002` inside `/etc/login.defs`.


## monit configuration

At a bare minimum monit allows us to ensure that if the system is overloaded or important services such as ssh hangs or dies that it gets rebooted.  It is a very reliable tool and good to have installed for general purpose use.

Configurations should be placed into `/etc/monit/monitrc.d/`, and symlinked to `/etc/monit/conf.d/`.  This allows you to easily disable or enable services.

I create one for `ssh`, one for `system`, and one for `web` accessibility by default.  The configuration you choose may vary greatly, and I recommend [reading their documentation](https://mmonit.com/monit/documentation/monit.html) before simply copying my own suggested contents.

To use the command line `monit status` an httpd configuration must be added.


## system timezone

If you run `date` and the system spits out a time from a different timezone it is very likely that you will have to fix it by replacing the file at `/etc/localtime` with a file containing your own timezone signature.

You can find the list of timezones in `/usr/share/zoneinfo`.


## domain name

If you did not do so during the installation, you can setup a fully established domain name by adding the machine name to the file `/etc/hostname`, then running `hostname -F /etc/hostname`.

To add the domain name you can edit `/etc/hosts` and add a record for `127.0.1.1` with your hostname, and fully qualified domain name.


## fixing grub panics

Sometimes there are problems and a kernel panic happens.  While rare, this can be a huge problem if the system is remote, so I add another flag to attempt to tell the system to automatically reboot shortly after a panic.

To do this, we want to add a configuration change to grub!


## creating a new user

I highly recommend using a [dot-files](https://github.com/cdelorme/dot-files) package, as this can greatly enhance your overall linux terminal experience and productivity.

Creating a new user is fairly straitforward, it will grab any default files from `/etc/skel` and put them into your new user home path.  There are two regularly used commands, the `adduser` command runs a perl script that acts as an interactive wrapper around the `useradd` command, which is the command I recommend.

Simply creating the user is not enough, you will need to set their password or they will be unable to login, or run the `sudo` command if they happen to be a super-user.

It is generally a good idea to generate an ssh key for your user.  Adding that key to something like github can be very beneficial as well.


## ssh configuration

If the system is publicly accessible (has a public ip) the first step I take is generally to obfuscate the ssh port to something non-standard.

My next step is adding all of my public keys to `~/.ssh/authorized_keys`.  I actually have a [script](../../data/home/.bin/update-keys) that I keep in my users crontab to keep this updated.

With trusted keys added manually the first time, I am now able to disable password based logins on that system, by setting `PasswordAuthentication no` inside `/etc/ssh/ssh_config`.

_It is also possible to lock down accounts completely by using `passwd -l username`, preventing anyone but root from logging in as that user._  This can have unexpected consequences and isn't really advisable in _most_ circumstances.

Finally, preventing root login is usually a good move, set `PermitRootLogin no` in `/etc/ssh/sshd_config`.  Nobody should have the root password, and handing out root keys to a system **should** feel bad and wrong.

**Be sure to reboot or restart the ssh service for these changes to take affect.**

_If you have `export HISTCONTROL=ignoreboth` in your `~/.bashrc` then adding a space before typing a command will omit it from your history, allowing you to run sensative information without clearing the entire history._


## [iptables](../../data/etc/iptables/iptables.rules)

You can use `iptables` to create a very secure firewall on a system, however it can be a bit confusing.  I recommend doing some reading if you want a solid understanding of how it works.

A good standardized location to place your configuration file is `/etc/iptables/iptables.rules`.  You will want to create a script to load them in `/etc/network/if-up.d` to restore the iptables rules at boot time or when the network device is reset.

The standard location for iptables configuration is `/etc/iptables/iptables.rules`, though unless you have installed additional utilities the directory will likely not exist.
I usually create a set of rules in `/etc/firewall.conf`, though some services would have you place it into `/etc/iptables/iptables.rules` and auto-load it by default.  However, I do not use the iptables daemon, instead I connect them to my `network up` sequence by creating a file in `/etc/network/if-up.d/` to reload the iptable rules.


## adding a locale

If you happen to dabble in other languages besides english (as I'm sure many do), then you can add another locale and generate related files.

The interactive way to do this is to use `dpkg-reconfigure locales`.  This will let you pick the options from an ncurses gui.

If you want to make it happen manually instead you can modify the `/etc/locale.gen` file, by removing comments next to the locale of your choice, then running `locale-gen`.


## watchdog

The watchdog is a hardware (or sometimes software) timer that runs behind the OS (such that the implementation is not dependent on the OS).  This allows it to perform a status check and take action if and when the OS ceases to respond.  This makes it useful for automatically rebooting a system when it encounters an unrecoverable error.

To my understanding when a system supports watchdog it will have a device-file at `/dev/watchdog`.  If you open this device-file and do not provide it with data within 60 seconds, or do not close it properly, the system will reboot.  You can easily test it by typing a simple echo into the file.  To my knowledge, you can cancel the watchdog by echoing a "V" into the device-file.

Finally, you will want to install the `watchdog` package, and tell it to run at boot time.  It's job is to ping the `/dev/watchdog` file with data within every 60 seconds to keep the watchdog from rebooting while the system remains responsive.  You may also need to compile watchdog support into your kernel.

**The `watchdog` package can be used for much more than just a watchdog timer, but also a system monitor, similar to monit but more limited in scope.**


## log accessibility

While securing your logs is important, if a user needs to debug a problem and cannot access them, or if it's just inconvenient to type sudo for every attempt to access the log files you may want to consider some minor modifications.

The default user group for log files found in `/var/log` is `adm`.  **Some files are more important and will not have that group for permissions**, but a majority will.

So the quick and dirty solution is to add your privileged users to the `adm` group.  For log files that are not owned by `adm`, be sure to check the configuration files in `/etc/logrotate.d`.  The following rotate scripts are not owned by `adm`:

- `dpkg`
- `apt`
- `aptitude`

_In some cases you will need to add the `create` line, not simply modify it._

There are some packages that do not use or come with logrotate configurations, which can make it more difficult to work around this.  **Awareness is valuable.**


## references

- [iptables securing ssh](http://www.rackaid.com/blog/how-to-block-ssh-brute-force-attacks/)
- [best practices 2010: "Don’t set the default policy to DROP"](http://major.io/2010/04/12/best-practices-iptables/)
- [reject > drop](http://unix.stackexchange.com/questions/109459/is-it-better-to-set-j-reject-or-j-drop-in-iptables)
- [reject & drop equally susceptable to DoS](http://www.linuxquestions.org/questions/linux-security-4/drop-vs-reject-685942/)
- [debian WhereIsIt reference doc](https://wiki.debian.org/WhereIsIt)
