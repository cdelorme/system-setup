#!/bin/bash

# notify failure without root permissions, and exit
[ $(id -u) -ne 0 ] && echo "execution will fail without root permissions..." && exit 1

##
# request additional information
##

echo -n "enter a username for your new system user: "
read username

echo -n "enter a password for your new system user: "
read password

echo -n "enter an ssh port (default: 22): "
read ssh_port

echo -n "enter a timezone path (default: /usr/share/zoneinfo/US/Eastern): "
read timezone

echo -n "enable jis (y|n, default: y): "
read jis

# set defaults
[ -z "$ssh_port" ] && ssh_port=22
[ -z "$timezone" ] && timezone="/usr/share/zoneinfo/US/Eastern"
[ -z "$jis" ] && jis="y"

# install netselect-apt and find the best mirrors
# then get the system updated before we go forward
aptitude install -ryq netselect-apt
mv /etc/apt/sources.list /etc/apt/sources.list.bak
netselect-apt -sn -o /etc/apt/sources.list
aptitude clean
if ! aptitude update
then
    mv /etc/apt/sources.list.bak /etc/apt/sources.list
    aptitude clean
    aptitude update
fi
aptitude upgrade -yq

# silently install template packages /w recommends
aptitude install -ryq screen tmux vim git mercurial bzr subversion command-not-found bash-completion unzip monit ntp resolvconf watchdog ssh sudo whois rsync curl e2fsprogs parted os-prober

# execute first-run warmups
update-command-not-found

# enable watchdog
update-rc.d watchdog defaults

# optimize lvm
sed -i 's/issue_discards = 0/issue_discards = 1/' /etc/lvm/lvm.conf

# fix permissions
sed -i 's/UMASK\s*022/UMASK        002/' /etc/login.defs
if [ $(grep -c "umask=002" /etc/pam.d/common-session) -eq 0 ]
then
    echo "session optional pam_umask.so umask=002" >> /etc/pam.d/common-session
fi

# install cronjobs
[ -f "data/etc/cron.daily/system-updates" ] && cp "data/etc/cron.daily/system-updates" "/etc/cron.daily/system-updates"  || $dl_cmd "/etc/cron.daily/system-updates" "https://raw.githubusercontent.com/cdelorme/system-setup/master/data/etc/cron.daily/system-updates"
[ -f "data/etc/cron.weekly/disk-maintenance" ] && cp "data/etc/cron.weekly/disk-maintenance" "/etc/cron.weekly/disk-maintenance"  || $dl_cmd "/etc/cron.daily/system-updates" "https://raw.githubusercontent.com/cdelorme/system-setup/master/data/etc/cron.weekly/disk-maintenance"

# todo install monit configs
[ -f "data/etc/monit/monitrc.d/system" ] && cp "data/etc/monit/monitrc.d/system" "/etc/monit/monitrc.d/system"  || $dl_cmd "/etc/monit/monitrc.d/system" "https://raw.githubusercontent.com/cdelorme/system-setup/master/data/etc/monit/monitrc.d/system"
[ -f "data/etc/monit/monitrc.d/ssh" ] && cp "data/etc/monit/monitrc.d/ssh" "/etc/monit/monitrc.d/ssh"  || $dl_cmd "/etc/monit/monitrc.d/ssh" "https://raw.githubusercontent.com/cdelorme/system-setup/master/data/etc/monit/monitrc.d/ssh"
[ -f "data/etc/monit/monitrc.d/web" ] && cp "data/etc/monit/monitrc.d/web" "/etc/monit/monitrc.d/web"  || $dl_cmd "/etc/monit/monitrc.d/web" "https://raw.githubusercontent.com/cdelorme/system-setup/master/data/etc/monit/monitrc.d/web"

# activate with symlinks
ln -nsf "../monitrc.d/system" "/etc/monit/conf.d/system"
ln -nsf "../monitrc.d/ssh" "/etc/monit/conf.d/ssh"
ln -nsf "../monitrc.d/web" "/etc/monit/conf.d/web"

# test and restart monit
monit -t && service monit restart

# set system timezone
ln -nsf $timezone /etc/localtime

# update hosts
# @todo add variable for hostname
#hostname -F /etc/hostname
#sed -i "s/127.0.1.1.*/127.0.1.1 ${config_system_hostname}.${config_system_domainname} ${config_system_hostname}/" /etc/hosts

# fix grub kernel panics
if [ -f /etc/default/grub ]
then
    sed -i 's/GRUB_COMMANDLINE_LINUX_DEFALT=.*/GRUB_COMMANDLINE_LINUX_DEFALT="quiet panic=10"/' /etc/default/grub
    update-grub
fi

# secure ssh & restart service
# @todo variable for ssh port, default to "22"
# sed -i "s/Port\s*[0-9].*/Port ####/" /etc/ssh/sshd_config
sed -i "s/^#\?PasswordAuthentication\s*[yn].*/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i "s/^#\?PermitRootLogin.*[yn].*/PermitRootLogin no/" /etc/ssh/sshd_config
service ssh restart

# install iptables
mkdir -p /etc/iptables
# @todo copy || download /etc/iptables/iptables.rules
# @todo copy || download /etc/network/if-up.d/iptables


# @todo add conditional variable to enable jis
# turn on jis locale & rebuild
if [ $(grep -c "ja_JP.UTF-8" /etc/locale.gen) -eq 1 ]
then
    sed -i "s/# ja_JP\.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/" /etc/locale.gen
fi
locale-gen
# @todo install custom fonts & rebuild cache
#mkdir -p /usr/share/fonts/ttf/jis
#curl -o "/usr/share/fonts/ttf/jis/ForMateKonaVe.ttf" "https://raw.githubusercontent.com/cdelorme/system-setup/master/data/fonts/ForMateKonaVe.ttf"
#curl -o "/usr/share/fonts/ttf/jis/epkyouka.ttf" "https://raw.githubusercontent.com/cdelorme/system-setup/master/data/fonts/epkyouka.ttf"
#fc-cache -fr

# @todo attempt to run dot-files installer as root, so it adds to /etc/skel


# @todo conditionally create new user and add to core groups
# if ! id ${config_system_username} &> /dev/null
# then
#     useradd -m -s /bin/bash -p $(mkpasswd -m md5 "${config_system_password}") ${config_system_username}
# fi
#usermod -aG sudo,adm ${config_system_username}

# @todo conditionally generate ssh key
# @todo conditionally upload ssh key to github

# @todo download home/ from repo (*specific files*)

# @todo add crontab to run `update-keys`
