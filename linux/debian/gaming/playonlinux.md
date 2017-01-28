
# playonlinux

This is a [wine](https://www.winehq.org/) wrapper that has a very friendly user interface, and makes it easy to manage multiple wine environments.

I use it very specifically for older games.  I do not promote wine as an alternative to demanding linux-native releases of future games, but I (like many) simply don't want to abandon games of the past that will never see a linux-release.

Global instructions will eventually be added here, and per-game customizations will be documented separately in the future.


## compatible

Here are the games I have successfully played on linux:

- 100% Orange Juice
- Borderlands
- Bunny Must Die!
- Caster (the game itself is damn glitchy)
- Coixleur Sigma
- Diablo 2
- Diablo 3
- The Elder Scrolls V: Skyrim
- Final Fantasy VII (steam version, no cloud sync)
- Final Fantasy VIII (steam version, no cloud sync)
- [Final Fantasy XIV: A Realm Reborn](ffxiv.md)
- Fortune Summoners: Secret of the Elemental Stone
- The Last Remnant
- Recettear: An Item Shop's Tale
- SCP: Containment Breach
- Skullgirls
- Valdis Story Abyssal City
- Ys I
- Ys II
- Ys Origin
- Ys: The Oath in Felghana

Some games have specific problems, such as with audio or full-screen modes.

Many problems can be solved by checking [winehq](https://www.winehq.org/) for missing dependencies.

For controller support, nothing beats the [koku-xinput-wine](https://github.com/KoKuToru/koku-xinput-wine) repository.

In the case of Diablo II there was a very helpful [modification](http://www.gamersonlinux.com/forum/threads/diablo-ii-expansion-guide.217/) that also helps even on windows.


## broken

These are the games I was unable to run:

- Project Root

_This game crashes with two dialogs, starting with `CGfxSystem::CreateEx` which yields absolutely no google search results.  Oddly enough I could find nothing to debug this further with._


## language requirements

Sometimes I like to run software that requires different locale, and to get the installation and launcher to work is actually surprisingly simple.

Just change the `LANG` environment variable in the context of the application.

The most complex one is during installation.  If you launch PlayOnLinux after changing the `LANG` it runs the entire UI in another language, which can be difficult to follow.  Instead, you should use `desktop shortcuts`.

Creating a desktop shortcut will create a `.desktop` file in `~/Desktop`, which you can easily modify to exhibit the desired behavior.

Where it has `Exec=` insert `env LANG=""` immediately after the equal sign, and specify the language in standard format (eg. `en_US.UTF8` or `ja_JP.UTF8`).

When you run that shortcut, it will now launch any installer or application using the new locale, and it will run properly.
