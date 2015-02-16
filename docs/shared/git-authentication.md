
# git authentication

This is a problem especially on windows platforms, but also when any system you are using doesn't support ssh and requires https access.

During those cases you have to enter your credentials for **every** remote operation, which is very annoying.  Secure, maybe, not so much on windows because of viruses and keyloggers, but sure let's say it's safe to force me to enter my password for every access even 15 seconds apart.

_Or, we can simply store our credentials in a system keychain._


## windows solution

Windows is the most complicated, of course.  You will need to download and install [git-credential-winstore.exe](http://gitcredentialstore.codeplex.com/) first.

After that you can run the same configuration line:

    git config --global credential.helper git-credential-winstore.exe

_Unlike the mac and linux solutions which use the terminal for credentials, this one may open a popup when you are first asked, but subsequent requests will load from storage._


## linux solution

Linux has optional keychains, one known to work well is the `gnome-keychain`.  Make sure it is installed:

    aptitude install -ryq gnome-keychain

Then, run a configuration line for git:

    git config --global credential.helper gnome-keychain


## mac solution

This one is th easiest.  It already comes with a keychain, so you just run one command and you are set:

    git config --global credential.helper osxkeychain
