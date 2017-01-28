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
	aptitude install -fryq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "$@" 2>&1 | tee /tmp/aptitude.log
	if [ $(grep -c "E: Failed" /tmp/aptitude.log) -ne 0 ] || [ $(grep -c "W: Failed" /tmp/aptitude.log) -ne 0 ]
	then
		safe_aptitude_install $@
	fi
}

# loop read-input until env var is populated
grab_input() {
	until [ -n "$(eval echo \${$1:-})" ]; do
		read -p "${2:-input}: " ${1}
	done
}

# loop hidden read-input until env var is populated
grab_password() {
	until [ -n "$(eval echo \${$1:-})" ]; do
		read -p "${2:-input}: " -s ${1}
		echo ""
	done
}

# loop read-input until env var is populated with y or n
grab_yn() {
	until [[ "$(eval echo \${$1:-})" = "y" || "$(eval echo \${$1:-})" = "n" ]]; do
		read -p "${2:-input} (y/n)? " ${1}
	done
}

# gather configuration details via user input
grab_yn "workstation" "is this a workstation"

# enable debug mode so we can witness execution
set -x

# install baseline utilities
safe_aptitude_install ssh sudo parted lm-sensors lzma unzip screen tmux vim ntp resolvconf libcurl3 git mercurial bzr subversion command-not-found

# set vim.basic as the default editor
update-alternatives --set editor /usr/bin/vim.basic

# detect & install firmware packages based on known device names
[ $(lspci | grep -ci "realtek") -gt 0 ] && safe_aptitude_install firmware-realtek
[ $(lspci | grep -i "wireless" | grep -ci "atheros") -gt 0 ] && safe_aptitude_install firmware-atheros
[ $(lspci | grep -i "wireless" | grep -ci "broadcom") -gt 0 ] && safe_aptitude_install firmware-brcm80211
[ $(lspci | grep -i "wireless" | grep -ci "intel") -gt 0 ] && safe_aptitude_install firmware-iwlwifi

# configure sensors
which sensors-detect &>/dev/null && (yes | sensors-detect) || true

# optimize uefi boot
if [ -f /boot/efi/EFI/debian/grubx64.efi ]; then
	mkdir -p /boot/efi/EFI/boot
	echo "FS0:\EFI\debian\grubx64.efi" > /boot/efi/startup.nsh
	cp -f /boot/efi/EFI/debian/grubx64.efi /boot/efi/EFI/boot/bootx64.efi
fi

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

# install base data files
if [ -d linux/debian/data/base ]; then
	cp -fR linux/debian/data/base/* /
else
	([ -d /tmp/system-setup ] && cd /tmp/system-setup && git pull ) || git clone https://github.com/cdelorme/system-setup /tmp/system-setup
	cp -fR /tmp/system-setup/linux/debian/data/base/* /
fi

# install global dot-files
curl -Ls https://raw.githubusercontent.com/cdelorme/dot-files/master/install | bash -s -- -q

# reboot after timeout on kernel panic
[ $(grep -c "panic=10" /etc/default/grub) -eq 0 ] && sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 panic=10"/' /etc/default/grub
[ $(grep -c "panic = 10" /etc/sysctl.conf) -eq 0 ] && echo "kernel.panic = 10" >> /etc/sysctl.conf

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

# update command not found archive
update-command-not-found

# install dot-files for root
find /etc/skel -mindepth 1 -maxdepth 1 -exec cp -R {} /root/ \;

# reload ssh and iptables
systemctl restart ssh
/etc/network/if-up.d/iptables

# finish with a positive exit code
[ "${workstation:-n}" != "y" ] && exit 0

echo "configuration workstation"
