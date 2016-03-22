
# [rAthena](https://github.com/rathena/rathena)

Documenting my attempts to setup a private server using the free and open source rathena servers and hacked clients.

The game is exceedingly aged, but still actively maintained and enjoyed by many; _although it appears the kRO client is no-longer available through normal channels._

The instructions here assume you're from a debian server installation based on (or similar to) my [debian-jessie script](../debian-jessie.sh).  The steps here are listed on [rathena's own documentation](https://rathena.org/wiki/Installation_(Debian)) with far greater details.


## compiling & configuration

Start by adding these packages to your system:

	aptitude install -ryq mysql-server libmysqlclient-dev
	mysql_secure_installation

_The installation and secure-scripts are interactive._

Using the root user, create a database and new user with appropriate permissions on that database:

	create database rathena;
	create user 'ragnarok'@'localhost' identified by 'ragnarok';
	grant select,insert,update,delete on `rathena`.* to 'ragnarok'@'localhost';

_The username and database name here are only examples, ideally you should try to create unique names for each component such that you can easily track down errors._

Clone the repository and enter the folder:

	git clone https://github.com/rathena/rathena.git
	cd rathena

Start by loading the sql files in `sql-files/` into the database using your root user:

	for F in sql-files/*.sql; do mysql -u root -p < rathena; done

_There did not appear to be a recommended list of files, though some appear to be renewal-only._

At a minimum, you'll want to supply these files with non-default values for WAN IP, database credentials, and inter-server authentication:

- `conf/import/char_conf.txt`
	- `userid`
	- `passwd`
	- `char_ip` to your WAN IP
	- `login_ip` to your WAN IP
- `conf/import/map_conf.txt`
	- `userid`
	- `passwd`
	- `map_ip` to your WAN IP
	- `char_ip` to your WAN IP
- `conf/import/login_conf.txt`
	- `use_MD5_passwords: yes`
- `conf/import/inter_conf.txt`
	- `login_server_id`
	- `login_server_pw`
	- `login_server_db`
	- `ipban_db_id`
	- `ipban_db_pw`
	- `ipban_db_db`
	- `char_server_id`
	- `char_server_pw`
	- `char_server_db`
	- `map_server_id`
	- `map_server_pw`
	- `map_server_db`
	- `log_db_id`
	- `log_db_pw`
	- `log_db_db`
	- `use_sql_db: yes`

_There are a number of additional settings that can be configured here, but it's best to start small to ensure the server works first._  I do recommend the `md5` setting by default, it's silly to store plain-text passwords.  The database configuration only looks long, assuming you are using the same database then it'll just be a bunch of the same values.  Also, since we've already loaded the database, we may as well use it for the remaining resources.

_It is worth noting that you can set a DNS address instead of a WAN IP if preferred._

Next, let's update the server account, and create a GM account for later:

	update `login` set `userid` = "server", `user_pass` = md5("secret") where `account_id` = 1;
	insert into `login` (userid, user_pass, sex, group_id) values ("gmaccount", md5("secret"), "M", 99)

_If you make a name shorter than 4 characters (eg. simply `gm`), additional steps must be taken to allow that both in `conf/import/` and when building your client._

Next we have to configure for our chosen client.  **I chose to work with the 2015-10-29 client**, which had a bug that I needed to fix in `src/char/char_clif.c` by stripping the pre-compile condition from this function:

	void chclif_charlist_notify( int fd, struct char_session_data* sd ){
		WFIFOHEAD(fd, 6);
		WFIFOW(fd, 0) = 0x9a0;
		// pages to req / send them all in 1 until mmo_chars_fromsql can split them up
		WFIFOL(fd, 2) = (sd->char_slots>3)?sd->char_slots/3:1; //int TotalCnt (nb page to load)
		WFIFOSET(fd,6);
	}

Next, we can compile but we need to make sure to set the packet version first:

	./configure --enable-packetver=20151029
	make clean
	make server

_Configuration from `conf/import/` does not require recompilation, only restarting the three servers._

As a final step, add these rules to `/etc/iptables/iptables.rules` and reload them to allow traffic:

	-A INPUT -p udp --dport 6900 -m state --state NEW -j ACCEPT
	-A INPUT -p udp --dport 5121 -m state --state NEW -j ACCEPT
	-A INPUT -p udp --dport 6121 -m state --state NEW -j ACCEPT
	-A INPUT -p tcp --dport 6900 -m state --state NEW -j ACCEPT
	-A INPUT -p tcp --dport 5121 -m state --state NEW -j ACCEPT
	-A INPUT -p tcp --dport 6121 -m state --state NEW -j ACCEPT

_The default ports can be modified later if preferred in `conf/import/`._


## [client](https://www.nickyzai.com/?p=kro)

The header links to a torrent for the latest kRO client package, which comes with `rsu` patchers (both renewal and classic) that need to be run first.

Afterwards, clone the [Translation](https://github.com/ROClientSide/Translation) repository and copy the `data/` and `System/` folders into the kRO folder merging ontop of the existing `System/` folder.

Clone [NEMO](https://github.com/MStr3am/NEMO.git) to edit the client, and download the latest [pre-modified RO client](https://rathena.org/board/topic/104205-2015-client-support/).

Ideally click `Use Recommended`, then also check `Read Data Folder First` to leverage the `data/` translations.  You may also consider checking the `Use Ragnarok Icon` to help identify the executable.

Once run, place the executable into the kRO installation folder, and update the `data/clientinfo.xml` to reflect the IP or DNS of your server.  _You may also set `<version>54</version>` to avoid warnings at the server._


## wine or pol

Install from winetricks:

- vcrun6
- vcrun2008
- vcrun2010
- gecko

_To deal with audio latency/crackling try adding `PULSE_LATENCY_MSEC=60` to your launcher (eg. `exec=env PULSE_LATENCY_MSEC=60`)._

Both the `NEMO` executable and the custom client should work.


## notes

I did some preliminary investigation of eathena, which appears to have ceased activity as of December 2015.  It was lacking adequate instructions and appeared to have only begun to the migration to github (as indicated by the lack of a valid markdown readme).

When working with eathena I found strange behavior with the TXT parser where it expected a trailing tab in `account.txt`, which led to hours of frustration since all of my editors trim trailing whitespace by default.

Attempts to run the latest native iRO client in WINE crash while attempting install patches for unknown reasons.  Suggestions to install gecko or ie6 failed to resolve.

Once I have the core client steps down, I'd like to investigate how patchers work (eg. Thor and TK) to see if it is possible to distribute the modified files for a custom RO server, and the legitimacy of doing so.  _For the time being, I may simply create a downloadable tarfile for friends._

I need to build a better understanding of the communication model for optimizing and securing configuration.  _If no diagrams exist, perhaps I can create some._

It appears that the starting items in the char configuration file are only used to give new characters a knife and novice armor, and do not support the full breadth of equipment.  _If such behavior is desired, [scripts](https://rathena.org/wiki/Scripting) should be created._

It seems registration must be handled separately and cannot occur in the client itself.  _It might be nice to propose/add a `create-on-first-login` feature?_

I would really like to see an expansion of DBMS options, since I would much rather be running postgresql than mysql on my systems (performance and resource related reasons, mysql is a pig).  _It may also be interesting to compare character saving performance using document storage such as mongodb._  A major hurdle would be creating a system to convert the sql provided with the project as-is.

It might be a fun project to try converting the login server, which appears to have the smallest code-base, to another language for fun.

It might also be cool to consider adding a custom client that works with the latest version of rAthena to the rAthena source.  A cross-platform client would mean linux-native as well as compatibility in-line with whatever the latest rAthena release happens to be.  If time allows I might investigate other such custom client projects floating around the forums.

I would also like to checkout FluxCP.  I wonder if it's possible to create a CP that also doubles as a registration server.  I'm not a fan of PHP for modern solutions, so maybe I can try creating a separate but equally useful tool.


## known bugs

When I last loaded, even with the "use sql" setting, it loads files and throws:

	[Error]: skill_parse_row_requiredb: Invalid item (in ITEM_REQUIRE list) 11602 for skill 5027.
	[Error]: sv_readdb: Could not process contents of line 982 of "db/re/skill_require_db.txt".

_My assumption is it must not be an important item or skill, but I haven't investigated just yet._


# references

- [rAthena Wiki](https://rathena.org/wiki/Main_Page)
- [NEMO](https://github.com/MStr3am/NEMO.git)
- [alternative client](http://download1324.mediafire.com/v827njf9tfbg/v5dej41fgok7vra/20160113.rar)
- [tutorial](https://rathena.org/board/topic/104452-tutorial-how-to-create-ragnarok-offline-2015-client/?hl=%2Bragnarok+%2Boffline)
- [exp rates](https://eathena.ws/wiki/index.php/Category:Configuration#Changing_the_base.2Fjob_experience_rates)
- [drop rates](https://eathena.ws/wiki/index.php/Category:Configuration#Setting_Drop_rates)
- [alternate guide](http://herc.ws/board/topic/7602-guide-client-creation-for-the-clueless/)
- [iro client](https://www.mediafire.com/folder/gpe5rgl13jcbw/)
- [iro wiki](http://irowiki.org/wiki/Clients_and_Patches)
- [thor patcher](http://thor.aeomin.net/)
- [native client](https://rathena.org/board/topic/104827-wip-native-ragnarok-client/)
- [suggestion to use older clients](https://rathena.org/board/topic/104634-recommendation-for-renewal-client-and-data/)
- [latest executable client](https://rathena.org/board/topic/104205-2015-client-support/)
- [eng data folder for kro client](https://github.com/ROClientSide/Translation)
- [packet obfuscation support](https://rathena.org/board/topic/101092-packet-obfuscation-support/)
