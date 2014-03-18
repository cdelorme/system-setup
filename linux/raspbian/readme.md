
# raspbian
#### updated on: 2014-3-17

These instructions will help with setting up an excellent and incredibly lean (resource friendly) raspbian media center.  It includes a complete openbox environment stack and a series of alternative work-flows to address common use cases that are not available in standard ways on linux and are tailored to the raspberry pi experience.

The primary objectives of this system include:

- video playback
- youtube support
- network file sharing (to access and store larger content)

**With all of these packages installed the total disk space consumed by rasbpian should be around 2.5GB, so make sure you have at least a 4GB SD card for this configuration.**

Due to the speed of the raspberry pi full configuration following these steps can take quite some time.  In the future I will have added them to my [system-setup repository](https://github.com/cdelorme/system-setup)'s automated scripts.

**_Commands within this document are context sensative, which means some may require root privileges.  If at first you don't succeed `sudo !!`!_**


## creating the installer

There are many approaches, my choice was to download the raspbian image file and directly copy it to my SD card using the `dd` command.  Since I ran it from my macbook I used the `rdisk#` format for unbuffered output:

    dd if=/path/to/raspbian.img of=/dev/rdisk1 bs=4m

_The `rdisk1` was my SD card in this case._  I have seen many instructions state to use 512k, or 1m, and different upper and lowercase combinations, as far as I can tell the sizes make very little difference besides how long the operation will take and anything between 512k and 4m is probably just fine.  **OSX uses lowercase and `xM` will error.**

Before ejecting the copied media, I make two modifications the fat32 boot partitions `config.txt` file.

I look for, and add if it is not already there, `boot_delay=1`, because without this I experience a "rainbow of death" when I start the system **after** configuration with `raspi-config`.

Next, in spite of the documentation saying that the `disable_overscan` being for video outputs besides HDMI, I found that my HDMI output was underscanned without setting it to `1`.


## installation (`raspi-config`)

It may be wise before performing any operations here to open the advanced options and update the `raspi-config` command itself.  It is also worth noting that you can update your raspberry pi's firmware with `rpi-update`.

First thing I do is expand the root partition.  Supposedly these changes do not take place until after a reboot, so at this point if you want to add a lot of stuff through `raspi-config` you may want to reboot first and manually re-run the command.

Optionally you may change or set the `pi` user password, however I remove the pi user and add my preferred username later so I omit any actions here.

Under internationalization options I make sure `en_US.UTF-8` is set (by default mine had `en_GB`).  I also add the `ja_JP.UTF-8` locale, and set `en_US` as the default.  _Pulling up this menu and applying these changes can take a few minutes._  Additionally I have to adjust my keyboard since by default it appears to have the wrong keyboard layout (though this can be done later with `dpkg-reconfigure keyboard-configuration`).  The option is buried in the second menu, the actual layout default is fine (generic 105 intl), after going forward it will have UK as the default, you need to go to other at the bottom and select US.

You _may_ want to set the desktop setting to only open terminal by default (just in case it is not already the default).

Under advanced options I change the hostname to **just** `pi`.  I also expand the split on mine to assign 128MB to the graphics.

**Obviously after all of these changes you will want to reboot the machine.**


## post-install configuration

Let's start with preparing the system for a new user account (unless you are alright keeping the `pi` user).  Login with the `pi` user, and run `sudo su` to use the root account.

I happen to have a rediculously awesome [dot-files repository](https://github.com/cdelorme/dot-files), and you should totally run the install script!  It will make your terminal far more aesthetically pleasing and even useful.  If you run it before creating a new user that new user will get these files automatically from `/etc/skel`.  You can download and run the install script simply with:

    aptitude clean && aptitude update && aptitude upgrade -y && aptitude install -yq git wget curl unzip
    wget "https://raw2.github.com/cdelorme/dot-files/master/install"
    chmod +x install
    ./install github_username

_For more information about additional arguments you can supply, please read the instructions._

Next run `passwd` to set the root password.

Now create a new user and set their password with:

    useradd -s /bin/bash -m username
    passwd username

_Now that we have a root password we should `exit` twice to get back to the login and login directly as root to delete the `pi` user:_

    userdel pi
    rm -rf /home/pi


## package management

Let's start by purging a massive list of packages to reduce the number of trouble-areas, which includes unused graphical tools:

    aptitude purge -yq aptitude alsa-base alsa-utils aspell-en blt console-setup consolekit cups-bsd cups-common dbus-x11 desktop-base dictionaries-common dillo fontconfig fontconfig-config  fonts-droid galculator gconf2 gconf2-common gdb gksu gnome-themes-standard gsfonts gsfonts-x11 icelib idle idle-python2.7 idle-python3.2 idle3 leafpad lesstif2 libarchive12 libasound2 libaspell15 libatasmart4 libavcodec53 libbluetooth3 libbluray1 libboost-iostreams1.46.1 libboost-iostreams1.48.0 libboost-iostreams1.49.0 libboost-iostreams1.50.0 libcairo-gobject2 libcairo2 libcdio-cdda1 libcdio-paranoia1 libcdio13 libcolord1 libcroco3 libcups2 libcupsimage2 libcurl3 libdirac-encoder0 libdirectfb-1.2-9 libexif12 libflac8 libfltk1.3 libfm-gtk-bin libfm-gtk1 libfm1 libfontconfig1 libfontenc1 libfreetype6 libgail-3-0 libgail18 libgconf-2-4 libgd2-xpm libgdk-pixbuf2.0-0 libgdu0 libgeoclue0 libgfortran3 libgif4 libgksu2-0 libgl1-mesa-glx libglade2-0 libglapi-mesa libgnome-keyring0 libgphoto2-2 libgphoto2-port0 libgs9 libgsm1 libgstreamer-plugins-base0.10-0 libgstreamer0.10-0 libgtk-3-0 libgtk-3-bin libgtk-3-common libgtk2.0-0 libgtk2.0-common libgtop2-7 libhunspell-1.3-0 libice6 libid3tag0 libimlib2 libimobiledevice2 libjack-jackd2-0 libjasper1 libjavascriptcoregtk-1.0-0 libjavascriptcoregtk-3.0-0 libjson0 liblapack3 liblcms1 liblcms2-2 liblightdm-gobject-1-0 libmad0 libmenu-cache1 libmikmod2 libmng1 libmp3lame0 libnotify4 libobrender27 libobt0 libogg0 libopenjpeg2 libpango1.0-0 libpci3 libpciaccess0 libplist1 libpng12-0 libpoppler19 libportmidi0 libpulse0 libpython2.7 libqt4-svg libqtgui4 libqtwebkit4 libraspberrypi0 librsvg2-2 librtmp0 libsamplerate0 libschroedinger-1.0-0 libsdl-image1.2 libsdl-mixer1.2 libsdl-ttf2.0-0 libsdl1.2debian libsgutils2-2 libsm6 libsmbclient libsmpeg0 libsndfile1 libsoup-gnome2.4-1 libsoup2.4-1 libspeex1 libthai0 libtheora0 libtiff4 libts-0.0-0 libunique-1.0-0 libusbmuxd1 libvorbisenc2 libvorbisfile3 libvpx1 libvte9 libwebkitgtk-1.0-0 libwebkitgtk-3.0-0 libwebp2 libwebrtc-audio-processing-0 libwnck22 libx11-6 libx11-xcb1 libx264-123 libxau6 libxaw7 libxcb-glx0 libxcb-render0 libxcb-shape0 libxcb-shm0 libxcb-util0 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxdmcp6 libxext6 libxfixes3 libxfont1 libxft2 libxi6 libxinerama1 libxkbfile1 libxklavier16 libxml2 libxmu6 libxmuu1 libxp6 libxpm4 libxrandr2 libxrender1 libxres1 libxslt1.1 libxss1 libxt6 libxtst6 libxv1 libxvidcore4 libxxf86dga1 libxxf86vm1 lightdm lightdm-gtk-greeter lxappearance lxde-common lxde-icon-theme lxmenu-data lxpolkit lxrandr lxtask lxterminal menu-xdg midori netsurf-gtk obconf omxplayer openbox pciutils pcmanfm policykit-1 poppler-data pulseaudio python-support python3 python3.2 python3.2-minimal scratch shared-mime-info squeak-vm tasksel tcl8.5 tsconf udisks wpagui x11-common x11-utils xarchiver xfonts-utils xinit xpdf xserver-xorg xserver-xorg-core fuse gettext-base gnome-accessibility-themes gnome-themes-standard-data libasprintf0c2 libasyncns0 libaudit0 libavutil51 libcaca0 libfftw3-3 libfile-copy-recursive-perl libfm-data libfuse2 libgs9-common libijs-0.35 libjbig2dec0 libmtdev1 libpaper-utils libpaper1 libqt4-dbus libqt4-network libqt4-xml libqtdbus4 libspeexdsp1 libsystemd-daemon0 libva1 libvte-common libwebkitgtk-3.0-common libwnck-common qdbus rtkit update-inetd zenity-common debian-reference-common debian-reference-en

_This process will also remove aptitude itself, which we will want to reinstall after:_

    apt-get install aptitude

Then to cleanup run:

    apt-get autoremove
    aptitude clean
    aptitude autoclean
    aptitude update
    aptitude upgrade -yq

**Unfortunately we are not yet at a stage where we can use `netselect-apt`, so while the package can be downloaded there is no matching `mirrors_full` format url for raspbian (yet).**

Next we want to install a set of packages to make the system more usable from command line.  Here is a complete list of packages I would advise you to install:

    aptitude install -ryq firmware-linux firmware-linux-free firmware-linux-nonfree usbutils uuid-runtime cpufrequtils bzip2 lzop p7zip-full zip unzip xz-utils unace rzip unalz zoo arj ssh curl ntp rsync whois vim git mercurial libncurses5-dev kernel-package build-essential fakeroot e2fsprogs parted sshfs fuse-utils exfat-fuse exfat-utils fusesmb os-prober sudo bash-completion command-not-found tmux screen bc less keychain pastebinit anacron miscfiles markdown rpi-update tasksel python-setuptools pciutils ffmpeg udisks lm-sensors libraspberrypi0 libraspberrypi-bin

If you expect to experiment with the breadboard at some point you should reinstall these packages:

    aptitude install -ryq oracle-java7-jdk wolfram-engine scratch squeak-vm smartsim

_Not installing them can save you almost half a gigabyte of space._

To use `command-not-found` we need to run this with root privileges (then again as our own user):

    update-command-not-found


### fixing log files

Both raspbian and debian use `rsyslog` for logging, as well as `logrotate`.  By default it tries to adhere to a permission scheme using an `adm` group for read permissions on all files.

If you want your user to be able to access the log files you must add them to the `adm` group like so:

    usermod -aG adm username

Also worth noting is that the permissions on the log files are not perfect, there are bugs.  Some of them are root only.

To fix root-only log files, you will want to update the settings inside `/etc/logrotate.conf` and `/etc/logrotate.d/*`, where the `create` command is either missing or specifically has root-only ownership.

After you have applied these patches you will still need to fix the permissions on the existing files, which can be done with a recursive chown:

    chown -R root:adm /var/log/*


### patching `mathkernel`

If you see messages relating to mathkernel and LSB, then you need to copy the LSB headers inside `/etc/init.d/skeleton` into the top of `/etc/init.d/mathkernel` to get rid of them.


### patching `wolfram-engine`

If you are getting errors regarding the wolfram-engine at anytime, you may have run these to delete already created symlinks (_since the post-install wolfram-engine configuration runs does not check if they already exist, and the purge never removed them_):

    rm /usr/share/icons/nuoveXT2/*/mimetypes/application-mathematic*
    rm /usr/share/icons/nuoveXT2/*/mimetypes/application-vnd.wolfram*

Afterwards you will want to rerun `aptitude upgrade` to reconfigure `wolfram-engine`:

    aptitude upgrade -yq


### setting timezone

By default raspbian will assume UTC time, to set your own timezone, do something like this:

    ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime


## installing a desktop environment

My primary experiences with linux user interfaces in the past have been with gnome.  I have done a large amount of reading on various desktop environments, as well as the various linux distributions that employ them, and I concluded that I still prefer a raw debian plus a custom configured openbox.

Systems like CrunchBang (or even pibang) are absolutely fantastic, but they stick you with a set of packages and you become dependent on their custom repo configurations and compiled versions of key UI software.

In no way is that meant to sound bad or insulting, as crunchbang and any similarly styled environments are an absolute pleasure to use, I find it easier to work with a bare bones setup and fully understand how everything intermingles.  When a distro does all of that for me, I learn nothing which is not my goal when using any linux software.

Let's start with a fresh install of all the graphical packages we will need:

    aptitude install -ryq desktop-base openbox obconf omxplayer tint2 conky kupfer chromium youtube-dl zenity zenity-common pcmanfm alsa-base alsa-utils pulseaudio fontconfig fontconfig-config fonts-droid shared-mime-info feh hsetroot avahi-utils xinit slim rxvt-unicode arandr clipit xscreensaver xfce4-volumed

_Some of these packages or their dependencies may already be installed from our terminal packages._


### configure `lm-sensors`

The `lm-sensors` package is used by `conky`, and should be configured after it is installed.  This can be done (as root or with sudopowers) via:

    yes | sensors-detect

_If you do use sudo, do as after the pipe.  Note that this should fail on raspberry pi since many of the sensors do not exist and this will cause `lm-sensors` to throw a fit.._


### configure `omxplayer`

For video playback we should be adding our user to the `video` group, like so:

    usermod -aG video username

_If you get playback errors regarding `vchiq`, then you may have to run this command to fix permissions:_

    chmod a+rw /dev/vchiq

With those changes, you should not be able to play most videos without a problem from command line!


### configure `youtube-dl`

Let's start by preparing out `youtube-dl` package by running this **twice** (with privileges):

    youtube-dl -U
    youtube-dl -U

_Currently this is the only way I have gotten youtube video playbakc working with raspbian._


### installing & configuring python whitey for youtube

_I have yet to get `whitey` working in raspbian, but I did in pibang.  I assume it must be a missing dependency or package version conflict._

The `whitey` python package is a command line youtube interface utility built in python, that uses `youtube-dl` to download the video, and `omxplayer` (or `mplayer`) to play the video.  As a result it is slow, since it will download a video before playback occurs.  However it is the best option available to you on the raspberry pi currently, as html5 and flash are not.

While the `whitey` package is available through `easy_install` with python, the latest fixes are only available through the github repository.

To install it from github:

    git clone https://github.com/rjw57/yt.git
    cd py
    python setup.py install

To install it with `easy_install`:

    easy_install whitey

The `whitey` package adds two commands, `yt`, and `pi-yt`.  The `pi-yt` is meant to be a raspberry pi tailored command, and should default to omxplayer.

If you used `easy_install` however, you will need to manually patch the missing parameter code.  The updated source can be found [in the repo](https://github.com/rjw57/yt/blob/master/src/yt/__init__.py).  We can find our local copy of the file at `/usr/local/lib/python2.7/dist-packages/whitey-0.4-py2.7.egg/yt/__init__.py`, and the method we need to fix is `main_with_omxplayer`, and it needs to have these five new lines and one modified line to pass the `args` variable:

    parser.add_argument('--player', default=OMXPLAYER_MODE)
    parser.add_argument('--novideo', default=False)
    parser.add_argument('--bandwidth', type=int)
    parser.add_argument('--audio', default='local')
    args = parser.parse_args()

    ui = Ui(args)

It should now work exactly as desired.


## installing custom fonts

This step is optional, but I keep two fonts in my [system-setup repository](https://github.com/cdelorme/system-setup) which I tend to install on most systems.  One is for clean readable japanese character support, and the other is excellent for programming and user-interface.

Run these commands to download and install them:

    mkdir ~/.fonts
    cd ~/.fonts
    wget "https://github.com/cdelorme/system-setup/raw/develop/data/osx/Library/Fonts/ForMateKonaVe.ttf"
    wget "https://github.com/cdelorme/system-setup/raw/develop/data/osx/Library/Fonts/epkyouka.ttf"
    fc-cache -fr

Any additional fonts of your choosing can be placed into that same folder, and you can reload the system font cache in order for the software to see the newly added fonts.


### patching pulseaudio & adding user privileges

For audio to work correctly we want to do a couple of things.  Let's start by adding our user(s) to the `audio` group:

    usermod -aG audio username

Now to avoid problems with pulse audio configuration, we want to set the `/etc/defaults/pulseaudio` variable `PULSEAUDIO_SYSTEM_START` to `1` to launch it as a daemon at boot time.  This should not cause any harm, but it will eliminate the warnings at boot and shutdown.


### configuring slim

By default `slim` on install should be configured to run at boot time.  If there are conflicting login managers it should display a configuration menu, but if no menu was displayed you may have to either rerun its configuration **or** reinstall it.  If it is installed and configuration is set properly you may have to tell the system to load it at boot time.

To rerun the configuration:

    dpkg-reconfigure slim

To reinstall and configure slim:

    aptitude reinstall -ry slim

_If there are conflicting login managers it should display an ncurses menu for you to select from.  Ideally you should remove any conflicting login managers (such as `lightdm`)._

To tell slim to load with the system at boot time (for sysvinit):

    update-rc.d slim defaults

_The systemd approach is different._

By default slim will check your `~/.xinitrc` file to launch your chosen window manager, but if you have not configured one or wish to try a different window manager simply pressing `f1` will toggle various preconfigured `xinitrc` files, which is just one of many awesome features in slim.


### configuring openbox

This is where the difficulty level skyrockets for openbox.  Being as flexible as it is comes with the price of required knowledge.  Hopefully this section will help explain and simplify the configuration process.

First it is important to understand that openbox is configured using xml files.  Second it stores custom configuration in your home directory at `~/.config/openbox`.  We can simplify things at the start by copying the defaults and working from there:

    mkdir ~/.config/openbox
    cd ~/.config/openbox
    cp /var/lib/openbox/* .
    cp /etc/xdg/openbox/* .

Anytime you modify these files you will have to reload your configuration with:

    openbox --reconfigure

Now let's discuss which files we can edit, and what they will do!

First, there is a `menu.xml` which is the primary menu that openbox will display when you right click!  Editing this allows you to change the whole menu stack.  The `debian-menu.xml` is the popup menu that appears in the main menu, and you can create as many similar instances to this as you like.

The `rc.xml` is the window managers behavior, and is where you can adjust things like the theme, or the hotkeys and other behavior.

The last two are not xml configuration files, but boot-time executable scripts.  The `autostart` script is where you should place any launcher script lines, such as to start services like `conky` and `tint2` to enhance your desktop experience.  The `environment` script is loaded per application, and can be used to set a series of application specific environment configuration data, including variables.


#### modifying `rc.xml`

- @TODO


#### my modified `menu.xml`

- @TODO: enhance

This is what my openbox `menu.xml` looks like:

    <?xml version="1.0" encoding="UTF-8"?>

    <openbox_menu xmlns="http://openbox.org/"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://openbox.org/ file:///usr/share/openbox/menu.xsd">

        <menu id="root-menu" label="Openbox 3">
            <item label="pcmanfm">
                <action name="Execute"><execute>pcmanfm</execute></action>
            </item>
            <item label="chromium">
                <action name="Execute"><execute>x-www-browser</execute></action>
            </item>
            <item label="urxvt">
                <action name="Execute"><execute>x-terminal-emulator</execute></action>
            </item>

            <!--custom menu here-->

            <!-- This requires the presence of the 'menu' package to work -->
            <separator />
            <menu id="client-list-menu" />
            <separator />
            <menu id="/Debian" />
            <separator />

            <item label="reload ob">
                <action name="Reconfigure" />
            </item>
            <item label="restart ob">
                <action name="Restart" />
            </item>
            <item label="logout | exit">
                <action name="Exit">
                    <prompt>no</prompt>
                </action>
            </item>
            <separator />
            <item label="reboot">
                <action name="Execute"><execute>sudo reboot</execute></action>
            </item>
            <item label="shutdown">
                <action name="Execute"><execute>sudo shutdown -h 0</execute></action>
            </item>
        </menu>

    </openbox_menu>

**The above configuration is not yet complete.**


#### launching openbox with `startx`

By default startx looks for a `~/.xinitrc` and will execute its contents.  Add the following lines to `~/.xinitrc` to launch openbox:

    #!/bin/sh
    exec openbox-session

With this you can manually start openbox via `startx`!  Ideally you should set the `~/.xinitrc` file as executable:

    chmod +x ~/.xinitrc


#### setting or changing default web browser and terminal

There is no `one size fits all` default software configuration utility, however the `update-alternatives` package does some very important ones.

For our first example let's change the default terminal to `rxvt-unicode` with:

    update-alternatives --set x-terminal-emulator /usr/bin/urxvt

_If you do not know which software to use, you can use `--config` instead of `--set` and provide no software path, and it will present you with a numbered list to pick from._

Let's do the same with our web browser by selecting chromium after running this:

    update-alternatives --set x-www-browser /usr/bin/chromium


#### configuring clipit

Our clipboard stores its configuration files per user at `~/.config/clipit/clipitrc`.  If you have tint2 running you should be able to load the UI for its preferences, but you can also change them by modifying that file directly.

These are the lines I change specifically:

    [rc]
    use_copy=true
    use_primary=false
    synchronize=false
    automatic_paste=false
    show_indexes=false
    save_uris=true
    use_rmb_menu=false
    save_history=false
    history_limit=50
    items_menu=20
    statics_show=true
    statics_items=10
    hyperlinks_only=false
    confirm_clear=false
    single_line=true
    reverse_history=false
    item_length=50
    ellipsize=2
    history_key=<Ctrl><Alt>H
    actions_key=<Ctrl><Alt>A
    menu_key=<Ctrl><Alt>P
    search_key=<Ctrl><Alt>F


#### configuring conky

Through a myriad of theft, experimentation, and customization I have created not just a single `~/.conkyrc`, but an entire `~/.conkyrc/` folder of configurations, which vary by purpose.  Since the raspberry pi is a lower powered machine I limit it to two conky configs, generally `system` or `system-light` and `logs`.  The `system` config includes more details and a list of hotkeys I configured, but it may consume a bit of power on the system so I recommend using `system-light`.

The `~/.conkyrc/system-light` configuration consists of the following:

- @TODO

For basic systems I have my `~/.conkyrc/system` config:

    ##
    # System Conky
    #
    # @version raspbian
    # @author Casey DeLorme <cdelorme@gmail.com>
    ##

    ##
    # general
    ##
    background yes
    update_interval 2.0
    cpu_avg_samples 3
    net_avg_samples 3
    diskio_avg_samples 3
    double_buffer yes
    no_buffers yes

    ##
    # display
    ##
    own_window yes
    own_window_hints undecorated,below,sticky,skip_taskbar,skip_pager
    own_window_transparent yes
    alignment middle_right
    gap_x 25
    use_xft yes
    xftalpha 0.2
    xftfont ForMateKonaVe:size=9
    uppercase no
    override_utf8_locale yes
    maximum_width 240
    default_color a7a7a7

    ##
    # raspbery pi transparent bg via lua
    ##
    lua_load ~/.conkyrc/scripts/lua/bg
    lua_draw_hook_pre draw_bg

    ##
    # content
    ##
    TEXT
    ##
    # system
    ##
    ${color e43526}S Y S T E M ${color 2f4f4f}${hr 1}${color}
      Username:$alignr
      Hostname:$alignr$nodename
      Kernel:$alignr${kernel ($machine)}
      Uptime:$alignr$uptime
      RAM:   $mem/$memmax${alignr}${membar 6,60}
      Swap:  $swap/$swapmax${alignr}${swapbar 6,60}
      CPU:   ${cpu cpu1}% ${alignr}${cpubar cpu1 6,60}
      ${cpugraph 20,205 fef7b2 e18522 -t}

    ##
    # disk space & io
    ##
    ${color e43526}D I S K S ${color 2f4f4f}${hr 1}${color}
      /:  ${fs_used /} / ${fs_size /} ${alignr}${fs_bar 6,40 /}

      Read${alignr}Write
      ${diskiograph_read 20,100 fef7b2 e18522 -t}${alignr}${diskiograph_write 20,100 fef7b2 e18522 -t}

    ##
    # network
    ##
    ${color e43526}N E T W O R K ${color 2f4f4f}${hr 1}${color}
      IP Address: ${addr}
      Down${alignr}Up
      ${downspeedgraph 20,100 fef7b2 ff0000 -t}${alignr}${upspeedgraph 20,100 fef7b2 00ff00 -t}
      Current: ${downspeed eth0}${alignr}${upspeed eth0}
      Total:   ${totaldown eth0}${alignr}${totalup eth0}

    ##
    # processes
    ##
    ${color e43526}P R O C E S S E S ${color 2f4f4f}${hr 1}${color}
      Count: ${processes}${alignr}Threads: ${threads}

      By CPU:${goto 95}PID   CPU%   MEM%
       ${top name 1}${goto 80}${top pid 1} ${top cpu 1} ${top mem 1}
       ${top name 2}${goto 80}${top pid 2} ${top cpu 2} ${top mem 2}
       ${top name 3}${goto 80}${top pid 3} ${top cpu 3} ${top mem 3}

      By RAM:${goto 95}PID   CPU%   MEM%
       ${top_mem name 1}${goto 80}${top_mem pid 1} ${top_mem cpu 1} ${top_mem mem 1}
       ${top_mem name 2}${goto 80}${top_mem pid 2} ${top_mem cpu 2} ${top_mem mem 2}
       ${top_mem name 3}${goto 80}${top_mem pid 3} ${top_mem cpu 3} ${top_mem mem 3}

    ##
    # hotkeys
    ##
    ${color e43526}H O T K E Y S ${color 2f4f4f}${hr 1}${color}

The second one I use is to monitor logs.  Your user must be a member of the `adm` group, or whichever group has access to `/var/logs` files.  It's contents are stored at `~/.conkyrc/logs`:

    ##
    # Logs Conky
    #
    # @version raspbian
    # @author Casey DeLorme <cdelorme@gmail.com>
    ##

    ##
    # general
    ##
    background yes
    update_interval 5.0
    double_buffer yes

    ##
    # display
    ##
    own_window yes
    own_window_hints below,skip_pager,skip_taskbar,undecorated,sticky
    own_window_transparent yes
    alignment middle_left
    gap_x 100
    use_xft yes
    xftalpha 0.2
    xftfont ForMateKonaVe:size=7
    xftalpha 0
    uppercase no
    override_utf8_locale yes
    default_color a7a7a7

    ##
    # rapsberry pi transparant bg via lua
    ##
    lua_load ~/.conkyrc/scripts/lua/bg
    lua_draw_hook_pre draw_bg

    ##
    # content
    ##
    TEXT
    /var/log/auth.log:${hr 1}
    ${exec tail -n10 /var/log/syslog | tac}

    /var/log/auth.log:${hr 1}
    ${exec tail -n10 /var/log/auth.log | tac}

    /var/log/kern.log:${hr 1}
    ${exec tail -n10 /var/log/kern.log | tac}

    /var/log/Xorg.0.log:${hr 1}
    ${exec tail -n10 /var/log/Xorg.0.log | tac}

My conky configurations also depend on some lua scripts for support.  To add a transparent background I create a file at `~/.conkyrc/scripts/lua/bg` with:

    -- dependencies
    require 'cairo'

    -- settings
    bg_colour = 0x000000
    bg_alpha = 0.6
    corner_r = 0

    -- rgb converter
    function rgb_to_r_g_b(colour,alpha)
        return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
    end

    -- primary bg function
    function conky_draw_bg()
        if conky_window == nil then return end
        local w = conky_window.width
        local h = conky_window.height

    -- create starting point (x/y)
        local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, w, h)
        cr = cairo_create(cs)

    -- draw a box to fill
        cairo_move_to(cr, corner_r, 0)
        cairo_line_to(cr, w-corner_r, 0)
        cairo_curve_to(cr, w, 0, w, 0, w, corner_r)
        cairo_line_to(cr, w, h-corner_r)
        cairo_curve_to(cr, w, h, w, h, w-corner_r, h)
        cairo_line_to(cr, corner_r, h)
        cairo_curve_to(cr, 0, h, 0, h, 0, h-corner_r)
        cairo_line_to(cr, 0, corner_r)
        cairo_curve_to(cr, 0, 0, 0, 0, corner_r, 0)
        cairo_close_path(cr)

    -- set fill color and fill
        cairo_set_source_rgba(cr, rgb_to_r_g_b(bg_colour, bg_alpha))
        cairo_fill(cr)

    end

To launch conky with openbox I simply add these lines to the `~/.config/openbox/autostart` file:

    # look for and launch conky
    if which conky &> /dev/null
    then
        (conky -d -q -c "$HOME/.conkyrc/system-light") &
        (conky -d -q -c "$HOME/.conkyrc/logs") &
    fi

_Generally conky will give your temperature data as well from the `lm-sensors` package, but the raspberry pi does not appear to have any so no temperatures will work._


#### creating a feh script to cycle background images

The first step is preparing a directory and storing your choice of wallpapers there.  Let's go with `~/.wallpaper/`:

    mkdir ~/.wallpaper

Once you have enough wallpaper images of your choosing you can easily set the wallpaper using the `feh` command via:

    feh --bg-scale ~/.wallpaper/image.jpg

_There are several options, for example `--bg-scale` will size the image to fit the screen, which can warp it.  Alternatives include `--bg-fill` which will treat the screen as a minimum bounding box which cuts off parts of the image, or `--bg-max` which treats the screen size as a max bounding box.  Unfortunately the max bounding box only allows black borders, which isn't pretty either.  Currently `feh` has no means of setting both a background image and also a custom border color._

When you have set a background it will store the last feh command in `~/.fehbg`, which means you can load that file from `~/.config/openbox/autostart` to set the previous wallpaper at boot:

    # look for and launch feh bg
    if [ -f ~/.fehbg ]
    then
        . ~/.fehbg
    fi

The final stage is to have the background update every so often by telling feh to randomize its selection.  Simply modify `~/.fehbg` to contain these lines:

    #!/bin/sh

    # fine infinite loop with 30 minute delay
    fehloop() {
        while true
        do

            # sleep for another 5 minutes
            sleep 300

            # change wallpaper
            feh -q --no-fehbg --bg-fill $(find "$HOME/.wallpaper" -type f | sort -R | tail -1)

        done
    }

    # set first wallpaper synchronous
    feh -q --no-fehbg --randomize --bg-fill "$HOME/.wallpaper/"*

    fehloop &

_I found that feh's `--randomize` flag was consistently picking the same image, so my script uses another approach._


#### configuring openbox autostart

My autostart checks for services before running them, whether you choose to continue the trend and keep your shell error-free is up to you.

The configuration file is found at `~/.config/openbox/autostart`, and here are my suggested contents:

    #!/bin/sh

    # begin script for desktop background cycles
    if [ -f "$HOME/.fehbg" ] && [ -d ~/.wallpaper/ ] && [ $(find ~/.wallpaper/ -type f | wc -l) -gt 0 ]
    then
        . "$HOME/.fehbg"
    else

        # set solid bg color
        (hsetroot -solid "#2E3436")
    fi

    # look for and launch tint2
    if which tint2 &> /dev/null
    then
        (tint2) &
    fi

    # clipboard manager
    if which clipit &> /dev/null
    then
        (clipit) &
    fi

    ##
    # keyboard repeat 250ms delay, 25 per second
    # and turn on/off system beep
    ##
    xset r rate 250 25 &
    xset b off &

    # start up xscreensaver if able
    if which xscreensaver &> /dev/null
    then
        (xscreensaver -no-splash) &
    fi

    # load xfce volume controls
    xfce4-volumed &

    # load kupfer for quick-launch
    if which kupfer &> /dev/null
    then
        (kupfer --no-splash) &
    fi

    # look for and launch conky
    if which conky &> /dev/null
    then
        (conky -d -q -c "$HOME/.conkyrc/system-light") &
        (conky -d -q -c "$HOME/.conkyrc/logs") &
    fi

Also, make sure that the autostart file is executable:

    chmod +x ~/.config/openbox/autostart


#### configuring tint2

- @TODO


#### configuring uxvrt (`rxvt-unicode`)

- @TODO


#### configuring `pcmanfm`

- @TODO


#### configure `xscreensaver`

The easy way is to either copy and paste mine below, or run `xscreensaver-demo` and configure it:

    # XScreenSaver Preferences File
    # Written by xscreensaver-demo 5.15 for cdelorme on Mon Mar 17 00:11:56 2014.
    # http://www.jwz.org/xscreensaver/

    timeout:    0:15:00
    cycle:      0:05:00
    lock:       False
    lockTimeout:    0:00:00
    passwdTimeout:  0:00:30
    visualID:   default
    installColormap:    True
    verbose:    False
    timestamp:  True
    splash:     True
    splashDuration: 0:00:05
    demoCommand:    xscreensaver-demo
    prefsCommand:   xscreensaver-demo -prefs
    nice:       10
    memoryLimit:    0
    fade:       True
    unfade:     False
    fadeSeconds:    0:00:03
    fadeTicks:  20
    captureStderr:  True
    ignoreUninstalledPrograms:False
    font:       *-medium-r-*-140-*-m-*
    dpmsEnabled:    False
    dpmsQuickOff:   False
    dpmsStandby:    2:00:00
    dpmsSuspend:    2:00:00
    dpmsOff:    4:00:00
    grabDesktopImages:  False
    grabVideoFrames:    False
    chooseRandomImages: True
    imageDirectory: /home/cdelorme/.wallpaper

    mode:       random
    selected:   -1

    textMode:   url
    textLiteral:    XScreenSaver
    textFile:
    textProgram:    fortune
    textURL:    http://planet.debian.org/rss20.xml

    programs:                                     \
    -               maze -root                  \n\
    - GL:               superquadrics -root             \n\
    -               attraction -root                \n\
    -               blitspin -root                  \n\
    -               greynetic -root                 \n\
    -               helix -root                 \n\
    -               hopalong -root                  \n\
    -               imsmap -root                    \n\
    -               noseguy -root                   \n\
    -               pyro -root                  \n\
    -               qix -root                   \n\
    -               rocks -root                 \n\
    -               rorschach -root                 \n\
    -               decayscreen -root               \n\
    -               flame -root                 \n\
    -               halo -root                  \n\
                    slidescreen -root               \n\
    -               pedal -root                 \n\
    -               bouboule -root                  \n\
    -               braid -root                 \n\
    -               coral -root                 \n\
                    deco -root                  \n\
    -               drift -root                 \n\
    -               fadeplot -root                  \n\
                    galaxy -root                    \n\
    -               goop -root                  \n\
    -               grav -root                  \n\
    -               ifs -root                   \n\
    - GL:               jigsaw -root                    \n\
    -               julia -root                 \n\
    -               kaleidescope -root              \n\
    - GL:               moebius -root                   \n\
    -               moire -root                 \n\
    - GL:               morph3d -root                   \n\
    -               mountain -root                  \n\
    -               munch -root                 \n\
                    penrose -root                   \n\
    - GL:               pipes -root                 \n\
    -               rd-bomb -root                   \n\
    - GL:               rubik -root                 \n\
    -               sierpinski -root                \n\
    -               slip -root                  \n\
    - GL:               sproingies -root                \n\
    -               starfish -root                  \n\
    -               strange -root                   \n\
                    swirl -root                 \n\
    -               triangle -root                  \n\
    -               xjack -root                 \n\
                    xlyap -root                 \n\
    - GL:               atlantis -root                  \n\
    -               bsod -root                  \n\
    - GL:               bubble3d -root                  \n\
    - GL:               cage -root                  \n\
    -               crystal -root                   \n\
    -               cynosure -root                  \n\
    -               discrete -root                  \n\
                    distort -root                   \n\
    -               epicycle -root                  \n\
    -               flow -root                  \n\
    - GL:               glplanet -root                  \n\
    -               interference -root              \n\
    -               kumppa -root                    \n\
    - GL:               lament -root                    \n\
    -               moire2 -root                    \n\
    - GL:               sonar -root                 \n\
    - GL:               stairs -root                    \n\
    -               truchet -root                   \n\
    -               vidwhacker -root                \n\
    -               blaster -root                   \n\
    -               bumps -root                 \n\
    -               ccurve -root                    \n\
    -               compass -root                   \n\
    -               deluxe -root                    \n\
    -               demon -root                 \n\
    - GL:               extrusion -root                 \n\
    -               loop -root                  \n\
    -               penetrate -root                 \n\
    -               petri -root                 \n\
    -               phosphor -root                  \n\
    - GL:               pulsar -root                    \n\
                    ripples -root                   \n\
                    shadebobs -root                 \n\
    - GL:               sierpinski3d -root              \n\
    -               spotlight -root                 \n\
    -               squiral -root                   \n\
    -               wander -root                    \n\
    -               webcollage -root                \n\
    -               xflame -root                    \n\
    -               xmatrix -root                   \n\
    - GL:               gflux -root                 \n\
    -               nerverot -root                  \n\
    -               xrayswarm -root                 \n\
    -               xspirograph -root               \n\
    - GL:               circuit -root                   \n\
    - GL:               dangerball -root                \n\
    - GL:               engine -root                    \n\
    - GL:               flipscreen3d -root              \n\
    - GL:               gltext -root                    \n\
    - GL:               menger -root                    \n\
    - GL:               molecule -root                  \n\
    -               rotzoomer -root                 \n\
    -               speedmine -root                 \n\
    - GL:               starwars -root                  \n\
    - GL:               stonerview -root                \n\
    -               vermiculate -root               \n\
    -               whirlwindwarp -root             \n\
    -               zoom -root                  \n\
    -               anemone -root                   \n\
    -               apollonian -root                \n\
    - GL:               boxed -root                 \n\
    - GL:               cubenetic -root                 \n\
    - GL:               endgame -root                   \n\
    -               euler2d -root                   \n\
    -               fluidballs -root                \n\
    - GL:               flurry -root                    \n\
    - GL:               glblur -root                    \n\
    - GL:               glsnake -root                   \n\
    -               halftone -root                  \n\
    - GL:               juggler3d -root                 \n\
    - GL:               lavalite -root                  \n\
    -               polyominoes -root               \n\
    - GL:               queens -root                    \n\
    - GL:               sballs -root                    \n\
    - GL:               spheremonics -root              \n\
    -               thornbird -root                 \n\
    -               twang -root                 \n\
    - GL:               antspotlight -root              \n\
    -               apple2 -root                    \n\
    - GL:               atunnel -root                   \n\
    -               barcode -root                   \n\
    - GL:               blinkbox -root                  \n\
    - GL:               blocktube -root                 \n\
    - GL:               bouncingcow -root               \n\
    -               cloudlife -root                 \n\
    - GL:               cubestorm -root                 \n\
    -               eruption -root                  \n\
    - GL:               flipflop -root                  \n\
    - GL:               flyingtoasters -root                \n\
    -               fontglide -root                 \n\
    - GL:               gleidescope -root               \n\
    - GL:               glknots -root                   \n\
    - GL:               glmatrix -root                  \n\
    - GL:               glslideshow -root               \n\
    - GL:               hypertorus -root                \n\
    - GL:               jigglypuff -root                \n\
                    metaballs -root                 \n\
    - GL:               mirrorblob -root                \n\
    -               piecewise -root                 \n\
    - GL:               polytopes -root                 \n\
    -               pong -root                  \n\
                    popsquares -root                \n\
    - GL:               surfaces -root                  \n\
    -               xanalogtv -root                 \n\
                    abstractile -root               \n\
    -               anemotaxis -root                \n\
    - GL:               antinspect -root                \n\
    -               fireworkx -root                 \n\
                    fuzzyflakes -root               \n\
    -               interaggregate -root                \n\
    -               intermomentary -root                \n\
    -               memscroller -root               \n\
    - GL:               noof -root                  \n\
    -               pacman -root                    \n\
    - GL:               pinion -root                    \n\
    - GL:               polyhedra -root                 \n\
    - GL:               providence -root                \n\
    -               substrate -root                 \n\
    -               wormhole -root                  \n\
    - GL:               antmaze -root                   \n\
    - GL:               boing -root                 \n\
    -               boxfit -root                    \n\
    - GL:               carousel -root                  \n\
    -               celtic -root                    \n\
    - GL:               crackberg -root                 \n\
    - GL:               cube21 -root                    \n\
                    fiberlamp -root                 \n\
    - GL:               fliptext -root                  \n\
    - GL:               glhanoi -root                   \n\
    - GL:               tangram -root                   \n\
    - GL:               timetunnel -root                \n\
    - GL:               glschool -root                  \n\
    - GL:               topblock -root                  \n\
    - GL:               cubicgrid -root                 \n\
                    cwaves -root                    \n\
    - GL:               gears -root                 \n\
    - GL:               glcells -root                   \n\
    - GL:               lockward -root                  \n\
                    m6502 -root                 \n\
    - GL:               moebiusgears -root              \n\
    - GL:               voronoi -root                   \n\
    - GL:               hypnowheel -root                \n\
    - GL:               klein -root                 \n\
    -               lcdscrub -root                  \n\
    - GL:               photopile -root                 \n\
    - GL:               skytentacles -root              \n\
    - GL:               rubikblocks -root               \n\
    - GL:               companioncube -root             \n\
    - GL:               hilbert -root                   \n\
    - GL:               tronbit -root                   \n\
    -               unicode -root                   \n\


    pointerPollTime:    0:00:05
    pointerHysteresis:  10
    windowCreationTimeout:0:00:30
    initialDelay:   0:00:00
    GetViewPortIsFullOfLies:False
    procInterrupts: True
    xinputExtensionDev: False
    overlayStderr:  True


#### configuring `kupfer`

We want kupfer to launch as error-free as possible, and automatically with openbox.

The first step I take is modifying (or creating) its configuration file at `~/.config/kupfer/kupfer.cfg` to contain these lines:

    [plugin_firefox]
    kupfer_enabled = False

    [plugin_vim]
    kupfer_enabled = True

    [plugin_chromium]
    kupfer_enabled = True

    [plugin_epiphany]
    kupfer_enabled = False

    [Tools]
    terminal = kupfer.plugin.core.urxvt

_The current versions firefox bookmarks plugin is bugged._

Next to get openbox to launch it I add these lines to `~/.config/openbox/autostart`:

    # load kupfer for quick-launch
    if which kupfer &> /dev/null
    then
        (kupfer --no-splash) &
    fi

Now when I have logged in I can use `ctrl+space` and begin typing to launch applications.  Obviously it can do a lot more if you take the time to sift through the various plugins.


### cleanup & bugfixes

I found some files in the file system that were not necessary (either at all or any longer), and removed them:

    rm ~/pistore.desktop
    rm -rf ~/.thumbnails
    rm -rf ~/.fontconfig

**I am still investigating a bug related to gnome keyring failing to store cache data.**


## **Kickass alternative workflows in linux**

Linux is not windows, and it is not OSX either.  It has its own tools and work best for specific jobs.  Learning these tools to accomplish everyday tasks is in the interest of any user who wishes to rely more on linux, and this section is dedicated to help others adjust to and identify those tasks.

THe `omxplayer` on raspberry pi is deliciously good, it's a terminal based video player, and takes up very few resources so playback of HD content is excellent.  It is the system around which most of these workflows are based.


### youtube like a boss

Ideally the `whitey` package should work allowing you to search for, download, and playback videos off of youtube.

**Unfortunately at this time I have not gottan `whitey` to work on raspbian, in the future I may update these instructions._

Without `yt` or `pi-yt` you can still use `youtube-dl` to download videos, and your web browser to find the urls.

Then you can playback the videos using omxplayer.  _Granted, this is not a streaming solution, so it may not be a perfect approach._


### network playback

The raspberry pi has two USB ports, and a 10/100 ethernet jack.

You can use the 10/100 or a USB wireless device to access networked storage, or a USB drive for data storage and direct playback.  _I recommend the network drive via nfs or smb._

With a mounted drive and omxplayer you're all set to watch videos over the network on your micro-computer.


# references

- [purge raspbian gui](http://www.raspberrypi.org/phpBB3/viewtopic.php?f=36&t=35519)
- [dot-files repository](https://github.com/cdelorme/dot-files)
- [keybindings for omxplayer (ignores UI settings)](http://omxplayer.sconde.net/)
- [system-setup repository](https://github.com/cdelorme/system-setup)
- [crunchbang configs](https://github.com/corenominal/cb-configs)
- [crunchbang's awesome conky](https://github.com/corenominal/cb-configs/blob/master/skel/.conkyrc)
- [some conky configs](https://bbs.archlinux.org/viewtopic.php?pid=1084822)
- [gorgeous conky](http://walkero.gr/post/50586862655/my-latest-conky-script)
- [conky settings](http://conky.sourceforge.net/config_settings.html)
- [conky variables](http://conky.sourceforge.net/variables.html)
- [wallpaper site](http://wallpaperswa.com/)
- [slim manual](http://slim.berlios.de/manual.php)


# future objectives

- try and get viewnior compiled because it's a nice lightweight picture viewer
- try and find a means of adding netflix support
