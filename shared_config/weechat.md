
# weechat

If you have not yet, [register a freenode account](https://freenode.net/faq.shtml).

Weechat is all command line, so it's configuration is handled via commands.

Here are my recommended settings to start with:

    /set irc.server.freenode.nicks "username, username_"
    /set irc.server.freenode.password "password"
    /set irc.server.freenode.autoconnect on
    /set weechat.history.max_buffer_lines_number 0
    /save
    /quit

_Obviously substitute your preferences as desired._

With these changes you should now have infinite history.  You will be automatically connected to freenode at boot, and it will verify your identity with NickServ.

The raw configuration itself is stored as key/value text files (traditional configuration), and can be found in `~/.weechat/` named accordingly (eg. `~/.weechat/irc.conf` and `~/.weechat/weechat.conf`, etc).  **If weechat has not yet been run, then no configuration files may exist.**
