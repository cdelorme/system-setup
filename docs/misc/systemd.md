
# Switching from sysvinit to systemd

This section, as you may have guessed, is incomplete.  By default debian uses the sysvinit boot process, and the reasons include:

- it is stable
- it is posix compatible
- it can be easily edited, as it only consists of shell scripts
- it only does one job, and that is to fire up services by run-level

The stability and easy editing are what matter to me most, while the unix philosophy tends to be an added benefit of good design.

The downsides are that:

- it is moderately slow to parallelize
- it only starts services, it does not keep them running or handle failure
- all configuration takes place in (quite often) overly complex bash scripts

On the otherhand, the systemd boot process changes the game by offering:

- automatic parallelized processes by dependency
- simplified ini files that make creating and editing easier, but provide less functionality
- uses binaries that make editing the process significnatly more difficult
- provides service monitoring and will restart crashed services

I do like the abstraction systemd offers to simplify scripting (eg. eliminating the bash scripts), but it also appears that if a service still uses a bash daemon most tools will simply launch the old bash script and not the actual service, which renders a large portion of systemd benefits moot.  The parallelized processing and process monitoring are what I find most valuable, however, the tradeoffs prevent me from making the leap on any system on which I desire stability.

I have used systemd on fedora and arch distros, and its stability was mostly terrible.  The boot speeds were exceptional.  I did not realize it was even monitoring services for failure to restart them.  Configuring its ini files is incredibly easy.  However, I experienced all sorts of crashes that stem from systemd's various tentacles.

To explain further, systemd is being tied to the latest gnome interface and binary logging tools.  Debugging errors just got way harder (not easier).  Meanwhile gnome continues to push extremely tight integration with all of its services, such as its network manager which has never once been a pleasing experience to use.

I intend to attempt systemd on my non-server system, using a different graphical user interface.  If I can manage to retain traditional logging and it remains stable I will likely add it to the steps in this file.  The next release of debian, "jessie" supposedly will have systemd as the new default bootloader, so I may give jessie a try as a shortcut to configuring systemd in wheezy.

_Keep in mind that by installing systemd I could also omit monit tools and configuration, though I do not know whether systemd offers any kind of api or web interface to determine service statuses from external sources like monit/munin do._
