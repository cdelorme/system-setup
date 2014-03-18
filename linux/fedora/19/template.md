
# Fedora Template
#### Updated 2013-11-20

Using my experience with Debian I have tried to mimmic the setup as closely as posible.  This is fine as the goal is a template system that can be extended, not a specific configuration for an intended purpose.

I use virtualization software and separate my configuration into four steps.

- Installation
- Naked
- Pre-Gui
- Post-Gui

The installation cannot be automated and merely defines the base on which I work from.

The naked install is a backup from that installation, and is useful if I want to start from a 100% fresh install.  For example, testing my own automation scripts.

The pre and post gui should be self-explanitory.

I may also add a fifth flavor, sugar, for developing in the sugar environment.

### Installation

The key components here are the hard drive, which I set a 20GB space for.

I use LVM for the drives, so I create a single /boot partition of 256M (or 500M), and the rest goes onto the LVM partition.

I break my LVM into:

- 1GB swap
- 500MB /tmp
- 500MB /var/log
- 8GB /
- XGB /home

The swap is plenty for most test cases, and easy to change.  The tmp and log folders are good practice simply as preventative maintenance.  If you run into space issues from log or tmp then clearly something is wrong elsewhere, but often debugging them is time consuming.

Finally I use 8GB for root, which tends to be plenty of space, and the remainder for home.


During the installation I select the Minimal no-gui option for the environment, and no checkboxes for services.

I also select from languages to add Japanese as a secondary/optional locale.


### Naked

During the install the only other thing I need to do is set a password.  The installation that finishes shortly after is my "Naked" template.

Using a service like Parallels I choose to create a snapshot, this is totally optional but helps if you need to restore to this point and save yourself the installation process.


### Pre-Gui Template

This template is intended to be for server purposes, so I install effectively all the tools I expect to be common on any working platform.

I also configure services to meet my personal expectations and/or needs.

**Here is a list of tools I install:**

- tmux
- screen
- vim
- ntp
- git
- net-tools
- mercurial
- pciutils
- virtualenvwrapper
- bpython
- p7zip
- p7zip-plugins
- japanese-bitmap-fonts

_Note that fedora does not support exfat-fuse (yet and possibly ever), so if you need exfat support stick with Debian._


**The command:**

    yum -y install tmux screen vim ntp git mercurial virtualenvwrapper bpython p7zip p7zip-plugins net-tools japanese-bitmap-fonts pciutils


**There is also group packages which we want:**

- Development Tools


**The command:**

    yum -y groupinstall "Development Tools"

_Fortunately you can also manually identify packages in a group using `yum groupinfo "name"`._

I then add a file at `/etc/cron.weekly/autoyum.sh` for automatic system updates, containing:

    yum clean all
    yum -y update


**Configuration Enhancement:**

_Add various dotfiles (`ACTUAL CONTENT PENDING`, copied from my backed up skel files)._

Note that Fedora uses firewalld by default and not iptables, so if you want to setup a firewall you will need to yum uninstall firewalld and install iptables and replace it.


**Install Global Fonts:**

We installed the package above, but we also want to create a new fonts folder for jis fonts, and add the truetype fonts in store:

    mkdir /usr/share/fonts/jis
    mv *.ttf /usr/share/fonts/jis/

Finally let's rebuild the font-cache:

    fc-cache -rf


**Install Parallels Tools:**

_Parallels Tools at first run did not work on Fedora, which was terrible and Parallels wasn't helpful, so I went ahead and patched them manually.  You can find an updated solution[here](https://github.com/CDeLorme/fedora_parallels_tools)._

Mount the cd, copy the cdrom locally to modify pre-execution.

    mkdir -p /media/cdrom
    mount /dev/sr0 /media/cdrom
    cp -R /media/cdrom /root/
    umount /media/cdrom

Replace the supplied garbage in kmods with my updated copy, and run ./install from the top level.  Then you are done


**Setup a User:**

Should automatically inherit the defined configuration files.

To do so run:

    useradd -m -s /bin/bash cdelorme
    usermod -aG wheel cdelorme
    passwd cdelorme

_The `wheel` account is the sudo account for Fedora.  Also passwd will require a password for that user._

**It is important that if the files are created in the root directory and copied, that you need to run `restorecon -R /etc/skel` before useradd.**


**Configure SSH:**

Login to the system and add my SSH key from my host.

Modify the `/etc/ssh/sshd_config` to disallow root login and password authentication:

    PermitRootLogin no
    PasswordAuthentication no

Restart ssh server and test access.


**Adjust default boot-time resolution (Parallels):**

Add these to `/etc/default/grub`:

    GRUB_GFXMODE=1024x768
    GRUB_GFXPAYLOAD_LINUX=keep
    GRUB_TERMINAL_OUTPUT=gfxterm

Then run:

    grub2-mkconfig -o /boot/grub2/grub.cfg

When you reboot you will now have a larger resolution.


That concludes the pre-gui configuration, and we can take a snapshot of this state.


### Post-Gui Template

The first step here is getting a desktop environment setup, doing this minimalist doesn't exist (I did not have time and dozens more packages than Debian).

**So run this command:**

    yum groupinstall "GNOME Desktop"

This will install 1.8GB (Over 500 packages), and when you reboot you will be able to login to a graphical environment.

Sadly, gdm won't load because we are still on multi-user.target, so let's fix that:

    rm /etc/systemd/system/default.target
    ln -s /lib/systemd/system/graphical.target /etc/systemd/system/default.target

Next we want these additional tools installed:

- guake
- gparted
- gnash
- gtk-recordmydesktop
- lsb
- libXScrnSaver

**With this command:**

    yum install guake gparted gnash gtk-recordmydesktop lsb libXScrnSaver

Add a link to start guake at boot time:

    mkdir -p ~/.config/autostart
    ln -s /usr/share/applications/guake.desktop ~/.config/autostart/guake.desktop


Let's install google chrome dev channel:

    wget --no-check-certificate https://dl.google.com/dl/linux/direct/google-chrome-unstable_current_x86_64.rpm
    rpm- i google-chrome-unstable_current_x86_64.rpm
    rm google-chrome-unstable_current_x86_64.rpm

Now let's add vlc to the mixture:

    rpm -ivh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-stable.noarch.rpm
    yum install vlc

Install sublime text:

    SAME METHOD AS DEBIAN (Except echo failed, needs testing)
    NEW URL: http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.2%20x64.tar.bz2
    Don't forget to copy over the files.


Fedora operates a bit differently, so this time I will not be adding runlevel modifications.


**Guake Configuration files for reduced transparency and increased default size should be added as well (probably to the scripted edition).  Same goes for Sublime Text configuration.**

Thus concludes the Post-GUI Configuration!


### Sugar

This is a potential final snapshot for my development purposes, allowing me to quickly roll out a development environment for sugar, with all the important tools I use.

Installed Sugar Desktop Environment via:

    yum groupinstall "Sugar Desktop Environment"

Create a git repository directory:

    mkdir ~/git

Now clone some key repositories:

    cd ~/git
    git clone https://github.com/FOSSRIT/Open-Video-chat
    git clone https://github.com/FOSSRIT/SkyTime
    git clone https://github.com/FOSSRIT/Sash
    git clone https://github.com/FOSSRIT/lemonade-stand

Reboot and verify that the option for Sugar session exists.

Shutdown and your template is set to go.
