
# Debian Wheezy Template Documentation
#### Updated 2-19-2014

I use these template instructions to prepare a virtual machine template which can be used for basic cloning when I need a fresh test system.

Having a documented default or "base" install can greatly reduce room for error when setting up new machines, as well as expedite the setup process.


### Hardware Configuration

Applications vary wildly, but this machine will run sufficiently on 512MB of RAM, but I tend to use 1GB or more.


#### Ideal Partitioning & Installation

I use Logical Volumes for my partitioning, and I always create partitions for error-prone areas like the logs.  This is purely a preventative step such that I never end up with a machine that I cannot even debug due to having no available drive space.

Logical Volumes provide you with a great deal of additional flexibility, and are compatible with pretty much every linux distribution.  Dynamically expanding and shrinking volumes, and paths that do not change based on the order the drive is connected in.  They can span multiple disks, or even handle a portion of RAID if needed.  If you have to reinstall you can do so without wiping your home directory.  Also you have a quick and easy way to backup each partition.

However, keep in mind that the root partition cannot be resized on the fly (or at the very least cannot _easily_ be resized on the fly), so it is best to allot the amount you will need for that up front, plus a margin-of-error (eg. if you expect to need 8GB assign 12GB).  I can say that a minimalist GUI and complete OS tend to take less than 6GB of space on root, but that will vary by packages installed, and can quickly escalate.

I try to keep my templates limited to 20GB of space, which should give you plenty of room to work with for starters, and is easier to backup and restore at that size.

Here is a break-down of my partitioning scheme:

- 512MB PC-Grub/EFI Partition
- 512MB ext4 /boot
- Remainder to Volume Group
    - VG Name "debian"
        - 2GB swap
        - 8GB root /
        - 512MB log /var/log
        - 512MB tmp /tmp
        - Remainder home /home (8GB)

I also only ever install `system utilities` from the package options, this is primarily because when running the install off of the disk things work much slower.  If you want to install other packages you can use debconf post-install.

I don't always use a desktop environment so I save those things for later.  I also don't use every application that the gnome3 base packages come with, and prefer a minimalist installation to save space.

Because I modify the dot files heavily I also tend to avoid creating any other users besides root.  This allows me to add utilities and create dot files in `/etc/skel` before creating a user, at which point they automatically get all the new files which saves me some typing.


### Post Installation Steps

Start by logging in as root to run through these steps.

#### Packages

I install lots of packages to form the basic foundation of a multi-functional platform.  In some cases not all of these packages are necessary, but in most cases they are helpful to have.  Worth noting that I use `aptitude` because it is a single sensible command interface, and for these packages I add the `-r` flag to install any recommended packages.  If you want to go full minimalist then omit this flag and pick and choose the packages to install.  However I recommend this to avoid any possibly problems later on.

The first task I perform is I install the `netselect-apt` package, which allows us to detect the best mirrors available and set our sources to them.

By default debian comes with `vim-tiny` which creates a `vi` symlink that I've found at times does **not** get replaced when the complete `vim` package is installed.  To avoid problems with accidentally launching the tiny version I remove `vim-common` and `vim-tiny` packages.

Moving onto our big install list; I've sectioned all the packages into groups that make some sense as far as their purpose on the machine, which may help you decide whether to install them yourself.

**Firmware:**

- firmware-linux
- firmware-linux-free
- firmware-linux-nonfree

You may or may not find any of these to be of help, but if you want to ensure that no hardware you connect is unsupported this is a good first step.  If you never plan to swap parts or connect new hardware, feel free to omit these.

**Hardware Utilities:**

- usbutils
- uuid-runtime
- debconf-utils
- cpufrequtils

I install these packages as support tools for various hardware and software that interacts with hardware.  I recommend all of them.

**Compression Utilities:**

- bzip2
- lzop
- p7zip-full
- zip
- unzip
- unrar
- xz-utils
- unace
- rzip
- unalz
- zoo
- arj

I have listed these packages in the order I find them to be useful.  You are welcome to omit some or all of them if you do not expect to encounter compressed files.

**Network Utilities:**

- netselect-apt
- ssh
- curl
- ntp
- rsync
- whois

As earlier instructed, we should already have `netselect-apt` installed to reduce the load of installing all the remaining packages.  I highly recommend `ssh`, `ntp`, and `curl` as they are all incredibly valuable to have on your system, while `rsync` is a bonus, and `whois` may or may not be of any use to you depending on your intended use of the machine.

**Development Support Utilities:**

- git
- git-flow
- mercurial
- debhelper
- libncurses5-dev
- kernel-package
- build-essential
- fakeroot

The `git` and `mercurial` packages are for popular version control software.  If you use `svn` you can throw that in too.  The last four will install all the necessary tools to build and compile source code, such as a custom kernel, or any software you cannot find in a debian package.

**Text Processing Utilities:**

- vim

The `vim` package is my preferred terminal editor, but there are others such as `nano` and `emacs`.  Your choice will depend on your preferences, and I'd imagine that depends on whichever you have more experience with.

**File System Utilities:**

- e2fsprogs
- parted
- sshfs
- fuse-utils
- gvfs-fuse
- exfat-fuse
- exfat-utils
- fusesmb
- os-prober

I use `parted` regularly, and `e2fsprogs` as well.  The `sshfs` package makes it much easier to secure direct local access to a set of remote files, and all of the fuse packages are excellent if you need to access special file systems such as example samba and exfat.  The `os-prober` package may help if you are troubleshooting drives or partitions.  If you don't plan to be accessing other file systems, then you don't need all of them, but I use them myself, and often.

**Terminal Support Utilities:**

- sudo
- bash-completion
- command-not-found
- tmux
- screen
- bc
- less
- keychain
- pastebinit
- anacron

I would be at a loss without tools like `tmux` and `screen`.  I find that `bash-completion` and `command-not-found` are fabulous tools to improve my productivity and help me locate things I missed.  The `sudo` command is basically required if you plan to use the system as a non-root user and still maintain easy privilege access.  The `bc` and `less` commands should already be installed and help with text processing and basic calculations.  The `anacron` package is for an asynchronous crontab, great for desktops which do not have a 24/7 uptime (for example, a virtual machine).  The `keychain` package is super helpful to load your ssh key at boot time so you don't have to constantly enter the password for it as you use the system (accessibility vs security).  Finally `pastebinit` is a website specific utility that allows you to easily push output to a public website to share with others, such as troubleshooting or even accessing it from another system.  I recommend all of these tools.

**Misc Utilities:**

- miscfiles
- monit
- markdown

The `miscfiles` package is non-executable files that contain loads of data that other software may find helpful, so I recommend it.  I use `markdown` for literally everything, so I install it.  The `monit` package allows me to specifically monitor important services and keep them from locking up or crashing permanently.

After installing the packages we still have a couple of steps to take care of before we are ready to move forward.  The `command-not-found` package requires a one-time run of `update-command-not-found` to update a local index of packages.


##### Commands

_Here are the all the commands I run to cover the entire packages section of documentation:_

    aptitude install -r -y netselect-apt
    netselect-apt -s -n
    aptitude clean
    aptitude update
    dpkg -r vim-common vim-tiny
    aptitude reinstall -r -y firmware-linux firmware-linux-free firmware-linux-nonfree usbutils uuid-runtime debconf-utils cpufrequtils bzip2 lzop p7zip-full zip unzip unrar xz-utils unace rzip unalz zoo arj netselect-apt ssh curl ntp rsync whois vim git git-flow mercurial debhelper libncurses5-dev kernel-package build-essential fakeroot e2fsprogs parted sshfs fuse-utils gvfs-fuse exfat-fuse exfat-utils fusesmb os-prober sudo bash-completion command-not-found tmux screen bc less keychain pastebinit anacron miscfiles monit markdown
    aptitude install -r -y firmware-linux firmware-linux-free firmware-linux-nonfree usbutils uuid-runtime debconf-utils cpufrequtils bzip2 lzop p7zip-full zip unzip unrar xz-utils unace rzip unalz zoo arj netselect-apt ssh curl ntp rsync whois vim git git-flow mercurial debhelper libncurses5-dev kernel-package build-essential fakeroot e2fsprogs parted sshfs fuse-utils gvfs-fuse exfat-fuse exfat-utils fusesmb os-prober sudo bash-completion command-not-found tmux screen bc less keychain pastebinit anacron miscfiles monit markdown
    update-command-not-found


#### Cron Jobs

I schedule a series of custom cronjobs to handle various tasks within the system that keep it up the date and running smoothly.  Generally I only add these to the primary cron folders, but that means they may not execute if the system is not running 24/7, so be sure to adjust your implementation accordingly.

I create a file in `/etc/cron.monthly/` that re-runs `netselect-apt` to ensure we still have the best mirrors available.

I create three files in `/etc/cron.weekly/`, including one to update our packages, one to defragment any ext4 partitions, and one to execute `fstrim` on any ext4 partitions (useful for solid state drives).



##### Commands & Files

_Starting with the files and their contents:_

**`/etc/cron.monthly/netselect-apt`:**

    #!/bin/bash

    # Update package mirrors
    netselect-apt -s -n
    aptitude clean
    aptitude update

**`/etc/cron.weekly/aptitude`:**

    #!/bin/sh

    # update packages weekly
    aptitude clean
    aptitude update
    aptitude upgrade -y
    update-command-not-found

**`/etc/cron.weekly/e4defrag`:**

    #!/bin/sh

    # defragment ext4 devices
    for DEVICE in $(mount | grep ext4 | awk '{print $1}')
    do
        e4defrag "${DEVICE}"
    done

**`/etc/cron.weekly/fstrim`:**

    #!/bin/bash

    # Handle regular trim cleanup (much less IO problems than setting discard flag in fstab)
    for DEVICE in $(mount | grep ext4 | grep -v mapper | awk '{print $1}')
    do
        fstrim "${DEVICE}"
    done

_Now I make sure all of them are executable:_

    chmod +x /etc/cron.monthly/netselect-apt
    chmod +x /etc/cron.weekly/aptitude
    chmod +x /etc/cron.weekly/e4defrag
    chmod +x /etc/cron.weekly/fstrim



#### Optimizations & Permissions

This optimization is for LVM with Solid State Drives.  In the `/etc/lvm/lvm.conf` file find the `issue_discards` flag, and set it to `1` to turn it on.

Next I prefer setting the default umask to `002` to allow group read and write by default.  This used to be a problem because users did not have personal groups, but that has long since been addressed and every user is in their own group by default, making it hard to "accidentally" share files.

To make these change we have to modify two files.  First we want to add `session optional pam_umask.so umask=002` to `/etc/pam.d/common-session`.  Second we want to set `UMASK 002` inside `/etc/login.defs`.


##### Commands

_The commands to make these optimizations:_

    sed -i 's/issue_discards = 0/issue_discards = 1/' /etc/lvm/lvm.conf
    sed -i 's/UMASK\s*022/UMASK        002/' /etc/login.defs
    echo "session optional pam_umask.so umask=002" >> /etc/pam.d/common-session


#### Monit Configuration

At a bare minimum monit allows us to ensure that if the system is overloaded or important services such as ssh hangs or dies that it gets rebooted.  It is a very reliable tool and good to have installed for general purpose use.

Configurations should be placed into `/etc/monit/monitrc.d/`, and symlinked to `/etc/monit/conf.d/`.

I create one for `ssh`, one for `system`, and one for `web` accessibility by default.  The configuration you choose may vary greatly, and I recommend [reading their documentation](https://mmonit.com/monit/documentation/monit.html) before simply copying my own suggested contents.


##### Commands & Files

_Let's start by creating these files:_

**`/etc/monit/monitrc.d/ssh`:**

    check process sshd with pidfile /var/run/sshd.pid
        start program = "/etc/init.d/ssh start"
        stop program  = "/etc/init.d/ssh stop"
        if cpu > 80% for 5 cycles then restart
        if totalmem > 200.00 MB for 5 cycles then restart
        if 3 restarts within 8 cycles then timeout


**`/etc/monit/monitrc.d/system`:**

    check system localhost
        if loadavg (1min) > 10 then alert
        if loadavg (5min) > 8 then alert
        if memory usage > 80% then alert
        if cpu usage (user) > 70% for 2 cycles then alert
        if cpu usage (system) > 50% for 2 cycles then alert
        if cpu usage (wait) > 50% for 2 cycles then alert
        if loadavg (1min) > 20 for 3 cycles then exec "/sbin/reboot"
        if loadavg (5min) > 15 for 5 cycles then exec "/sbin/reboot"
        if memory usage > 97% for 3 cycles then exec "/sbin/reboot"

**`/etc/monit/monitrc.d/web`:**

    # Establish Web Server on a custom port and restrict access to localhost
    set httpd port ####
        allow 127.0.0.1

_Be sure to substitute the port number of your choice with `####` in the above configuration.  Then you can securely access it using ssh tunneling: `ssh -f -N username@remote_ip -L ####:localhost:####`_

_Finally, we run these commands to add symlinks

    cd /etc/monit/conf.d
    ln -s ../monitrc.d/ssh ssh
    ln -s ../monitrc.d/system system
    ln -s ../monitrc.d/web web

_You can then test, and restart monit:_

    monit -t
    service monit restart


#### Domain Name

If you did not do so during the installation, you can setup a fully established domain name by adding the machine name to the file `/etc/hostname`, then running `hostname -F /etc/hostname`.

To add the domain name you can edit `/etc/hosts` and add a record for `127.0.1.1` with your hostname, and fully qualified domain name.


##### Commands

_To add a hostname and FQDN, here are the commands:_

    echo "hostname" > /etc/hostname
    hostname -F /etc/hostname

_Edit the `/etc/hosts` file manually, and add or replace this line:_

    127.0.1.1 hostname.domain.dev hostname

_Now if we type `hostname -f` we will get the whole domain name._


#### Static IP

On most of my desktop systems inside a local network I assign a static IP.  I do this to make SSH access simpler, and to reduce routing traffic.

These instructions are primarily for wired connections and may require significant changes to be useful for wireless connections.


##### Commands

_Edit the `/etc/network/interfaces` file by replacing or adding these lines:_

    allow-hotplug eth0
    iface eth0 inet static
        address 10.0.5.8
        netmask 255.255.255.0

_Your network device name, and address are dependent on your system and intranet._


#### SSH Configuration

The first step I take to securing SSH is to obfuscate the port by changing it to a different number in `/etc/ssh/sshd_config`.

Next it would be wise to add any keys to `~/.ssh/authorized_keys` under a user account (generally not under the root account), and prevent access via passwords.  To do this set `PasswordAuthentication no` inside `/etc/ssh/sshd_config`.  If you use [github](https://github.com/), you can use `curl` or `wget` to grab your accounts trusted public keys from terminal.

If you don't use `sudo` often, you can further lock down accounts by preventing password logins and authentication in general via `passwd -l username`.  This can have unexpected consequences, but is another way to limit password authentication.

Finally, preventing root login is usually a good move, set `PermitRootLogin no` in `/etc/ssh/sshd_config`.

**Be sure to reboot or restart the ssh service for these changes to take affect.**

You should also generate an SSH key for your user account.  _Passwordless keys are as insecure as automatically loading your key, so for greater security it is advisable to use a key with a password, and not to automatically load it._  However, I often use the `keychain` package to automatically load my keys into the ssh-agent if I am not concerned about the security of the account or need it for automation of some sort.

You can also add a generated key to your github account via their api using curl.

_Don't forget a space in front to prevent it from showing in your `history` (since it has username & password)._


##### Commands

_These commands will secure your ssh service:_

    sed -i "s/Port\s*[0-9].*/Port ####/" /etc/ssh/sshd_config
    sed -i "s/^#\?PasswordAuthentication\s*[yn].*/PasswordAuthentication no/" /etc/ssh/sshd_config
    sed -i "s/^#\?PermitRootLogin.*[yn].*/PermitRootLogin no/" /etc/ssh/sshd_config
    service ssh restart

_Be sure to replace `####` with a port number of your choosing.  This number will also be important for a later step._

_These commands will grab your trusted keys off the net, and add your newly generated public key to your account (**swap your username and password, and be sure to clear your `history` after**)._

    curl -o ~/.ssh/authorized_keys "https://github.com/username.keys"
    curl -i -u "username:password" -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"title\":\"name this key\",\"key\":\"$(cat ~/.ssh/id_rsa.pub)\"}' https://api.github.com/user/keys

_To generate an ssh key, here is the command (prompts will be required after):_

    ssh-keygen -t rsa -b 4096


#### Firewall via IPTables

The `iptables` package makes for an excellent firewall.  However, its configuration can be quite confusing.  I recommend reading up on it if you want a solid understanding.

I usually create a set of rules in `/etc/firewall.conf`, though some services would have you place it into `/etc/iptables/iptables.rules` and auto-load it by default.  However, I do not use the iptables daemon, instead I connect them to my `network up` sequence by creating a file in `/etc/network/if-up.d/` to reload the iptable rules.


##### Commands & Files

_Let's start by creating our IPTables file in `/etc/firewall.conf`:_

    *filter

    -P INPUT DROP
    -P OUTPUT ACCEPT
    -P FORWARD ACCEPT

    # Allow traffic for INPUT, OUTPUT on loopback
    # address interface.
    -A INPUT -i lo -j ACCEPT
    -A OUTPUT -o lo -j ACCEPT

    # Allow Pings
    -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

    # Allow SSH with rate limiting
    -A INPUT -p tcp -m tcp --dport ssh -m conntrack --ctstate NEW -m recent --set --name DEFAULT --rsource
    -N LOG_AND_DROP
    -A INPUT -p tcp -m tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 --name DEFAULT --rsource -j LOG_AND_DROP
    -A INPUT -p tcp -m tcp --dport ssh -m state --state NEW -m recent --update --seconds 60 --hitcount 4 --name DEFAULT --rsource -j LOG_AND_DROP
    -A INPUT -p tcp -m tcp --dport ssh -j ACCEPT
    -A LOG_AND_DROP -j LOG --log-prefix "iptables deny: " --log-level 7
    -A LOG_AND_DROP -j DROP

    # Continue to allow established connections
    -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    COMMIT

_Remember that the `ssh` port number varies and the string evaluates to port 22 (the default)._

_Next let's create our file `/etc/network/if-up.d/iptables` with loading code:_

    #!/bin/bash
    iptables-restore < /etc/firewall.conf

_Finally, we need to make the iptables script executable:_

    chmod +x /etc/network/if-up.d/iptables


#### Locale Support

If you happen to dabble in other languages besides english (as I'm sure do many), then you can add another locale and generate related files.

The interactive way to do this is to use `dpkg-reconfigure locales`.  This will let you pick the options from an ncurses gui.

If you want to make it happen manually instead you can modify the `/etc/locale.gen` file, by removing comments next to the locale of your choice, then running `locale-gen`.


##### Commands

_I usually add japanese locale for language support:_

    echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen


#### Creating a User

**Before creating a new user I highly recommend preparing your system for new users with my [dot-files repository](https://github.com/cdelorme/dot-files), which contains a number of prompt enhancements, vim plugins and configuration, and numerous user-configuration defaults that improve overall performance.**

Provided all the configuration files you desire are in the `/etc/skel/` path, you can proceed with creating a new user.  I do so using the `useradd` command, but if you prefer an interactive approach then the `adduser` perl script should do nicely.

After adding a user you will want to set their password with `passwd username`.  Also, don't forget to add your user to appropriate groups, such as the `sudo` group.


##### Commands

_Here is how I create my new users:_

    useradd -m -s /bin/bash username
    passwd username
    usermod -aG sudo username
