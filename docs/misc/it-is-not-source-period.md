
#### It's Not `source` .

This is a short rant on any bash documentation that uses the `source` command.

First, [here is a reference](http://www.gnu.org/software/bash/manual/bashref.html).

The use of `.` is POSIX compliant, and supported on all distros.

The use of the `source` command is not, and is in fact not supported on many very common distros.

I absolutely hate when I read someones guide or their script and they have `source /path/to/some/shell_script`.  I know that not only that script, but anything else they have written probably won't work on half of the distros I use, and not because those distros are lacking, but because they chose to remain POSIX compliant.


##### Here are the Facts

The `.` is a bash built-in POSIX compliant command to executing the subsequent script.

The `source` command is an alias to `.`, and is not POSIX compliant.  While `.` will work on any distro and also in `sh` not just `bash`, the `source` command is only available to distros that have built bash to support it.

**If you are a `source` user... stop it!**
