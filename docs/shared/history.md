
# clearing history

With linux & osx, the terminal keeps a history of commands, which is generally very useful.

However, if you find that you accidentally entered commands with personal information you can completely clean them out easily enough by running:

    history -c && history -w

If you want to use a scalpal you can edit the history file, which should be akin to `~/.bash_history` or just `~/.history`
