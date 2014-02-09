
# Debian Wheezy Template Documentation
#### Updated 11-20-2013

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

As a precursor to the other packages we should install `netselect-apt` to update our aptitude sources to the closest and fastest mirror.  We can do so via:

    aptitude install -y netselect-apt
    mv /etc/apt/sources.list /etc/apt/sources.list.original
    netselect-apt -s -o /etc/apt/sources.list
    aptitude clean
    aptitude update

I dislike having extra auto-completion conflicting software, and debian comes with `vi` or `vim-tiny` by default.  So I generally remove it before installing the full vim:

    dpkg -r vim-common vim-tiny

I generally install these packages on every machine:

    aptitude install -y sudo ssh tmux screen vim parted ntp git git-flow mercurial bash-completion unzip p7zip-full keychain exfat-fuse exfat-tools monit pastebinit curl markdown kernel-package build-essential debhelper libncurses5-dev fakeroot lzop fonts-takao netselect-apt


**Package Mirrors:**

We want to use the `netselect-apt` package to automate finding the best mirrors to work with going forward.  Place these lines in `/etc/cron.monthly/netselect`:

    # #!/bin/bash

    # Update package mirrors
    netselect-apt -s -n
    aptitude clean
    aptitude update

Then make it executable:

    chmod +x /etc/cron.monthly/netselect


**Automatic Updates:**

Potentially a security problem, but not really a bad script to create, is a cron job to handle updating packages on the system.

If you are concerned for breaks you can always have it execute a dry-run and email you so you know when updates become available.

I create a file `/etc/cron.weekly/aptitude` containing:

    #!/bin/sh

    # update packages weekly
    aptitude clean
    aptitude update
    aptitude upgrade -y

Be sure it is executable:

    chmod +x /etc/cron.weekly/aptitude


**Defragmentation:**

If you have a bunch of ext4 file systems storing content, even on lvm, it might be wise to create a defrag cron-job to keep the data orderly.  Create a file at `/etc/cron.weekly/e4defrag` with lines similar to:

    #!/bin/sh

    # defragment ext4 devices
    for DEVICE in $(mount | grep ext4 | awk '{print $1}')
    do
        e4defrag "${DEVICE}"
    done


_The primary benefit is not one of performance, but of disk consumption.  As data spreads it can be harder to organize, which could be a negative as far as resizing partitions or LVM for that matter._

As before we wish to make this executable:

    chmod +x /etc/cron.weekly/e4defrag


**SSD Optimizations:**

If this system is running ontop of a SSD, you may consider a couple of additions for TRIM support.  First, instead of enabling the `discard` option in fstab, you will want to run the `fstrim` command on a regular basis, so as to reduce the amount of IO and extend the life of the drive.  Create a file in `/etc/cron.weekly/fstrim` with these lines:

    #!/bin/bash

    # Handle regular trim cleanup (much less IO problems than setting discard flag in fstab)
    for DEVICE in $(mount | grep ext4 | grep -v mapper | awk '{print $1}')
    do
        fstrim "${DEVICE}"
    done



Then make it executable:

    chmod +x /etc/cron.weekly/fstrim

For LVM partitions, you will want to tell the logical volume manager, through its own configuration, that it can issue discards, by setting `issue_discards = 1` inside `/etc/lvm/lvm.conf`:

    sed -i 's/issue_discards = 0/issue_discards = 1/' /etc/lvm/lvm.conf


**UMask for Group Write Permissions:**

Modern platforms create a private user group per user, which eliminates a bulk of former security concerns with providing group privileges on ones files.  I have chosen to modify the default for standard users (root should still retain a mask of `022`) that will allow access for any shared groups by default, which can be exceptionally helpful to reduce conflicts with automation on a multi-user system.

To start we locate `UMASK 022` inside `/etc/logins.def` and change it to `UMASK 002`, which will give 775 permissions (more than one space may separate the code from UMASK).

Next we want to globally enforce this using `/etc/pam.d/common-session` by adding the following line at the bottom:

    session optional pam_umask.so umask=002

_This will take effect immediately and will not require a reboot._


**Switching from sysvinit with systemd:**

This section, as you may have guessed, is incomplete.  By default debian uses the sysvinit boot process, and the reasons include:

- it is stable
- it is posix compatible
- it can be easily edited, as it only consists of shell scripts
- it only does one job, and that is to fire up services by run-level

The systemd boot process changes the game by offering:

- automatic parallelized processes by dependency
- simplified ini files that make creating and editing easier, but provide less functionality
- uses binaries that make editing the process significnatly more difficult
- provides service monitoring and will restart crashed services

The last one there, to me, is the most valuable.  I want to have a boot process tool whose job it is to "manage" boot processes, not just kick them off.  If the processes _it_ starts crash, I want _it_ to be responsible for noticing and restarting them.

That said, I have had first hand experience in fedora and arch of systemd, and found it to be one of many things that led to instability.  In particular the push towards binary "anything" is the wrong move, and it created far too many problems on my systems.  Combined with the binary log services, the heavy-weight GUI, Gnome3, and the ever-annoying network manager, everything was tightly coupled, leaving no room for choice.

_If I were to install systemd it would primarily be for the monitoring of services which would eliminate the need for monit (or any similar system), but I probably won't switch so long as it becomes tied to too many other binary services._


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

---



**Establish a FQDN Hostname:**

Start by updating the hostname with this command (to automate this we would need a config option per system):

    echo "hostname" > /etc/hostname
    hostname -F /etc/hostname

_I often assign a static IP but that cannot be automated.  I do this to prevent conflicts and make it easier to know my target for SSH access or other activities._

If you did **not** set a domain name during installation, you can do so now manually.  For a fully qualified domain name we want to add two bits to `/etc/hosts`:

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

Be sure to `service ssh restart` for the changes to take affect.


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


**Add JPN Locale Support:**

If you want to have japanese character support, and did not select the secondary locale during install, you can do so now by modifying the `/etc/locale.gen` file and re-running the locale-gen command:

    echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen



**User Creation:**

_If you want to automate configuring the terminal, potentially saving a bit of time, then you should run through the instructions below this step first._

This is the last task I perform, generally after I have placed all of my dot files and related configuration into `/etc/skel`, this way future users on that system automatically have all those useful tools available to them.

I create a new user with this command (ensuring bash shell, otherwise debian defaults to `/bin/sh`):

    useradd -m -s /bin/bash username
    passwd username

You will then wish to run `passwd username` to assign that account a password (or else they may be unable to login).

If this user will have admin privileges add them to the sudo group:

    usermod -aG sudo username


### Etc Skel & User Configuration

**If you want to skip the next several pages of configuration, you can just download and execute my [dot-files](https://github.com/cdelorme/dot-files) repo.**

_Ideally, besides being in `~/`, the files created here can be placed into `/etc/skel`, where they will be distributed to all new users._


**Setting up SSH:**

You should generally only create keys for user accounts, root accounts should not be involved in security beyond the local system, this prevents any extra ties to the outside from becoming potential risks.

To create a strong SSH key:

    ssh-keygen -t rsa -b 4096 -C Email

Follow the prompts for naming, and optionally add a password.

By default your key will ask you for your password everytime you use it.  To avoid this you can configure `keychain`, which will allow you to easily load the key into an ssh-agent.  _I do this in my `~/.bashrc` dot file._

If your machine will be running scripts that need ssh access to remote resources you may consider creating a passwordless ssh key.

The only real security flaw with a passwordless ssh key is if someone gains unauthorized access to that machine.  As such it is best practice to provide read-only access to that ssh key from those resources.

_Note that it is equally insecure to add a password to your SSH key and load it from a file that is read only for your user, because if someone gains unauthorized access they can still acheive the exact same degree of control._

If you want to add this key to your github account, you can use the curl command to do so from the command line without any GUI at all:

    curl -i -u "username:password" -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"title\":\"name this key\",\"key\":\"$(cat ~/.ssh/id_rsa.pub)\"}' https://api.github.com/user/keys

To optimize ssh, and avoid rate-limiting problems with iptables, you can re-use an established ssh connection from the same machine.  Simply add these lines to `~/.ssh/config`:

    Host *
        ControlMaster auto
        ControlPath ~/.ssh/%r@%h:%p
        CompressionLevel 9
        ControlPersist 2h

_Note that doing this may require you to set an addition `-o ControlMaster=no` option when tunneling services, or adding specific details for tunneling to the same config file:_

    Host monit
        ControlMaster no
        HostName remote_ip
        User username
        LocalForward remote_port 127.0.0.1:local_port


**Git Configuration:**

    git config --global core.editor "vim"
    git config --global help.autocorrect -1
    git config --global color.ui true
    git config --global push.default matching
    git config --global pull.default matching
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

I also like to enhance my overall terminal experience by adding a bunch of functionality.

First let's create `~/.bash_logout` specifically to clear my environment on exit so subsequent logins don't see the previous commands and appear "fresh":

    #!/bin/bash

    # clear on exit
    [ -x "/usr/bin/clear" ] && /usr/bin/clear
    [ -x "/usr/bin/clear_console" ] && clear_console -q

Next we'll download [git completion](https://raw.github.com/git/git/master/contrib/completion/git-completion.bash), to make git even easier to use:

    wget "https://raw.github.com/git/git/master/contrib/completion/git-completion.bash" -O .git-completion

In the above git config I aliased a command to a `~/.githelpers`, which can be found all over the internet, but basically gives you a beautified and simple pipeline of git activity.  The contents include:

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

Next let's customize our prompt and add git and mercurial support by creating a custom `~/.promptrc`:

    #!/bin/bash
    #~/.promptrc

    # Create a dynamic prompt that adjusts if in a git repo
    c_bold=`tput bold`
    c_red=`tput setaf 1`
    c_green=`tput setaf 2`
    c_blue=`tput setaf 4`
    c_purple=`tput setaf 5`
    c_cyan=`tput setaf 6`
    c_sgr0=`tput sgr0`

    # Support for Git & Mercurial
    parse_repo_branch ()
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

    # Colorize the branch based on its state
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

    # Check for git and supply a colorized detailed prompt
    colorify ()
    {
        if ! git status &> /dev/null;
        then
            echo -ne "${c_blue}${0} ($(date +%R:%S)) ${c_purple}$(whoami)${c_sgr0}@${c_green}$(hostname) ${c_bold}${c_blue}$(dirs)${c_sgr0}"
        else
            echo -ne "$(whoami)@$(hostname) ${c_bold}${c_red}$(dirs)${c_sgr0} [$(branch_color)$(parse_repo_branch)${c_sgr0}]"
        fi
    }

    # By wrapping in single quotes we allow the command execution to be parsed only when requested
    PS1='\n[$(colorify)\n$ '

Finally to tie all of these things together and add some infrastructure (some optional for gui), we can create a `~/.bashrc`:

    #!/bin/bash

    # Discontinue if shell is not interactive
    [ -z "$PS1" ] && return

    # Set default editor
    export EDITOR=vim

    # Create a bin folder for the user if one does not exist
    if [ ! -d ~/bin ];
    then
        mkdir -p ~/bin &> /dev/null
    fi

    # Always add local bin path for user-overrides
    export PATH=~/bin:$PATH

    # Auto-Completion
    if [[ -r /usr/share/bash-completion/bash_completion ]];
    then
        . /usr/share/bash-completion/bash_completion
        set show-all-if-ambiguous on
        set show-all-if-unmodified on

        # Add for sudo users
        complete -cf sudo &> /dev/null
    fi

    # If the command is not found, look for packages that contain it
    [[ -f /usr/share/doc/pkgfile/command-not-found.bash ]] && . /usr/share/doc/pkgfile/command-not-found.bash

    # Set History File
    export HISTFILE=~/.history

    # Append History
    shopt -s histappend

    # Ignore lines in history that started with a space
    export HISTCONTROL=ignoreboth

    # Attempt Directory Autocompletion (For typo-prone)
    shopt -s dirspell

    # Expand typed variables, instead of correcting
    shopt -s direxpand

    # Alias ls
    alias ls='ls -ahF --color=auto'

    # Auto-detect changes in window size and adjust
    shopt -s checkwinsize

    # If the system has a gnome shell, let's
    if [ -n "$DISPLAY" ];
    then

        # Create Autostart Folder if it does not already exist
        if [ ! -d ~/.config/autostart ];
        then
            mkdir -p ~/.config/autostart &> /dev/null
        fi

        # Check for Sublime Text & create subl command if not already present
        if [ ! -f ~/bin/subl ] && [ -f ~/Applications/sublime_text/sublime_text ];
        then
            ln -s ~/Applications/sublime_text/sublime_text ~/bin/subl
        fi

        # If guake exists, make sure it is loaded at login
        if [ ! -h ~/.config/autostart/guake.desktop ] && [ -f ~/.local/share/applications/guake.desktop ];
        then
            ln -s ~/.local/share/applications/guake.desktop ~/.config/autostart/guake.desktop
        fi

    fi

    # Autoload SSH Access
    if [ -z "$SSH_AGENT_PID" ];
    then
        keychain ~/.ssh/id_rsa
        . ~/.keychain/$HOSTNAME-sh
    fi;

    # Load Git Completion
    . ~/.git-completion

    # Load Custom Prompt
    . ~/.promptrc


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

This gives me a very basic auto-completion, and a variety of useful tools that help my productivity.
