
# Debian Wheezy Template Documentation
#### Updated 10-13-2013

I use these template instructions to prepare a virtual machine template which can be used for basic cloning when I need a fresh test system.

Having a documented default or "base" install can greatly reduce room for error when setting up new machines, as well as expedite the setup process.


### Known Concerns

With templates some concerns arise.  These generally tend to be re-use of configuration data, so it is imparative that you change the configuration, especially when applying it multiple times within a network.

Here is a list of other known problems I have encountered:

Debian will remember network devices by mac address, and you will need to wipe out addresses stored inside `/etc/udev/rules.d/70-persistent-net.rules` if you intend to **clone** a templated installation across the same network.

**If using a virtual machine platform** such as Parallels desktop or VMWare, you may want to avoid snapshots for cloned machines, as they can consume significantly more space than the actual base system does.  Ideally create one template machine with the snapshots, and wipe them out after cloning a new instance.


### Hardware Configuration

Applications vary wildly, but this machine will run sufficiently on 1GB of memory, possibly less if you omit the GUI installation, more if you intend to run large memory hungrey applications.


#### Ideal Partitioning & Installation

I tend to rely on logical volumes to separate all key partitions.  This is for security and control, for example I limit /var/log and /tmp partitions to sizes between 500MB-1GB.  _This is a preventative step and does not actually address the real cause of the problem, but it can take off some of the stress of solving a problem when your system stops functioning due to no drive space._  An independent home volume allows for easy expansion as necessary, giving you additional flexibility.  Technically you cannot expand root while the system is running, but there are several detailed guides on doing so in various platforms (even redhat).

Due to the complexity involved in resizing root it would be ideal to supply a high threshhold according to what you intend to have running.  For a full GUI environment somewhere between 8-12GB tends to work nicely.

I try to keep my template to 20GB of space, which should give you enough room for an 8GB root and plenty spare for the remaining partitions.  A standard install with Gnome3 will work with 6GB so 8GB gives you some flexing room for packages such as development tools or multimedia.

Here is a break-down of my partitioning scheme:

- 256MB PC-Grub/EFI Partition
- 256MB ext4 /boot
- Remainder to Volume Group
    - VG Name "debian"
        - 2GB swap
        - 8GB root /
        - 512MB log /var/log
        - 512MB tmp /tmp
        - Remainder home /home (8.5GB)

I also only ever install `system utilities` from the package options.

I leave Gnome3 for later, as I don't always use it in all templates, and when I do I prefer a minimalist install to save nearly a GB of space consumed by default software that I would not be using.

I also omit user creation besides root for the begining.  This gives me greater flexibility in creating the user later, after `sudo` and other utilities are readily available.


### Post Installation Steps

Start by logging in as root to run through these steps.

I generally install these packages on every machine:

    aptitude install -y sudo ssh tmux screen vim parted ntp git mercurial curl bash-completion

Optional Tools:

    aptitude install -y kernel-package build-essential debhelper fakeroot p7zip-full exfat-fuse exfat-tools keychain monit


**Automatic Updates:**

Potentially a security problem, but not really a bad script to create, is a cron job to handle updating packages on the system.

If you are concerned for breaks you can always have it execute a dry-run and email you so you know when updates become available.

I create a file `/etc/cron.weekly/aptitude` containing:

    #!/bin/sh
    # Weekly Software Updates (No Logging or Notification, be warned)
    aptitude clean
    aptitude update
    aptitude upgrade -y

Be sure it is executable:

    chmod +x /etc/cron.weekly/aptitude


**SSD Optimizations:**

If this system is running ontop of a SSD, you may consider a couple of additions for TRIM support.

First, a cron job to handle fstrim in batches which can dramatically improve the life of the disk:

    echo "#!/bin/sh\nfor mount in / /boot /home /var/log /tmp; do\n\tfstrim $mount\ndone" > /etc/cron.weekly/fstab
    chmod +x /etc/cron.weekly/fstab

You can also set the `issue_discards = 1` inside `/etc/lvm/lvm.conf` to enable LVM trims:

    sed -i 's/issue_discards = 0/issue_discards = 1/' /etc/lvm/lvm.conf


**UMask for Group Write Permissions:**

Modern platforms create a private user group per user, which eliminates a bulk of former security concerns.  I choose to modify the default UMASK on files for group privileges, which ensures that files created going forward will be properly shared with group members.  This is especially helpful for automation, where controlling created file permissions would add extra steps and sometimes not be feasible.

To start we locate `UMASK 022` inside `/etc/logins.def` and change it to `UMASK 002`, which will give 775 permissions (more than one space may separate the code from UMASK).

Next we want to globally enforce this using `/etc/pam.d/common-session` by adding the following line at the bottom:

    session optional pam_umask.so umask=007

_This will take effect immediately and will not require a reboot._


**Configuring Monit:**

At a bare minimum monit allows us to ensure that if the system is overloaded or a key utility such as ssh hangs or dies that it gets rebooted.  It is a very reliable tool and good to have installed for general purpose use.

Here are some example configurations for ssh and system you can throw into `/etc/monit/conf.d`:

SSH:

    check process sshd with pidfile /var/run/sshd.pid
        start program = "/etc/init.d/ssh start"
        stop program  = "/etc/init.d/ssh stop"
        if cpu > 80% for 5 cycles then restart
        if totalmem > 200.00 MB for 5 cycles then restart
        if 3 restarts within 8 cycles then timeout

System:

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

You can also add a secured "tunnel-only" accessible web interface to check the server status via another config file:

    # Establish Web Server on a custom port and restrict access to localhost
    set httpd port ####
        allow 127.0.0.1

You can then use SSH tunneling to access the page from `http://127.0.0.1:####`:

    ssh -f -N username@remote_ip -L ####:localhost:####

_Monit can do a whole lot more than this so if you are interested check out their documentation._


**Establish a FQDN Hostname:**

Start by updating the hostname with this command (to automate this we would need a config option per system):

    echo "hostname" > /etc/hostname
    hostname -F /etc/hostname

_I often assign a static IP but that cannot be automated.  I do this to prevent conflicts and make it easier to know my target for SSH access or other activities._

For a fully qualified domain name we want to add two bits to `/etc/hosts`:

    127.0.1.1 hostname.domain.dev hostname

Now if we type `hostname -f` we will get the whole domain name.


**Securing SSH:**

Obfuscating the SSH port is always a good plan on a public facing server:

    sed -i "s/Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config

We can start with disabling root ssh access by opening `/etc/ssh/sshd_config` and finding the line below and making sure it is set to no:

    PermitRootLogin no

_If you are logged in as root over ssh it might be wise to skip ahead and create a user with sudo privileges beforehand._

If you want to simplify SSH access you can add your remote or work machines public key contents to `~/.ssh/authorized_keys`, or perhaps to `/etc/skel` to be supplied to any users created henceforth.

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

I generally create a basic iptables file with affective policies and ssh rate limiting, placing the contents into `/etc/firewall.conf`:

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

_Note that the `ssh` value translates to the default port 22, and will not change based on the active/actual SSH port.  If you have changed the port number you will have to adjust the iptables value._

Next we want to make sure that it gets loaded when the network comes up.  Running `iptables-restore` will do the trick, and it automatically flushes all the existing rules.  _Despite many articles claiming the use of `/etc/network/if-pre-up.d` as the correct directory, I have found the actual directory to us is `/etc/network/if-up.d`._

Here is a script you can place into `/etc/network/if-up.d`, be sure to make it executable:

    #!/bin/bash
    iptables-restore < /etc/firewall.conf

_According to the man pages, the restore operation will automatically (by default) flush the existing rules when loading a new file._


### Etc Skel & User Configuration

_Changes made to `~/*` should be placed into `/etc/skel`, which will be distributed to all users._


**Setting up SSH:**

If you intend to run a server headless and need to pull down contents from private repositories, this is the best way to accomplish that.  Even with software such as the `keychain` package you will have to login and enter a password at boot time everytime.

Obviously for security reasons you will want to make sure that any passwordless keys are not given write privileges to remote contents.

To create a strong SSH key:

    ssh-keygen -t rsa -b 4096 -c Email

Follow the prompts for naming, and optionally add a password.

To handle SSH rate limiting in the previous firewall rules we may want to re-use established SSH connections.  This can be done by adding the following to your `~/.ssh/config`:

    Host *
        ControlMaster auto
        ControlPath ~/.ssh/%r@%h:%p
        CompressionLevel 9

_Note that doing this may require you to set an addition `-o ControlMaster=no` option when tunneling services, or adding specific details for tunneling to the same config file:_

    Host monit
        ControlMaster no
        HostName remote_ip
        User username
        LocalForward remote_port 127.0.0.1:local_port


**Git Configuration:**

    git config --global user.name "Casey DeLorme"
    git config --global user.email "CDeLorme@gmail.com"
    git config --global core.editor "vim"
    git config --global help.autocorrect -1
    git config --global color.ui true
    git config --global push.default matching
    git config --global remote.origin.push HEAD
    git config --global alias.a add
    git config --global alias.s status
    git config --global alias.st stash
    git config --global alias.sa "stash apply"
    git config --global alias.c commit
    git config --global alias.l '!. ~/.githelpers && pretty_git_log'
    git config --global alias.pp '!git pull && git push'

I use aliases to expedite the git command chain, which despite the small difference can have a significant impact.  Either way if you don't use them having them won't hurt.

This should create a `~/.gitconfig` similar to:

    [user]
        name = Casey DeLorme
        email = CDeLorme@gmail.com
    [core]
        editor = vim
    [help]
        autocorrect = 1
    [color]
        ui = true
    [alias]
        a = add
        s = status
        c = commit
        st = stash
        sa = stash apply
        l = !. ~/.githelpers && pretty_git_log
        pp = !git pull && git push
    [push]
        default = matching
    [remote "origin"]
        push = HEAD

I further enhance my git experience with a series of files.

First I add a prompt enhancer to `~/.git-prompt` containing:

    #!/bin/bash
    #~/.git-prompt
    # Colorful default with non-breaking bare-repository git PS1 support
    if [[ $- == *i* ]] ; then
        c_red=`tput setaf 1`
        c_green=`tput setaf 2`
        c_blue=`tput setaf 4`
        c_purple=`tput setaf 5`
        c_cyan=`tput setaf 6`
        c_sgr0=`tput sgr0`

        parse_git_branch ()
        {
            if git rev-parse --git-dir >/dev/null 2>&1
            then
                gitver=$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')
                numfil=$(git status | grep "#   " | wc -l)
                echo -e git:$gitver:$numfil

            elif hg status -q >/dev/null 2>&1
            then
                hgver=$(hg branch 2>/dev/null)
                numfil=$(hg status | wc -l)
                echo -e hg:$hgver:$numfil
            else
                  return 0
            fi
        }

        branch_color ()
        {
                color="${c_red}"
                if git rev-parse --git-dir >/dev/null 2>&1
                then
                        if git status | grep "nothing to commit" 2>&1 > /dev/null
                        then
                            color=${c_green}
                        fi
                elif hg status -q >/dev/null 2>&1
                then
                        if expr $(hg status | wc -l) == 0 2>&1 > /dev/null
                        then
                            color=${c_green}
                        fi
                else
                        return 0
                fi
                echo -ne $color
        }

        colorify ()
        {
            if ! git status &> /dev/null;
            then
                echo -ne "${c_blue}${0} ($(date +%R:%S))${c_sgr0} ${c_purple}$(whoami)${c_sgr0}@${c_green}$(hostname)${c_sgr0} ${c_blue}$(dirs)${c_sgr0}"
            else
                echo -ne "$(whoami)@$(hostname) ${c_red}$(dirs)${c_sgr0} [$(branch_color)$(parse_git_branch)${c_sgr0}]"
            fi
        }

        PS1='[$(colorify)]$ '
    fi

Next I create a `~/.githelpers` file for pretty log output containing:

    #!/bin/bash

    # Log output:
    #
    # * 51c333e    (12 days)    <Gary Bernhardt>   add vim-eunuch
    #
    # The time massaging regexes start with ^[^<]* because that ensures that they
    # only operate before the first "<". That "<" will be the beginning of the
    # author name, ensuring that we don't destroy anything in the commit message
    # that looks like time.
    #
    # The log format uses } characters between each field, and `column` is later
    # used to split on them. A } in the commit subject or any other field will
    # break this.

    HASH="%C(yellow)%h%Creset"
    RELATIVE_TIME="%Cgreen(%ar)%Creset"
    AUTHOR="%C(bold blue)<%an>%Creset"
    REFS="%C(red)%d%Creset"
    SUBJECT="%s"

    FORMAT="$HASH}$RELATIVE_TIME}$AUTHOR}$REFS $SUBJECT"

    show_git_head() {
        pretty_git_log -1
        git show -p --pretty="tformat:"
    }

    pretty_git_log() {
        git log --graph --abbrev-commit --date=relative --pretty="tformat:${FORMAT}" $* |
            # Repalce (2 years ago) with (2 years)
            #sed -Ee 's/(^[^<]*) ago)/\1)/' |
            # Replace (2 years, 5 months) with (2 years)
            #sed -Ee 's/(^[^<]*), [[:digit:]]+ .*months?)/\1)/' |
            # Line columns up based on } delimiter
            column -s '}' -t |
            # Page only if we need to
            less -FXRS
    }

I also grab a copy of the git-completion shell script (you can find this online).


**User .bashrc:**

I generally replace the contents of my `~/.bashrc/` with:

    # .bashrc for interactive shells post login

    # Don't continue if not interactive
    [ -z "$PS1" ] && return

    # Shell options (resize & history)
    shopt -s checkwinsize
    shopt -s histappend

    # Don't add lines to history that begin with a space
    HISTCONTROL=ignoreboth

    # Enable Bash Completion
    if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
    elif [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
    fi

    # If not ~/bin exists, create it
    if [ ! -d "~/bin" ];then
        mkdir -p "~/bin"
    fi

    # If sublime text is installed and no subl exists create it
    if [ ! -f "~/bin/subl" ] && [ -f "~/Applications/sublime_text/sublime_text" ];then
        ln -s "~/Applications/sublime_text/sublime_text" "~/bin/subl"
    fi

    # If no autostart dir exists create it
    if [ ! -d "~/.config/autostart" ];then
        mkdir -p "~/.config/autostart"
    fi

    # If guake not exists on startup add it
    if [ ! -f "~/.config/autostart/guake.desktop" ] && [ -f "~/.local/share/applications/guake.desktop" ];then
        ln -s "~/.local/share/applications/guake.desktop" "~/config/autostart/guake.desktop"
    fi

    # Add color to ls
    alias ls='ls -ahF --color=auto'

    # Load Git Additions
    . ~/.git-completion
    . ~/.git-prompt

Load your ssh keys using keychain so that automated processes can run without password entry until the next reboot:

    keychain ~/.ssh/id_rsa
    . ~/.keychain/$HOSTNAME-sh


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


**User Creation:**

I create a new user with this command (to ensure bash shell):

    useradd -m -s /bin/bash -p username
    passwd username

Supply a password so that you may login as this user going forward.  The `-s` flag lets us  set the bash shell, otherwise it will default to the original `/bin/sh`.

I will usually add my user account to a series of groups:

    usermod -aG sudo username
    usermod -aG video username
    usermod -aG audio username
    usermod -aG cdrom username


## Gui Configuration

Minimalist Gnome3 Packages:

    sudo aptitude install -y gnome-session gnome-terminal gnome-disk-utility gnome-screenshot gnome-screensaver desktop-base gksu gdm3 xorg-dev ia32-libs-gtk binfmt-support xdg-user-dirs-gtk xdg-utils network-manager

Optional GUI Software:

    sudo aptitude install -y eog gparted guake gnash vlc gtk-recordmydesktop chromium

Optional Development Tools:

    sudo aptitude install -y glib-devel glibc-devel gnome-libs-devel gstream-devel gtk3-devel guichan-devel libX11-devel libmcrypt-devel qt3-devel qt-devel pythonqt-devel python-devel python3-devel pygame-devel perl-devel nodejs-devel ncurses-devel pygobject2-devel pygobject3-devel gobject-introspection-devel guichan bpython

_These development tools may add a significantly to the size of the install._


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


**Patch Guake:**

Guake has a known bug that has yet to be fixed where it prevents execution at login due to `notification.show()` commands not able to be processed.

    sed -i 's/notification.show()/try:\n                notification.show()\n            except Exception:\n                pass/' /usr/bin/guake
    rm /etc/xdg/autostart/guake.desktop

I create a new .desktop file in `~/.local/share/applications/guake.desktop` containing:

    [Desktop Entry]
    Name=Guake Terminal
    Comment=Use the command line in a Quake-like terminal
    TryExec=guake
    Exec=guake
    Icon=/usr/share/pixmaps/guake/guake.png
    Type=Application
    Categories=GNOME;GTK;Utility;TerminalEmulator;

Then I can easily setuo local autostart in `~/.config/autostart` and symlink the new .desktop:

    mkdir -p ~/.config/autostart
    ln -s ~/.local/share/applications/guake.desktop ~/.config/autostart/guake.desktop


**Setup Sublime Text:**

_I am using Sublime Text 2, but Sublime Text 3 may soon be replacing it, so these instructions are subject to change._

Installing a copy per-user is probably the best way to separate the application, but you can decide whether to put it someplace more global.

Grab the latest version off their website:

    wget -O ~/sublime.tar.bz2 http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.2%20x64.tar.bz2
    tar xf sublime.tar.bz2
    rm sublime.tar.bz2
    mkdir ~/applications
    mv Sublime* ~/applications/sublime_text/

You can create a .desktop file in `~/.local/share/applications/subl.desktop` with:

    [Desktop Entry]
    Name=Sublime Text
    Comment=The World's best text editor!
    TryExec=subl
    Exec=subl
    Icon=~/applications/sublime_text/Icon/256x256/sublime_text.png
    Type=Application
    Categories=GNOME;GTK;Utility;TerminalEmulator;Office;

I generally keep a local `~/bin` folder and load it into the global PATH from my .bashrc, which allows me to then add a symlink to sublime text:

    ln -s ~/applications/sublime_text/sublime_text ~/bin/subl


**Enable GDM Login as Root:**

Totally optional, but doing so is a simple matter of adjusting pam:

    sed -i "s/user != root//" /etc/pam.d/gdm3


#### Parallels Desktop Mods

To install parallels tools you will need to mount the iso with execution options:

    mount -o exec /dev/cdrom /media/cdrom
    /media/cdrom/install

The install script must be executed with root permissions.

Post-installation you may encounter a video problem if the `/etc/initd/prl-x11` script does not contain the correct insserv headers, but you can easily add them to the top and re-run the script before rebooting:

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
