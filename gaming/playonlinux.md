
# playonlinux

This is a [wine](https://www.winehq.org/) wrapper that has a very friendly user interface, and makes it easy to manage multiple wine environments.

I use it very specifically for older games.  I do not promote wine as an alternative to demanding linux-native releases of future games, but I (like many) simply don't want to abandon games of the past that will never see a linux-release.

Global instructions will eventually be added here, and per-game customizations will be documented separately in the future.


## language requirements

Sometimes I like to run software that requires different locale, and to get the installation and launcher to work is actually surprisingly simple.

Just change the `LANG` environment variable in the context of the application.

The most complex one is during installation.  If you launch PlayOnLinux after changing the `LANG` it runs the entire UI in another language, which can be difficult to follow.  Instead, you should use `desktop shortcuts`.

Creating a desktop shortcut will create a `.desktop` file in `~/Desktop`, which you can easily modify to exhibit the desired behavior.

Where it has `Exec=` insert `env LANG=""` immediately after the equal sign, and specify the language in standard format (eg. `en_US.UTF8` or `ja_JP.UTF8`).

When you run that shortcut, it will now launch any installer or application using the new locale, and it will run properly.
