
# transmission

The `transmission-daemon` package is fantastic and I highly recommend it in contrast to most who suggest `rtorrent`.  In my experience transmission is cleaner, easier to configure, and has far better interface options for modern software.

My suggested base configuration can be found [here](../data/extras/etc/transmission-daemon/settings.json).  _Anytime you want to change the configuration you must stop the transmission service first, since it writes the current configuration on exist which will delete any changes you make beforehand._

File ownership is one thing you'll need to correct by adding yourself to the same group as the default created by transmission during installation:

	# add user to group
	usermod -aG debian-transmission username


## quirks

In my opinion there are two quirks I have found with transmission while attempting to run it as a server service.

- file ownership can lead to unexpected behavior
- lack of post-processing behavior is as debilitating as `rtorrent`

While you can give transmission a `watchDir`, it will be unable to read files with your own group applied.  _Using sticky-bits can address this, but you still have to manually drop files there then yourself, **and moving files will in fact evade sticky-bits and those files will never get loaded, so you have to cp the files and delete the originals.**_

The second problem is that there is a lack of states that trigger scripted events.  Primarily there is a state when the download has completed, but not when you have hit your desired seeding ratio.

To address both of these problems I craft a [go-transmission-helper](https://github.com/cdelorme/go-transmission-api), which can be compiled and run in your crontab from the same machine to automatically torrent files from a path of your choosing, and to automatically clear torrents in a true finished state.

_It may be equally possible to run `transmission-daemon` in userspace with a custom `systemctl` unit file, but I have not spent the time to verify the setup._


## iptables

While you may find dynamic port mapping works well enough, I prefer fixed ports.

Here is how to open the default peer traffic port:

	# tranmission peer traffic (default port 51413)
	-A INPUT -p udp -m udp --dport 51413 -j ACCEPT

For the web interface here is how you can lock it down to the current machine:

	# transmission web interface restricted-local-access
	-A INPUT -s 127.0.0.1 -p tcp -m tcp --dport 9091 -j ACCEPT

_You could also use a local address and subnet mask to allow anyone on the same private network to access (eg. `192.168.0.0/24`)._
