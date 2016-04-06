
# [rathena setup](https://github.com/rathena/rathena)

I am documenting my attempts to provision a private server using the free and open source rAthena servers and hexed clients.  The game remains nostalgic in spite of its age; _and it sounds as though the kRO client is no-longer available through normal channels._

These instructions are tailored to work with my debian jessie installation.  It is broken into `Server` and `Client` sections, which are very different processes, _and there seems to be far less clarity around the client setup._


## [server](https://www.youtube.com/watch?v=FhvV6mYiRrU)

Setting up the server is a very easy process and can be done in a matter of minutes if you have a solid understanding of the infrastructure.


### [clone the project](https://github.com/rathena/rathena)

Start by cloning the repository, this step will provide files necessary for database configuration:

	git clone https://github.com/rathena/rathena.git
	cd rathena

_Included within are sql files and database translation utilities that let us build the latest sql files._

Let's do that next:

	cd tools/
	./convert_sql.pl --i=../db/re/item_db.txt --o=../sql-files/item_db_re.sql -t=re --m=item
	cd ..

_This updates the item database, adding support for Doram starting gear and fixing a few database item errors you may otherwise encounter._


### mysql

_While the servers may work with raw txt files, it is significantly easier to troubleshoot database errors than txt file parsing, so I recommend using a database._  Unfortunately only mysql is currently supported, and in the future I would like to propose and submit pull-requests with alternative implementations.

Install the necessary packages:

	aptitude install -ryq mysql-server libmysqlclient-dev
	mysql_secure_installation

_The installation and secure-scripts are interactive._

Using the root user, create a database and new user with appropriate permissions on that database:

	create database rathena;
	create user 'ragnarok'@'localhost' identified by 'secret';
	grant select,insert,update,delete on `rathena`.* to 'ragnarok'@'localhost';

_Using separate non-default account names helps when troubleshooting connection problems._

Now we can load everything from `sql-files/` into the database via:

	for F in sql-files/*.sql; do mysql -u root -p rathena < $F; done

_Remove the `-p` if your root user has no password._

Next let's update the default server account and add a gm account to our list:

	update `login` set `userid` = "server", `user_pass` = md5("secret") where `account_id` = 1;
	insert into `login` (account_id, userid, user_pass, sex, group_id) values (2000000, "gm", md5("secret"), "M", 99);

_If you choose accounts smaller than 4 characters, make sure you have the same settings applied to the client for the logins to work._

**New users must be registered through a registration website or by hand.**  The client will not do this for you.


### iptables

If you are configuring a VPS or a LAN instance, you will want to open ports for inbound traffic and so the system can talk to itself and users can login and play; add these rules to `/etc/iptables/iptables.rules` and reload them:

	-A INPUT -p udp --dport 6900 -m state --state NEW -j ACCEPT
	-A INPUT -p udp --dport 5121 -m state --state NEW -j ACCEPT
	-A INPUT -p udp --dport 6121 -m state --state NEW -j ACCEPT
	-A INPUT -p tcp --dport 6900 -m state --state NEW -j ACCEPT
	-A INPUT -p tcp --dport 5121 -m state --state NEW -j ACCEPT
	-A INPUT -p tcp --dport 6121 -m state --state NEW -j ACCEPT

_The default ports can be modified later if preferred in `conf/import/`._


#### patches

At the time I compiled last, the following patch was necessary to the `chclif_charlist_notify` function in `src/char/char_clif.c` to avoid crashing the client:

	void chclif_charlist_notify( int fd, struct char_session_data* sd ){
		WFIFOHEAD(fd, 6);
		WFIFOW(fd, 0) = 0x9a0;
		// pages to req / send them all in 1 until mmo_chars_fromsql can split them up
		WFIFOL(fd, 2) = (sd->char_slots>3)?sd->char_slots/3:1; //int TotalCnt (nb page to load)
		WFIFOSET(fd,6);
	}

_This change must be made prior to compiling._


### compiling renewal

Next we want to compile the server with a valid `packetver`, which is directly related to the client which it talks to.  Here is how to compile for the 20151029 client:

	./configure --enable-packetver=20151029
	make clean
	make server

_Anytime you chance the client you will need to rerun the `./configure` command first.  If you make source code changes but want the same client be sure you run `make clean` first when recompiling._


### compiling classic

Compiling for classic mode (eg. Pre-Renewal), you simply add the `--enable-prere` flag when configuring:

	./configure --enable-prere=yes --enable-packetver=20151029
	make clean
	make server

_The same client should be compatible, and the translation files used will need to be swapped._


### configuration

Fortunately, configuration can be done anytime before or after compiling and only requires that you restart the servers.  _All changes should be made to the files in `conf/import/`, as they will not get overwritten when pulling changes through version control._


**For local testing:**

Starting with `conf/import/char_conf.txt`:

	userid: server
	passwd: secret
	server_name: Elsewhere
	pincode_enabled: no
	pincode_force: no
	char_moves_unlimited: yes
	char_ip: 127.0.0.1
	login_ip: 127.0.0.1

Next is `conf/import/inter_conf.txt`:

	login_server_id: ragnarok
	login_server_pw: secret
	login_server_db: rathena
	login_case_sensitive: yes
	ipban_db_id: ragnarok
	ipban_db_pw: secret
	ipban_db_db: rathena
	char_server_id: ragnarok
	char_server_pw: secret
	char_server_db: rathena
	map_server_id: ragnarok
	map_server_pw: secret
	map_server_db: rathena
	log_db_id: ragnarok
	log_db_pw: secret
	log_db_db: rathena
	use_sql_db: yes

Next `conf/import/login_conf.txt`:

	use_MD5_passwords: yes
	new_acc_length_limit: no

Finally `conf/import/map_conf.txt`:

	userid: server
	passwd: secret
	map_ip: 127.0.0.1
	char_ip: 127.0.0.1

By default the services may try to use the WAN IP, which can lead to trouble when attempting to run a client against localhost.  Therefore, forcing all server ip's to `127.0.0.1` is the most sane way to ensure traffic flows correctly.


**Example on a VPS:**

Starting with `conf/import/char_conf.txt`:

	userid: server
	passwd: secret
	server_name: Elsewhere
	pincode_enabled: no
	pincode_force: no
	char_moves_unlimited: yes
	char_ip: ro.mydns.com
	login_ip: ro.mydns.com

Next is `conf/import/inter_conf.txt`:

	login_server_id: ragnarok
	login_server_pw: secret
	login_server_db: rathena
	login_case_sensitive: yes
	ipban_db_id: ragnarok
	ipban_db_pw: secret
	ipban_db_db: rathena
	char_server_id: ragnarok
	char_server_pw: secret
	char_server_db: rathena
	map_server_id: ragnarok
	map_server_pw: secret
	map_server_db: rathena
	log_db_id: ragnarok
	log_db_pw: secret
	log_db_db: rathena
	use_sql_db: yes

Next `conf/import/login_conf.txt`:

	use_MD5_passwords: yes
	new_acc_length_limit: no
	new_account: no

Finally `conf/import/map_conf.txt`:

	userid: server
	passwd: secret
	map_ip: ro.mydns.com
	char_ip: ro.mydns.com

_There are a great number of additional settings that can be modified, so be sure to look at the `conf/*_athena` files for a more comprehensive list of options._

Using a WAN IP for all servers on a VPS's configuration is the most sane way to get things working.

You are able to use a dns record instead of an IP address, and it will be checked at launch.  _I haven't tested this, but this may mean changing DNS after launching athena will result in the old server IP being used if you split your servers onto separate machines and need to migrate._

The `new_account` setting is helpful for quickly creating new accounts on LAN servers or when in development, and allows you to supply an unused account name and a gender to create when you login.  _For a VPS you may not want it enabled unless you want to get around setting up a registration website._


### execution

You can `start`, `stop`, and `restart` all three servers at once using the `athena-start` script:

	./athena_start start
	./athena_start restart
	./athena_start stop

_Restarting will reload configuration changes._  If running on a remote VPS you might want to launch from inside `screen` or `tmux`, so you can disconnect your remote connection without loosing access to log output.

Alternatively you can run each executable independently:

- `./map-server`
- `./login-server`
- `./char-server`

_This can help with separately identifying bugs when developing._


## [client](https://www.youtube.com/watch?v=0JpUcb3D43Y)

These are the steps to installing a customized client:

- [download kro](https://www.nickyzai.com/?p=kro) (torrent preferred)
- execute it to extract an `RO/` folder
- run the `rsu-kro-renewal-lite.exe` patcher and close the window when it completes
- download the [Translation](https://github.com/ROClientSide/Translation) then merge or replace the `data/` and `System/` folders into of `RO/`
	- **You may want to merge the files from [this translation](https://github.com/zackdreaver/ROenglishPRE) with the first for classic mode.**
- update `RO/data/clientinfo.xml` to reflect your expected server settings
- download the [latest compatible pre-modified client](https://rathena.org/board/topic/104205-2015-client-support/) (20151029)
- download [NEMO](https://github.com/MStr3am/NEMO.git) and execute it against the pre-modified client
- copy the custom client into the `RO/` folder
- add shortcuts to `RO/Setup.exe` and `RO/custom.exe` (or w/e you named it)
- run `RO/Setup.exe` and set your window size first
- launch the custom client and test that you can connect

**This is obviously a lot of work to ask of users for a private server.**  In the future I may learn how patchers work and create a tutorial for those as well.


### linux

_I am a linux junkie, so I made the same steps work on linux with a fresh PlayOnLinux 32 bit instance._  I installed `gecko`, but it probably wasn't needed, and none of the vcrun distributables were necessary.  I placed the files into `drive_c/Program Files/Gravity/RO/` to match a normal installation, and added shortcuts to `Setup` as well as the custom client.

If you encounter audio problems such as latency or crackling, you can try modifying your shortcuts `exec` to include `Exec=env PULSE_LATENCY_MSEC=60`.  _This can be adjusted until audio is improved._

If you are using multiple monitors, you may find that 3D Acceleration won't work on the second monitor.  This can be fixed by configuring wine to display a virtual desktop.  It may also improve both performance and audio.


### clientinfo.xml

Here is a sample clientinfo.xml, with valid `version` code for the 20151029 client and fixed admin accounts:

	<?xml version="1.0" encoding="euc-kr" ?>
	<clientinfo>
		<desc>Private Server Description</desc>
		<servicetype>korea</servicetype>
		<servertype>primary</servertype>
		<connection>
			<display>ServerName</display>
	      	<address>127.0.0.1</address>
	      	<port>6900</port>
	      	<version>54</version>
	      	<langtype>0</langtype>
			<registrationweb>www.ragnarok.com</registrationweb>
			<loading>
				<image>loading00.jpg</image>
				<image>loading01.jpg</image>
				<image>loading02.jpg</image>
				<image>loading03.jpg</image>
				<image>loading04.jpg</image>
			</loading>
			<yellow>
				<admin>2000000</admin>
			</yellow>
	   	</connection>
	</clientinfo>

_The `account_id` values must start at 2000000 and up, anything below will fail during login, which means you need to take care that your registration system starts even higher to reserve a predictable range for GM accounts._


### NEMO settings

Here are the settings I chose when constructing my custom client (can be loaded from `NEMO/settings.log`):

	9 Disable 1rag1 type parameters (Recommended)
	10 Disable 4 Letter Character Name Limit
	11 Disable 4 Letter User Name Limit
	12 Disable 4 Letter Password Limit
	13 Disable Ragexe Filename Check (Recommended)
	16 Disable Swear Filter
	20 Extend Chat Box
	22 Extend PM Box
	23 Enable /who command (Recommended)
	24 Fix Camera Angles (Recommended)
	29 Disable Game Guard (Recommended)
	32 Increase Zoom Out Max
	33 Always Call SelectKoreaClientInfo() (Recommended)
	34 Enable /showname (Recommended)
	35 Read Data Folder First
	36 Read msgstringtable.txt (Recommended)
	37 Read questid2display.txt (Recommended)
	38 Remove Gravity Ads (Recommended)
	39 Remove Gravity Logo (Recommended)
	40 Restore Login Window (Recommended)
	41 Disable Nagle Algorithm (Recommended)
	44 Translate Client (Recommended)
	46 Use Normal Guild Brackets (Recommended)
	47 Use Ragnarok Icon
	48 Use Plain Text Descriptions (Recommended)
	49 Enable Multiple GRFs (Recommended)
	53 Use Ascii on All LangTypes (Recommended)
	64 @ Bug Fix (Recommended)
	67 Disable Quake skill effect
	73 Remove Hourly Announce (Recommended)
	84 Remove Serial Display (Recommended)
	90 Enable DNS Support (Recommended)
	91 Disconnect to Login Window
	97 Cancel to Login Window (Recommended)
	207 Resize Font
	213 Disable Help Message on Login (Recommended)
	215 Increase Map Quality

_Some of these are personal preference, for example size 10 font on a 1920x1080 window tends to be awful from my experience._

There is a neat `Culling` setting that adds opacity to foreground elements such as tall buildings from bad angles.  This is mostly functional, but I ran into issues where water on the ship you start in was on the deck as if the ship sank.  _There could be other glitches that might actually interfere with gameplay, so be careful with this setting._


### [black background with new character at login](https://rathena.org/board/topic/105174-new-character-black-background/)

To fix this, download `OldIzlude.grf` and add it to `RO/`, then modify `RO/DATA.INI` by adding the line `1=OldIzlude.grf` before `2=data.grf` and save the file.

_The file and overview with more details can be found in the both linked by the header._


### gm clothing

Turns out if you leave `RO/data/clientinfo.xml` with the default settings, it automatically assumes the first three accounts (id's 200001-200003) are GM's and your client will not reflect clothing by job.

_Easily fixed by removing the non-GM numbers,_ though a tad confusing.


### disconnected shortly after login

If you are disconnected after it accepts your credentials, it probably indicates a problem with `RO/data/clientinfo.xml`.

For example, make sure you did not set `LangType` to anything besides 0 (eg. setting 1 for English will actually cause an error between the client and server).


### unresolved

Here are some things I have not yet figured out:

- what local setting would prevent friend registration?
- what is `RO/rdata.grf`?

First, I ran into an issue where friend registration did not work for a character on two accounts.  I tried using `/nt` or `/notrade`, and also `@noask`, but none of those fixed it.  The problem was two directional with the two accounts.

To rule out system-settings I tried logging into both accounts on the same machine, and it still did not work.

This did not rule out a system-global-setting, so I tried creating a new character on one account.  That new character had a working friend dialog.  The other direction was still automatically blocked.

I thought it was a server setting, but it seems that it's more likely a character-slot setting that applies per system, because when I created a brand new installation adding friends suddenly worked.

I do not know how else to resolve it though, so if you run into it I guess you just have to start a client from scratch, or keep a 3GB backup on your system at all times.

While the game loads `RO/data.grf` by default from `RO/DATA.INI`, some folks have mentioned loading `RO/rdata.grf` in their `RO/DATA.INI`, but I have no details on what is contained within.


## future

Future additions to this documentation may include:

- youtube video tutorials with links for setting up a server and a client
- updated iptables to reduce exposed security holes (if able, may already be locked down)
- creating a registration web server (FluxCP and custom-rigged)
- adding and supplying a patcher
- investigate the source for a first-login-account-creation pull request
- considerations for alternative DBMS options?
- try creating the login server in another language?
- custom native cross-platform client?

After I'm done updating this documentation, I plan to reboot my system and clear a spot to demonstrate the complete process on video and upload it to youtube.  _There is a significant lack of modern video material for client configuration, but many server configuration tutorials._

I need to validate my understanding of the networking communication to see if I can lock down the iptables tighter or expose less ports.  _Additionally, creating a diagram that depicts some examples of same-box and distributed models would be neat to add to the wiki._

I want to checkout FluxCP and figure out how to set it up and how it operates.  _As I am not a fan of php with modern source options, I'd also consider a custom-built alternative for registration that could expand in the future._

I still need to investigate how the patchers work so I can figure out how to simplify client-setup for potential users of an rAthena server.

It would be super for local development and LAN servers if the first-login attempt automatically created accounts.  Adding a configuration setting that is off by default but can be turned on would be really neat.  I can probably contribute this and submit a pull request, but I may ask if anyone thinks it's a feature worth adding.

I would like to see more DBMS options, such as postgres or even mongodb.  I'm partly interested in performance and resource consumption comparisons as well (mysql tends to be a pig).  I'd like to see what the barriers would be and whether there is any interest, then I could add to the conversion tool or create a new tool for the new DBMS options to build from the txt files.  Of course depending on how TXT and SQL are split from the actual code currently would directly effect the difficulty of making such a change.

The smallest components appears to be the login server, and I'd like to see what happens if I rewrote it in another language, such as go.  I'm very interested both in the performance, complexity, and potentially friendlier build tools.  However, I'd also just like a fun yet challenging project.

I am excited to see a native client written by a third party that can leverage the official assets but could be built the same way as rAthena, allowing for fully custom built stacks and significantly easier asset distribution chains where users download the official client, run the patcher for it, then put the new client in the same folder and launch it instead.  _Also, linux client would be super._  I posted my support towards a project on the rAthena forums, we can only hope...


## notes

I tried eathena before I realized it had been abandoned, and found a TXT parser bug where when using `account.txt` it expects trailing tabs or fails to parse an account, which led to hours of frustration since all of my editors trim trailing whitespace by default.

Attempts to run the latest native iRO client in WINE crashed when attempting to apply a downloaded patchfile, and I was unable to resolve it using suggestions from the wine HQ.  Probably would have worked had I started from a fresh instance.

Starting items in the `conf/char_config.txt` file are only to add a knife and clothes to a new adventurer to match the official RO system and do not support the full breadth of equipment.  _If automatically equipping new players is desired, it is suggested to write [scripts](https://rathena.org/wiki/Scripting)._

Map channels are new and confusing, apparently to space out maps for high counts of players multiple "channels" are created now, effectively loading one actual map with all players, but duplicating monsters and displaying each separately by assigned channel.  This approach allows them to scale for players as opposed to load, _since sharding maps does not solve having a thousand players in one map._  **Apparently NPCs in specific locations let you switch channels.**

The Doram race in rAthena is supported, but their starting map is devoid of monsters and NPC's and completely isolated.  **So creation is possible, but full gameplay may not yet be.**


## unsolved

I tried my hand at classic-mode, which runs but seems to have a mixture of renewal menus plus the starting area (without `OldIzlude.grf`) is unpopulated (eg. no NPC's to get you through novice training area) and therefore unplayable without some modification(s).  I may update this guide in the future if/when I have time to solve classic mode.


# references

- [rAthena Wiki](https://rathena.org/wiki/Main_Page)
- [rAthena Debian Installation](https://rathena.org/wiki/Installation_(Debian)
- [NEMO (client editor)](https://github.com/MStr3am/NEMO.git)
- [Translation (english layer for kRO)](https://github.com/ROClientSide/Translation)
- [Translation for Classic (pre-re, missing files or broken?)](https://github.com/zackdreaver/ROenglishPRE)
- [latest pre-modified client](https://rathena.org/board/topic/104205-2015-client-support/)
- [decent full stack tutorial tutorial](https://rathena.org/board/topic/104452-tutorial-how-to-create-ragnarok-offline-2015-client/?hl=%2Bragnarok+%2Boffline)
- [older client tutorial](http://herc.ws/board/topic/7602-guide-client-creation-for-the-clueless/)
- [exp rates](https://eathena.ws/wiki/index.php/Category:Configuration#Changing_the_base.2Fjob_experience_rates)
- [drop rates](https://eathena.ws/wiki/index.php/Category:Configuration#Setting_Drop_rates)
- [iro client](https://www.mediafire.com/folder/gpe5rgl13jcbw/)
- [iro wiki](http://irowiki.org/wiki/Clients_and_Patches)
- [thor patcher](http://thor.aeomin.net/)
- [native client](https://rathena.org/board/topic/104827-wip-native-ragnarok-client/)
- [suggestion to use older clients](https://rathena.org/board/topic/104634-recommendation-for-renewal-client-and-data/)
- [RO Browser Web Client](http://www.robrowser.com/)
