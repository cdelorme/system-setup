
# vim

I have mixed feelings on vim.  Many times I feel it's the best editor at my disposal.  Other times I curse its existence.

_I prefer software that exists cross platform, and behaves the same cross platform.  Sadly vim does not exist everywhere, nor does it always behave the same.  This is why my primary editor (if available) is [sublime text](sublime-text.md)._

However, when you spend a massive portion of your day connected to servers via ssh, vim is the **only** editor available, or at the very least the most sensible option.  It is very wise to improve your vim-foo, but more importantly to understand how to make vim behave much nicer.

First, know that there are multiple versions of vim.  Newer releases, as an example, often support newer configuration options.  There is also a vim-tiny package on debian that comes by default.  This "version" lacks full keyboard controls and is a pain to work with, so often I remove it and install vim or vim-full (varies by platform).

There are also two decent package managers for vim.  I don't use either, but [pathogen](https://github.com/tpope/vim-pathogen) and [vundle](https://github.com/gmarik/Vundle.vim) are very popular.

Configuring your vim is probably the most important step.  I have a very light weight [`~/.vimrc`](https://github.com/cdelorme/dot-files/blob/master/src/.vimrc), which I install in any new system that I setup.

I can also recommend quite a number of plugins:

- [ctrlp](https://github.com/kien/ctrlp.vim)
- [json](https://github.com/elzr/vim-json)
- [sparkup](https://github.com/tristen/vim-sparkup)
- [easymotion](https://github.com/Lokaltog/vim-easymotion)
- [surround](https://github.com/tpope/vim-surround)
- [emmet](https://github.com/mattn/emmet-vim.git)

Color schemes also help make things much more readable.  Here are two I can recommend:

- [VividChalk](https://github.com/tpope/vim-vividchalk)
- [Sunbirst](https://github.com/tangphillip/SunburstVIM.git)

I created a [dot-files](https://github.com/cdelorme/dot-files) repository to help resolve many of the pains of setting up a new system.  It automates installing and configuring a large core of my system, including vim and shell enhancements.  If you want a nice and simple solution, check it out.
