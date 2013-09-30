
# Debian Wheezy Template
#### Updated 7-7-13

I use these template instructions to prepare a virtual machine template which can be used for basic cloning when I need a fresh test system.

Having a documented default or "base" install can greatly reduce room for error when setting up new machines.


### Known Concerns

With templates some concerns arise.  These generally tend to be re-use of configuration data, so it is imparative that you change the configuration, especially when applying it multiple times within a network.

Here is a list of other known problems:

Debian will remember network devices by mac address, and you will need to wipe out this storage inside `/etc/udev/rules.d/70-persistent-net.rules` if you intend to clone a templated installation.

**If using a virtual machine platform** such as Parallels desktop or VMWare, you may want to avoid snapshots for cloned machines, as they can consume significantly more space than the actual base system does.


### Hardware Configuration

Applications vary wildly, but this machine will run sufficiently on 1GB of memory, possibly less if you omit the GUI installation, more if you intend to run large applications.


#### Ideal Partitioning & Installation

I tend to rely on logical volumes to separate all key partitions.  This is for security and control, for example logs and temporary files are limited to 1GB of space.  An independent home volume allows for easy expansion as necessary.

However, it is important to note that expanding the root partition is difficult (or impossible) to do at run-time without a live CD.  Ideally you should set ample space for the current and all future packages you intend to install.

I generally stick to a minumum of 20GB per installation, which allows for 8-10GB for root.  An installation of debian with Gnome3 can be done with around 6GB leaving some leg room, but if you have plans to add any sizable amount of packages, such as for development, you'd be better off with more space.

Here is a break-down of my partitioning scheme:

- 256MB PC-Grub/EFI Partition
- 256MB ext4 /boot
- 120GB Volume Group
    - VG Name "xen"
        - 1GB swap
        - 8GB root /
        - 1GB log /var/log
        - 1GB tmp /tmp
        - Remainder home /home
- Remainder LVM
    - VG Name "vm"

I also only ever install `system utilities` from the package options.

At a later time I install a minimalist version of gnome3.

I also omit user creation besides root for the begining.


### Post Installation Steps

I generally install these packages on every machine:

    sudo aptitude install -y sudo ssh tmux screen vim parted ntp git mercurial p7zip-full curl bash-completion

Optional Tools:

    sudo aptitude install -y p7zip-full exfat-fuse exfat-tools

Optional Development Tools:

    sudo aptitude install -y glib-devel glibc-devel gnome-libs-devel gstream-devel gtk3-devel guichan-devel libX11-devel libmcrypt-devel qt3-devel qt-devel pythonqt-devel python-devel python3-devel pygame-devel perl-devel nodejs-devel ncurses-devel pygobject2-devel pygobject3-devel gobject-introspection-devel guichan bpython


**Establish a FQDN Hostname:**

Start by updating the hostname with this command (to automate this we would need a config option per system):

    echo "hostname" > /etc/hostname
    hostname -F /etc/hostname

_I often assign a static IP but that cannot be automated.  I do this to prevent conflicts and make it easier to know my target for SSH access or other activities._

For a fully qualified domain name we want to add two bits to `/etc/hosts`:

    127.0.1.1 hostname.domain.dev hostname

Now if we type `hostname -f` we will get the whole domain name.


**Securing SSH:**

Disabled Root SSH Access by opening `/etc/ssh/sshd_config` and finding the line below and making sure it is set to no:

    PermitRootLogin no

If you want to simplify SSH access you can add your remote or work machines public key contents to `~/.ssh/authorized_keys` for your user account on the server.

There are two additional steps you can take to further secure the server.

You can prevent the account from being logged into with a password by locking it with passwd:

    passwd -l username

_Note that this will prevent you from using the sudo command, as any attempt to supply your password will now fail.  For most scenarios this may be acceptable, but if you are an authorized administrator this will not be very helpful as you will have to `su root` to perform any maintenance._

You can also tell SSH to only allow certificate authentication, and not to accept passwords by opening `/etc/ssh/sshd_config` and finding this line and making sure it is uncommented with no after it:

    PasswordAuthentication no

Finally, for production servers especially, since port 22 is a well known port to attack, you should obfuscate it by changing the port number to something arbitrary and above the normal range, which can also be done in `/etc/ssh/sshd_config`:

    Port ####

Once that has been set you will need to use `ssh -p ####` to access your server, and anyone attempting to reach Port 22 will be denied.  Obfuscation is a very effective security precaution, and at the very least will reduce your logged denied login attempts.

Be sure to `sudo service ssh restart` for the changes to take affect.


**IPTables:**

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
    -A INPUT -p tcp -m tcp --dport 51122 -m conntrack --ctstate NEW -m recent --set --name DEFAULT --rsource
    -N LOG_AND_DROP
    -A INPUT -p tcp -m tcp --dport 51122 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 --name DEFAULT --rsource -j LOG_AND_DROP
    -A INPUT -p tcp -m tcp --dport 51122 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 --name DEFAULT --rsource -j LOG_AND_DROP
    -A INPUT -p tcp -m tcp --dport 51122 -j ACCEPT
    -A LOG_AND_DROP -j LOG --log-prefix "iptables deny: " --log-level 7
    -A LOG_AND_DROP -j DROP

    # Continue to allow established connections
    -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    COMMIT

Next we want to make sure that it gets loaded when the network comes up.  Running `iptables-restore` will do the trick, and it automatically flushes all the existing rules.  _Despite many articles claiming the use of `/etc/network/if-pre-up.d` as the correct directory, I have found the actual directory to us is `/etc/network/if-up.d`._

Here is a script you can place into `/etc/network/if-up.d`, be sure to make it executable:

    #!/bin/bash
    iptables-restore < /etc/firewall.conf





---


### Etc Skel & User Configuration

I create a new user with this command (to ensure bash shell):


I add my user to a series of groups:

    usermod -aG sudo username
    usermod -aG cdrom username
    usermod -aG floppy username
    usermod -aG audio username
    usermod -aG dip username
    usermod -aG video username
    usermod -aG plugdev username
    usermod -aG scanner username
    usermod -aG netdev username
    usermod -aG bluetooth username


**User .bashrc:**

I usually add color to the terminal by adding to `~/.bashrc`:

    # enable color ls
    alias ls='ls -Fa --color=auto'

_Remember that most of these can (and should) be placed into the `/etc/skel` directory._


**Vim Configuration:**

I use the following plugins:

- [ctrlp](https://github.com/kien/ctrlp.vim)
- [Surround](https://github.com/tpope/vim-surround)
- [EasyMotion](https://github.com/Lokaltog/vim-easymotion)
- [SparkUp](https://github.com/tristen/vim-sparkup)

I use the [vividchalk](https://github.com/tpope/vim-vividchalk) color scheme.

Here is what my `~/.vimrc` looks like:

    " Define Default State
    set nocompatible
    set hidden
    set nowrap
    set shiftwidth=4
    set tabstop=4
    set shiftround
    set autoindent
    set copyindent
    set smartindent
    set expandtab
    set smarttab
    set number
    set showmatch
    set ignorecase
    set smartcase
    set hlsearch
    set incsearch
    set backspace=indent,eol,start
    set nobackup
    set noswapfile
    set foldlevelstart=20

    " Define Color Scheme
    set background=dark
    colorscheme vividchalk

    " Remap Convenient Keys
    :map <F1> <Esc>
    :imap <F1> <Esc>
    nnoremap ; :
    let mapleader=","
    set pastetoggle=<F2>

    " Quickly edit/reload the vimrc file
    nmap <silent> <leader>ev :e $MYVIMRC<CR>
    nmap <silent> <leader>sv :so $MYVIMRC<CR>

    " No Noise
    set noeb vb t_vb=

    " Syntax and File Type Config
    :filetype on
    :syntax on
    :filetype indent on
    filetype plugin on
    set foldmethod=syntax

    " File Recognition
    au BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn}   set filetype=markdown
    au BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn}.{des3,des,bf,bfa,aes,idea,cast,rc2,rc4,rc5,desx} set filetype=markdown

    " Added Syntax
    highlight BadWhitespace ctermbg=red guibg=red
    highlight BadWhitespace ctermbg=red guibg=red
    au BufRead,BufNewFile *.py match BadWhitespace /*\t\*/
    au BufRead,BufNewFile *.py match BadWhitespace /\s\+$/

    " Tab autocompletion
    function! Tab_Or_Complete()
        if col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w'
            return "\<C-N>"
        else
            return "\<Tab>"
        endif
    endfunction
    :inoremap <Tab> <C-R>=Tab_Or_Complete()<CR>
    :set dictionary="/usr/dict/words"

    " Load Plugins
    set runtimepath^=~/.vim/bundle/ctrlp.vim
    :helptags ~/.vim/doc


**Git Configuration:**

    git config --global user.name "Casey DeLorme"
    git config --global user.email "CDeLorme@gmail.com"
    git config --global core.editor "vim"
    git config --global help.autocorrect 1
    git config --global color.ui true


#### Parallels Desktop Mods:

To install parallels tools you will need to mount the iso with execution options:

    mount -o exec /dev/cdrom /media/cdrom
    /media/cdrom/install

The install script must be executed with root permissions.

Post-installation you may consider modifying the `/etc/init.d/prl-x11` script by adding `insserv` headers to the top, like this:

    # Add LSB insserv Compatibility
    ### BEGIN INIT INFO
    # Provides:          prl-x11
    # Required-Start:    $remote_fs
    # Required-Stop:     $remote_fs
    # Default-Start:     2 3 4 5
    # Default-Stop:      0 1 6
    # Short-Description: x11 guest driver extension
    # Description:       prl-x11 is a parallels service that configures X11
    #                    for guest virtual machines.
    ### END INIT INFO


## Gui Configuration

Minimalist Gnome3 Packages:

    sudo aptitude install -y gnome-session gnome-terminal gnome-disk-utility gnome-screenshot gnome-screensaver desktop-base gksu gdm3 xorg-dev ia32-libs-gtk binfmt-support xdg-user-dirs-gtk xdg-utils network-manager

Optional GUI Software:

    sudo aptitude install -y eog gparted guake gnash vlc gtk-recordmydesktop chromium


**Patch Guake:**

Guake has a known bug that has yet to be fixed where it prevents execution at login due to `notification.show()` commands not able to be processed.


**Adjust Boot Services:**

With the GUI installed we now have bluetooth and network-manager services we don't need, and GUI at run-level 2 which we want to turn off:

    update-rc.d network-manager disable 2
    update-rc.d network-manager disable 3
    update-rc.d network-manager disable 4
    update-rc.d network-manager disable 5
    update-rc.d bluetooth disable 2
    update-rc.d bluetooth disable 3
    update-rc.d bluetooth disable 4
    update-rc.d bluetooth disable 5
    update-rc.d gdm3 disable 2

This stops the network-manager from interfering with our interfaces network devices, and since we don't have bluetooth devices we eliminate a running daemon.

We can use `telinit 3` to start the GUI, or `startx` if preferred, allowing us to reduce consumed resources at boot time since we don't always need the GUI.


#### Parallels Desktop Mods

_If running in parallels desktop_, you will want to update the parallels tools package prior to rebooting or you will end up with a blank screen.  You can access terminal again by switching tty consoles using ctrl+alt+f#.

For the GUI environment the parallels tools must be reinstalled:

    mount -o exec /dev/cdrom /media/cdrom
    /media/cdrom/install

Follow the prompts, opting to `upgrade`, and before rebooting add initd headings to the `/etc/init.d/prl-x11` file:

    # Add LSB insserv Compatibility
    ### BEGIN INIT INFO
    # Provides:          prl-x11
    # Required-Start:    $remote_fs
    # Required-Stop:     $remote_fs
    # Default-Start:     2 3 4 5
    # Default-Stop:      0 1 6
    # Short-Description: x11 guest driver extension
    # Description:       prl-x11 is a parallels service that configures X11
    #                    for guest virtual machines.
    ### END INIT INFO


**Grub Configuration:**

First, open up `/etc/default/grub` and find the line with `#GRUB_GFXMODE=640x480` and change it to `GRUB_GFXMODE=1024x768` or a resolution of your choice.

Next open up `/etc/grub.d/00_header`, and find the line with `set gfxmode=${GRUB_GFXMODE}` and add `set gfxpayload=keep` below it before `load_video`.

Now run `sudo update-grub` and reboot your system.  Your terminal will now be sized better for working directly instead of over SSH if desired.  _Be careful_, as a larger resolution can render the text unreadable.
