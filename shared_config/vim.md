
# vim

I have mixed feelings on vim.  Many times I feel it's the best editor at my disposal.  Other times I curse its existence.

_I prefer software that exists cross platform, and behaves the same cross platform.  Sadly vim does not exist everywhere, nor does it always behave the same.  This is why my primary editor (if available) is [sublime text](https://github.com/cdelorme/system-setup/tree/master/shared_config/sublime_text.md)._

However, when you spend a massive portion of your day connected to servers via ssh, vim is the **only** editor available, or at the very least the most sensible option.  It is very wise to improve your vim-foo, but more importantly to understand how to make vim behave much nicer.

First, know that there are multiple versions of vim.  Newer releases, as an example, often support newer configuration options.  There is also a vim-tiny package on debian that comes by default.  This "version" lacks full keyboard controls and is a pain to work with, so often I remove it and install vim or vim-full (varies by platform).

There are also two decent package managers for vim.  I don't use either, but [pathogen](https://github.com/tpope/vim-pathogen) and [vundle](https://github.com/gmarik/Vundle.vim) are very popular.

Configuring your vim is probably the most important step.  Here is my default configuration (`~/.vimrc`):

    " default state
    set nocompatible
    set modelines=0 enc=utf-8 ffs=unix
    set ts=4 sw=4 sts=4 expandtab shiftround
    set autoindent smartindent
    set showmode showcmd laststatus=2
    set hidden nowrap number ruler cursorline
    set ignorecase smartcase hlsearch incsearch showmatch scrolloff=3
    set backspace=indent,eol,start
    set ttyfast lazyredraw vb
    set wildmenu wildmode=list:longest
    set foldmethod=syntax foldlevelstart=20
    set nobackup noswapfile
    :silent! set undodir=$HOME/.vim/undo undolevels=1000 undoreload=10000 undofile

    " these options can improve visibility of newlines and tabs,
    "  at the cost of making it difficult to copy externally
    "set list listchars=tab:▸\ ,eol:¬

    " if you want a more pronounced divider for the 80
    "  character width entry space enable this
    "set formatoptions=qrn1 colorcolumn=85

    " mouse operation makes it harder to
    "  copy and paste outside of vim
    "set mouse=a

    " select color scheme
    set background=dark
    ":silent! colorscheme sunburst
    :silent! colorscheme vividchalk

    " set leader-key to comma
    let mapleader=","

    " clear search
    nnoremap <leader><space> :noh<cr>

    " remap inconvenient keys
    inoremap <F1> <Esc>
    nnoremap <F1> <Esc>
    vnoremap <F1> <Esc>

    " shortcut ; to : for less keys
    nnoremap ; :

    " toggle paste mode with F2
    set pastetoggle=<F2>

    " quickly edit/reload the vimrc file (,ev or ,sv)
    nmap <silent> <leader>ev :e $MYVIMRC<CR>
    nmap <silent> <leader>sv :so $MYVIMRC<CR>

    " disable noise makers
    set noeb vb t_vb=

    " auto syntax highlighting and fold-settings
    :filetype on
    :syntax on
    :filetype indent on
    filetype plugin on
    set foldmethod=syntax

    " additional file recognition
    au BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn}   set filetype=markdown

    " missing syntax recognition
    highlight BadWhitespace ctermbg=red guibg=red
    au BufRead,BufNewFile *.py match BadWhitespace /*\t\*/
    au BufRead,BufNewFile *.py match BadWhitespace /\s\+$/

    " autoconvert tabs to spaces (disabled by default for various reasons)
    " au BufWritePre * :%s/\t/    /e

    " remove trailing whitespace automatically on save
    au BufWritePre * :%s/\s\+$//e

    " remove windows carriage returns automatically
    au BufWritePre * :%s/\r//e

    " tab autocompletion
    function! Tab_Or_Complete()
        if col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w'
            return "\<C-N>"
        else
            return "\<Tab>"
        endif
    endfunction
    :inoremap <Tab> <C-R>=Tab_Or_Complete()<CR>
    :set dictionary="/usr/dict/words"

    " load plugins
    :silent! set runtimepath^=$HOME/.vim/bundle/ctrlp.vim
    :silent! :helptags $HOME/.vim/doc

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
