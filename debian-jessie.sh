#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# fail if not running as root
[ $(id -u) -ne 0 ] && echo "must be executed with root permissions..." && exit 1

# function to correctly retry package installation on failure
safe_aptitude_install() {
	unset UCF_FORCE_CONFNEW
	local UCF_FORCE_CONFOLD=true
	local DEBIAN_FRONTEND=noninteractive
	aptitude clean
	aptitude update
	aptitude upgrade -yq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" | tee /tmp/aptitude.log
	if [ $(grep -c "E: Failed" /tmp/aptitude.log) -ne 0 ] || [ $(grep -c "W: Failed" /tmp/aptitude.log) -ne 0 ]
	then
		safe_aptitude_install $@
	fi
	aptitude install -f -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
	[ -z "$@" ] && return 0
	aptitude install -fryq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "$@" 2>&1 | tee /tmp/aptitude.log
	if [ $(grep -c "E: Failed" /tmp/aptitude.log) -ne 0 ] || [ $(grep -c "W: Failed" /tmp/aptitude.log) -ne 0 ]
	then
		safe_aptitude_install $@
	fi
	return 0
}

##
# @description request input and optionally apply a fallback/default value
# @param $1 variable name
# @param $2 default value
# @param $3 description
##
grab_or_fallback()
{
	[ -n "$(eval echo \${$1:-})" ] && return 0
	export ${1}=""
	read -p "${3:-input}: " ${1}
	[ -z "$(eval echo \$$1)" ] && export ${1}="${2:-}"
	return 0
}

##
# @description request secret input (eg. passwords) and optionally apply a fallback/default value
# @param $1 variable name
# @param $2 default value
# @param $3 description
##
grab_secret_or_fallback()
{
	[ -n "$(eval echo \${$1:-})" ] && return 0
	export ${1}=""
	read -p "${3:-input}: " -s ${1}
	echo "" # move to nextline
	[ -z "$(eval echo \$$1)" ] && export ${1}="${2:-}"
	return 0
}

##
# @description ask for yes/no response via y/n
# @param $1 variable to handle input
# @param $2 description
##
grab_yes_no()
{
	[[ "$(eval echo \${$1:-})" = "y" || "$(eval echo \${$1:-})" = "n" ]] && return 0
	export ${1}=""
	until [[ "$(eval echo \$$1)" = "y" || "$(eval echo \$$1)" = "n" ]]; do
		read -p "${2:-} (yn)? " ${1}
	done
	return 0
}

# gather configuration details via user input
# grab_or_fallback "username" "root" "enter your username"
# grab_secret_or_fallback "password" "" "enter your user password"
# [ ! -f "/home/$username/.ssh/id_rsa" ] && grab_yes_no "generate_ssh_key" "create an ssh key"
# grab_or_fallback "github_username" "" "enter your github username"
# if [ -n "$github_username" ]; then
# 	if [ -f "/home/$username/.ssh/id_rsa" ] || [ "${generate_ssh_key:-}" = "y" ]; then
# 		grab_yes_no "github_ssh_key" "upload ssh key to github"
# 		[ "$github_ssh_key" = "y" ] && grab_secret_or_fallback "github_password" "" "enter your github password"
# 	fi
# fi
# grab_yes_no "workstation" "is this a workstation"
# @note: automatically assume all work/development and gaming software packages

# enable debug mode so we can witness execution
set -x

# install baseline utilities
safe_aptitude_install ssh sudo parted lm-sensors lzma unzip screen tmux vim ntp resolvconf libcurl3 git mercurial bzr subversion command-not-found

# detect & install firmware packages based on known device names
[ $(lspci | grep -ci "realtek") -gt 0 ] && safe_aptitude_install firmware-realtek
[ $(lspci | grep -i "wireless" | grep -ci "atheros") -gt 0 ] && safe_aptitude_install firmware-atheros
[ $(lspci | grep -i "wireless" | grep -ci "broadcom") -gt 0 ] && safe_aptitude_install firmware-brcm80211
[ $(lspci | grep -i "wireless" | grep -ci "intel") -gt 0 ] && safe_aptitude_install firmware-iwlwifi

# @todo: revisit nvidia installation here or within desktop block

# configure sensors
which sensors-detect &>/dev/null && (yes | sensors-detect) || true

# optimize btrfs
if [ "$(mount -t btrfs | awk '{print $3}' | grep -c '/')" -gt 0 ]; then
	export btrfs_optimizations="noatime,compress=lzo,space_cache,autodefrag"

	# create /home subvolume if it is not already a subvolume
	if [ "$(btrfs subvol list / | awk '{print $9}')" != "home" ]; then
		mv -f /home /home.bak
		btrfs subvol create /home
		find /home.bak -mindepth 1 -maxdepth 1 -exec cp -R {} /home/ \;
		rm -rf /home.bak/
	fi

	# check whether fstab already contains optimizations
	if [ $(cat /etc/fstab | grep ' / ' | grep -c "${btrfs_optimizations}") -eq 0 ]; then

		# verify if ssd is being used
		export root_partition="$(mount | awk -v dev='/' '$3==dev {print $1}')"
		export root_disk="${root_partition:5:3}"
		[ $(cat /sys/block/${root_disk}/queue/rotational) -eq 0 ] && export btrfs_optimizations="${btrfs_optimizations},ssd"

		# add optimizations
		sed -i "s;/.*btrfs.*;/\tbtrfs\t${btrfs_optimizations}\t0\t1;" /etc/fstab

		# defragment and rebalance
		set +eu
		btrfs filesystem defragment -rfclzo / &>/dev/null
		mount -n -o "remount,${btrfs_optimizations}" $root_partition /
		btrfs balance start /
		set -eu
	fi
fi

# install local files or from git repository
if [ -d data/ ]; then
	cp -fR data/* /
else
	rm -rf /tmp/system-setup
	git clone https://github.com/cdelorme/system-setup /tmp/system-setup
	cp -fR /tmp/system-setup/data/* /
fi

# install global dot-files
curl -Ls https://raw.githubusercontent.com/cdelorme/dot-files/master/install | bash -s -- -q

# add pam tally locking
[ $(grep -c "pam_tally2" /etc/pam.d/common-auth) -eq 0 ] && echo "auth required pam_tally2.so deny=4 even_deny_root onerr=fail unlock_time=600 root_unlock_time=60" >> /etc/pam.d/common-auth
[ $(grep -c "pam_tally2" /etc/pam.d/common-account) -eq 0 ] && echo "account required pam_tally2.so" >> /etc/pam.d/common-account

# fix default permissions (secure by group)
sed -i 's/UMASK\s*022/UMASK\t\t002/' /etc/login.defs
if [ $(grep -c "umask=002" /etc/pam.d/common-session) -eq 0 ]; then
	echo "session optional pam_umask.so umask=002" >> /etc/pam.d/common-session
fi

# secure & optimize ssh
sed -i "s/^#\?PermitRootLogin.*[yn].*/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/^#\?PasswordAuthentication\s*[yn].*/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i "s/^#\?GSSAPIAuthentication.*/GSSAPIAuthentication no/" /etc/ssh/sshd_config
sed -i "s/^#\?UseDNS.*/UseDNS no/" /etc/ssh/sshd_config
[ $(grep -c 'GSSAPIAuthentication no' /etc/ssh/sshd_config) -eq 0 ] && echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
[ $(grep -c 'UseDNS no' /etc/ssh/sshd_config) -eq 0 ] && echo "UseDNS no" >> /etc/ssh/sshd_config

# optimize lvm
[ -f /etc/lvm/lvm.conf ] && sed -i 's/issue_discards = 0/issue_discards = 1/' /etc/lvm/lvm.conf

# eliminate udev network persistence
if [ ! -d /etc/udev/rules.d/70-persistent-net.rules ]; then
	rm -f /etc/udev/rules.d/70-persistent-net.rules
	mkdir -p /etc/udev/rules.d/70-persistent-net.rules
fi

# disable capslock forever in favor of ctrl & reload console configuration
if [ $(grep "XKBOPTIONS" /etc/default/keyboard | grep -c "ctrl:nocaps") -eq 0 ]; then
	sed -i 's/XKBOPTIONS.*/XKBOPTIONS="ctrl:nocaps"/' /etc/default/keyboard
	dpkg-reconfigure -phigh console-setup
fi

# enable jis and load any installed fonts
[ $(grep "# ja_JP.UTF-8" -F /etc/locale.gen) -eq 0 ] || sed -i "s/# ja_JP\.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/" /etc/locale.gen
locale-gen
fc-cache -fr

# @todo: add desktop installation steps
# @todo: as part of desktop mode, try to detect battery for automatic laptop utilities & config

# update command not found archive
update-command-not-found

# install dot-files for root
find /etc/skel -mindepth 1 -maxdepth 1 -exec cp -R {} /root/ \;

# @todo: rebuild user configuration section

# # create the user & add to basic groups
# id $username &>/dev/null || useradd -m -s /bin/bash -p $(mkpasswd -m md5 "$password") $username
# usermod -aG sudo,users,disk,adm,netdev,plugdev $username
# [ "$desktop" = "y" ] && usermod -aG bluetooth,input,audio,video $username

# # generate ssh key & optionally upload to github
# if [ "$username" != "root" ] && [ "${generate_ssh_key:-}" = "y" ] && [ ! -f /home/$username/.ssh/id_rsa ]; then
# 	ssh-keygen -q -b 4096 -t rsa -N "$password" -f "/home/$username/.ssh/id_rsa"
# 	[ -d /home/$username/.ssh ] && chmod 600 /home/$username/.ssh/*
# 	if [ -f "/home/$username/.ssh/id_rsa.pub" ] && [ "${github_ssh_key:-}" = "y" ]; then
# 		curl -Li -u "${github_username}:${github_password}" -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"title\":\"$(hostname -s) ($(date '+%Y/%m/%d'))\",\"key\":\"$(cat /home/${username}/.ssh/id_rsa.pub)\"}" https://api.github.com/user/keys
# 	fi
# fi

# # prepare crontab for non-root user
# if [ "$username" != "root" ]; then
# 	export cronfile="/var/spool/cron/crontabs/${username}"
# 	[ -f "$cronfile" ] || touch "$cronfile"
# 	chown $username:crontab $cronfile
# 	chmod 600 $cronfile

# 	# update ssh keys using github account
# 	set +eu
# 	if [ -n "$github_username" ]; then
# 		[ $(grep -c "update-keys" "$cronfile") -eq 1 ] || echo "@hourly /usr/local/bin/update-keys $github_username" >> /var/spool/cron/crontabs/$username
# 		su $username -c "which update-keys &>/dev/null && update-keys $github_username"
# 	fi
# 	set -eu
# fi

# # ensure ownership for users folder
# [ -d /home/$username/.ssh ] && chown -R $username:$username /home/$username/.ssh/

# # use github username to acquire name & email from github
# if [ -n "$github_username" ]; then
# 	tmpdata=$(curl -Ls "https://api.github.com/users/${github_username}")
# 	github_name=$(echo "$tmpdata" | grep name | cut -d ':' -f2 | tr -d '",' | sed "s/^ *//")
# 	github_email=$(echo "$tmpdata" | grep email | cut -d ':' -f2 | tr -d '":,' | sed "s/^ *//")
# 	su $username -c "cd && git config --global user.name $github_username"
# 	su $username -c "cd && git config --global user.email $github_email"
# fi

# reload ssh and iptables
systemctl restart ssh
/etc/network/if-up.d/iptables

# finish with a positive exit code
exit 0
