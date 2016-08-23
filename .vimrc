set autoindent
set tabstop=2
set shiftwidth=2
set expandtab
set background=dark

" Plugins
call plug#begin()
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()

" General Vim Settings
set number                        " line numbers
set encoding=utf-8
set backspace=indent,eol,start    " backspace works as intended
set autoread                      " reload files if changed by other program

" Mouse
set mouse=a
set ttymouse=xterm2               " needed for tmux

" Syntax
syntax on
filetype on                       " detect the type of file
filetype indent on                " Enable filetype-specific indenting
filetype plugin on                " Enable filetype-specific plugins

" Airline Settings
let g:airline_powerline_fonts=1
let g:airline_theme="papercolor"
