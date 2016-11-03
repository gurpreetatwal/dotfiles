set autoindent
set tabstop=2
set shiftwidth=2
set expandtab

" Plugins
call plug#begin()
Plug 'ctrlpvim/ctrlp.vim'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'pangloss/vim-javascript'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'chriskempson/base16-vim'
Plug 'Valloric/YouCompleteMe', {'do': './install.py --tern-completer'}
call plug#end()

" General Vim Settings
set number                        " line numbers
set encoding=utf-8
set backspace=indent,eol,start    " backspace works as intended
set autoread                      " reload files if changed by other program
set cursorline                    " show horizontal cursor line
let mapleader='\<space>'
map <space> <leader>

" Mouse
set mouse=a
set ttymouse=xterm2               " needed for tmux

" Syntax
syntax on
filetype on                       " detect the type of file
filetype indent on                " Enable filetype-specific indenting
filetype plugin on                " Enable filetype-specific plugins

" Colors
set background=dark
set hlsearch
let base16colorspace=256
source ~/.vimrc_background

" Custom keybindings
"" General
nnoremap <leader>w :w<CR>

"" Copy & Paste into sytem buffer
map <leader>y "+y
map <leader>d "+d
map <leader>p "+p
map <leader>P "+P

" YouCompleteMe/Tern
"" TODO look into multi-file refactor after learning about vim's quickfix mode
"" TODO look into cursor hold for getType
nnoremap <leader>td :YcmCompleter GoToDefinition<CR>
nnoremap <leader>tt :YcmCompleter GetType<CR>
nnoremap <leader>tr :YcmCompleter GoToReferences<CR>
nnoremap <leader>tR :YcmCompleter RefactorRename
nnoremap <leader>tdoc :YcmCompleter GetDoc<CR>

" Airline Settings
set laststatus=2                " show airline even if no split exists
set showtabline=2               " show tabline even if no tabs open
let g:airline_theme='murmur'
let g:airline_powerline_fonts=1
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline_left_alt_sep=''
let g:airline_right_alt_sep=''
let g:airline_section_y=airline#section#create(['%l/%L'])
let g:airline_section_z=airline#section#create(['%v'])
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#default#section_truncate_width={
  \ 'b': 79, 'x': 60, 'y': 45, 'z': 45, 'warning': 80, 'error': 80
  \ }

" Syntastic Settings
let g:syntastic_check_on_wq=1
let g:syntastic_auto_loc_list=2
let g:syntastic_javascript_checkers=['eslint']
let g:syntastic_javascript_eslint_exe='$(npm bin)/eslint'

" CtrlP Settings
let g:ctrlp_show_hidden=1
let g:ctrlp_clear_cache_on_exit=0
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\.git$\|\.yardoc\|node_modules\|log\|tmp$',
  \ 'file': '\.so$\|\.swp|\.dat$|\.DS_Store$'
  \ }

" Vim Javascript Settings
set conceallevel=1
set concealcursor=c
let g:javascript_plugin_jsdoc=1
let g:javascript_conceal_function="λ"

" Strip Whitespace on Save
autocmd BufWritePre * :call StripTrailingWhitespaces()
function! StripTrailingWhitespaces()
    let _s=@/
    let l = line('.')
    let c = col('.')
    %s/\s\+$//e
    let @/=_s
    call cursor(l, c)
endfunction
