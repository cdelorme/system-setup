#!/bin/bash -eux

##
# define reusable operations
##

# @todo: update these operations to require input and continue asking until provided
grab_no_fallback()
{
	[ -n "$(eval echo \${$1:-})" ] && return 0
	export ${1}=""
	read -p "${3:-input}: " ${1}
	[ -z "$(eval echo \$$1)" ] && export ${1}="${2:-}"
	return 0
}

grab_secret_no_fallback()
{
	set +x
	[ -n "$(eval echo \${$1:-})" ] && set -x && return 0
	export ${1}=""
	read -p "${3:-input}: " -s ${1}
	echo "" # move to nextline
	[ -z "$(eval echo \$$1)" ] && export ${1}="${2:-}"
	set -x
	return 0
}

grab_yes_no()
{
	[[ "$(eval echo \${$1:-})" = "y" || "$(eval echo \${$1:-})" = "n" ]] && return 0
	export ${1}=""
	until [[ "$(eval echo \$$1)" = "y" || "$(eval echo \$$1)" = "n" ]]
	do
		read -p "${2:-} (yn)? " ${1}
	done
	return 0
}

brew_install() {
	brew install "$@"
	sudo -v
}


##
# acquire sudo privileges
##

echo "this script will require sudo privileges..."
sudo echo "ok"


##
# ask for required inputs
##

grab_no_fallback "github_username" "please enter your github username"
[ "$github_username" ] && grab_secret_no_fallback "github_upassword" "please enter your github password"
[ ! -s ~/.ssh/id_rsa ] && grab_secret_no_fallback "ssh_key_password" "please enter a password for your ssh key"
grab_yes_no "do you want to install multimedia tools" "install_multimedia_tools"
grab_yes_no "do you want to install development tools" "install_dev_tools"
[ "$install_dev_tools" = "y" ] && grab_yes_no "install_node" "do you want to install node"
[ "$install_dev_tools" = "y" ] && grab_yes_no "install_go" "do you want to install go"



# @note: temporary exit while testing behavior
exit 0



##
# here be dragons
##

# install fonts
mkdir -p ~/Library/Fonts
[ ! -f ~/Library/Fonts/ForMateKonaVe.ttf ] && curl -Lo ~/Library/Fonts/ForMateKonaVe.ttf "https://github.com/cdelorme/system-setup/raw/master/data/usr/share/fonts/truetype/jis/ForMateKonaVe.ttf"
[ ! -f ~/Library/Fonts/epkyouka.ttf ] && curl -Lo ~/Library/Fonts/epkyouka.ttf "https://github.com/cdelorme/system-setup/raw/master/data/usr/share/fonts/truetype/jis/epkyouka.ttf"

# install markdown quicklook generator
if [ ! -f /tmp/qlgen.zip ]
then
	curl -Lo /tmp/qlgen.zip "https://github.com/toland/qlmarkdown/releases/download/v1.3.5/QLMarkdown.qlgenerator.zip"
	(cd /tmp && unzip /tmp/qlgen.zip)
	[ ! -d /Library/QuickLook/QLMarkdown.qlgenerator ] && sudo mv /tmp/QLMarkdown.qlgenerator /Library/QuickLook/
fi

# install dot-files & reload ~/.bash_profile
if [ ! -s ~/.bash_profile ]
then
	sudo -v
	curl -L "https://raw.githubusercontent.com/cdelorme/dot-files/master/install" | bash -s -- -q
	. ~/.bash_profile

	# install vim packages & fonts
	mkdir -p ~/.vim/colors
	if [ ! -d /tmp/vim-ctrlp ]
	then
		git clone "https://github.com/kien/ctrlp.vim" /tmp/vim-ctrlp
		find /tmp/vim-ctrlp/* -maxdepth 0 -type d -exec cp -R {} ~/.vim/ \;
	fi
	if [ ! -d /tmp/vim-json ]
	then
		git clone "https://github.com/elzr/vim-json" /tmp/vim-json
		find /tmp/vim-json/* -maxdepth 0 -type d -exec cp -R {} ~/.vim/ \;
	fi
	if [ ! -d /tmp/vim-node ] && [ "$install_node" = "y" ]
	then
		git clone "https://github.com/moll/vim-node" /tmp/vim-node
		find /tmp/vim-node/* -maxdepth 0 -type d -exec cp -R {} ~/.vim/ \;
	fi
	if [ ! -d /tmp/vim-go ] && [ "$install_go" = "y" ]
	then
		git clone "https://github.com/fatih/vim-go" /tmp/vim-go
		find /tmp/vim-go/* -maxdepth 0 -type d -exec cp -R {} ~/.vim/ \;
	fi
	[ ! -f ~/.vim/colors/vividchalk.vim ] && curl -Lso ~/.vim/colors/vividchalk.vim "https://raw.githubusercontent.com/tpope/vim-vividchalk/master/colors/vividchalk.vim"
	[ ! -f ~/.vim/colors/sunburst.vim ] && curl -Lso ~/.vim/colors/sunburst.vim "https://raw.githubusercontent.com/tangphillip/SunburstVIM/master/colors/sunburst.vim"

	# download ~/.git-completion
	[ ! -f ~/.git-completion ] && curl -Lso ~/.git-completion "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
fi

# download authorized_keys & configure git
if [ -n "$github_username" ]
then
	curl -Lo ~/.ssh/authorized_keys "https://github.com/${github_username}.keys"

	# use github username to acquire name & email from github
	tmpdata=$(curl -Ls "https://api.github.com/users/$github_username")
	github_name=$(echo "$tmpdata" | grep name | cut -d ':' -f2 | tr -d '",' | sed "s/^ *//")
	github_email=$(echo "$tmpdata" | grep email | cut -d ':' -f2 | tr -d '":,' | sed "s/^ *//")
	git config --global user.name "$github_username"
	git config --global user.email "$github_email"
	git config --global credential.helper osxkeychain
fi

# generate ssh keys & load using -K & upload to github
if [ ! -s ~/.ssh/id_rsa ]
then
	[ -n "$ssh_key_password" ] && ssh-keygen -q -b 4096 -t rsa -N "$ssh_key_password" -f ~/.ssh/id_rsa

	# @todo: verify this bypasses prompt for password entry when loading ssh key password into osx keychain
	echo "$ssh_key_password" | ssh-add -K ~/.ssh/id_rsa

	if [ -s ~/.ssh/id_rsa.pub ] && [ -n "$github_username" ] && [ -n "github_password" ]
	then
		curl -Li -u "${github_username}:${github_password}" -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"title\":\"$(hostname -s) ($(date '+%Y/%m/%d'))\",\"key\":\"$(cat $HOME/.ssh/id_rsa.pub)\"}" https://api.github.com/user/keys

		# acquire or create re-usable homebrew token
		keys=$(curl -s -i -u "${github_username}:${github_password}" -H "Content-Type: application/json" -H "Accept: application/json" -X GET https://api.github.com/authorizations)
		if echo $keys | grep "homebrew" &> /dev/null
		then
		    token=$(echo "${keys#*homebrew}" | grep token | head -n1 | tr -d '":,' | awk '{print $2}')
		else
		    keys=$(curl -i -u "${github_username}:${github_password}" -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"scopes\":[\"gist\",\"repo\",\"user\"],\"note\":\"homebrew\"}" https://api.github.com/authorizations)
		    token=$(echo "$keys" | grep token | head -n1 | tr -d '":,' | awk '{print $2}')
		fi

		# load token into `~/.bash_profile`
		if [ -n "$token" ]
		then
		    echo -ne "\n# homebrew github token (remove rate-limiting)\nexport HOMEBREW_GITHUB_API_TOKEN=${token}" >> ~/.bash_profile
			. ~/.bash_profile
		fi
	fi
fi

# install homebrew
if ! which brew &>/dev/null
then
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	sudo -v

	# add brew updater
	if ! which brewgrade &>/dev/null
	then
		echo "#!/bin/bash" > ~/.brewgrade
		echo "/usr/local/bin/brew update" >> ~/.brewgrade
		echo "/usr/local/bin/brew upgrade" >> ~/.brewgrade
		echo "/usr/local/bin/brew cleanup" >> ~/.brewgrade
		echo "/usr/local/bin/brew doctor" >> ~/.brewgrade
		chmod +x ~/.brewgrade
		sudo mv ~/.brewgrade /usr/local/bin/brewgrade
		sudo -v
	fi
fi

# install basic brew packages
brew_install --override-system-vi vim
brew_install tmux
brew_install git
brew_install openssl
brew_install wget
brew_install Caskroom/cask/osxfuse
brew_install Caskroom/cask/sshfs
brew_install mplayer

# mutlimedia tools
if [ "$install_multimedia_tools" = "y" ]
then
	brew_install lame
	brew_install jpeg
	brew_install faac
	brew_install libvorbis
	brew_install x264
	brew_install openh264
	brew_install xvid
	brew_install theora
	brew_install graphicsmagick
	brew_install imagemagick
	brew_install swftools
	brew_install --with-tools ffmpeg
	brew_install sdl2_gfx
	brew_install sdl2_image
	brew_install sdl2_mixer
	brew_install sdl2_net
	brew_install sdl2_ttf
	brew_install sdl_gfx
	brew_install sdl_image
	brew_install sdl_mixer
	brew_install sdl_net
	brew_install sdl_rtf
	brew_install sdl_sound
	brew_install sdl_ttf
	brew_install sfml
	brew_install homebrew/versions/glfw3
fi

# developer tools
if [ "$install_dev_tools" = "y" ]
then
	brew_install mercurial
	brew_install svn
	brew_install bzr
	brew_install awscli
	brew_install Caskroom/cask/vagrant
	brew_install docker-machine
	brew_install docker-compose
	brew_install terraform

	# asynchronously initialize docker-machine and add to `~/.bash_profile`
	(docker-machine create --driver virtualbox default && echo 'eval $(docker-machine env default)' >> ~/.bash_profile) && echo '[ "$(docker-machine status)" != "Running" ] && docker-machine start' >> ~/.bash_profile &
fi

# install (latest) youtube-dl
if ! which youtube-dl &>/dev/nul
then
	sudo curl "https://yt-dl.org/downloads/2016.03.06/youtube-dl" -o /usr/local/bin/youtube-dl
	sudo chmod +x /usr/local/bin/youtube-dl
	youtube-dl -U
	sudo -v
fi

# install node version manager /w latest stable node
if ! which npm &>/dev/null && [ "$install_node" = "y" ]
then
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash
	. ~/.bash_profile
	nvm install stable
	nvm alias default stable
fi

# install go version manager /w go1.6
if ! which go &>/dev/null && [ "$install_go" = "y" ]
then
	bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
	. ~/.bash_profile
	gvm install go1.4.3
	gvm use go1.4.3
	echo "export GOROOT_BOOTSTRAP=$GOROOT" >> ~/.bash_profile
	gvm install go1.6
	gvm use go1.6 --default
fi

# create and load crontab to update the system @daily
echo "@daily /usr/local/bin/brewgrade" > ~/.crontab
echo "@daily /usr/local/bin/youtube-dl -U" >> ~/.crontab
crontab ~/.crontab
