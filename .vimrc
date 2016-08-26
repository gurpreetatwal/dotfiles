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
Plug 'Valloric/YouCompleteMe', {'do': './install.py --tern-completer'}
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
let g:airline_theme="papercolor"
let g:airline_powerline_fonts=1

" Syntastic Settings
let g:syntastic_check_on_wq=1
let g:syntastic_check_on_open=1
let g:syntastic_auto_loc_list=2
let g:syntastic_javascript_checkers=['eslint']
let g:syntastic_javascript_eslint_exe='$(npm bin)/eslint'
