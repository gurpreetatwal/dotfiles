set autoindent
set tabstop=2
set shiftwidth=2
set expandtab

" Plugins
call plug#begin()
Plug 'chriskempson/base16-vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'edkolev/tmuxline.vim'
Plug 'gurpreetatwal/vim-avro'
Plug 'scrooloose/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'sjl/gundo.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'w0rp/ale'
call plug#end()

" General Vim Settings
set encoding=utf-8
set number                        " line numbers
set incsearch                     " highlight search matches as you type
set wildmenu                      " show autocomplete menu for vim commands
set backspace=indent,eol,start    " backspace works as intended
set autoread                      " reload files if changed by other program
set cursorline                    " show horizontal cursor line
set scrolloff=5                   " always show 5 lines above and below cursor
set sidescrolloff=5               " always show 10 characters to left and right of line
let mapleader='\<space>'
map <space> <leader>

" Mouse
set mouse=a
if !has('nvim')
  set ttymouse=xterm2             " needed for tmux
endif

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
nnoremap <C-g> :GundoToggle<CR>
nnoremap <leader>w :w<CR>

"" Copy & Paste into sytem buffer
map <leader>y "+y
map <leader>d "+d
map <leader>p "+p
map <leader>P "+P

" Plugin Settings
"" gundo
let g:gundo_width=30
let g:gundo_preview_height=20
let g:gundo_preview_bottom=1    " show the preview under the current window
let g:gundo_close_on_revert=1   " close gundo after reverting
let g:gundo_prefer_python3=1    " needed for python3 support

"" YouCompleteMe/Tern
""" TODO look into multi-file refactor after learning about vim's quickfix mode
""" TODO look into cursor hold for getType
nnoremap <leader>td :YcmCompleter GoToDefinition<CR>
nnoremap <leader>tt :YcmCompleter GetType<CR>
nnoremap <leader>tr :YcmCompleter GoToReferences<CR>
nnoremap <leader>tR :YcmCompleter RefactorRename
nnoremap <leader>tdoc :YcmCompleter GetDoc<CR>

"" Airline Settings
set laststatus=2                " show airline even if no split exists
set showtabline=2               " show tabline even if no tabs open
let g:airline_theme='lucius'
let g:airline_powerline_fonts=1
" let g:airline_left_sep=''
" let g:airline_right_sep=''
" let g:airline_left_alt_sep=''
" let g:airline_right_alt_sep=''
let g:airline_section_y=airline#section#create(['%l/%L'])
let g:airline_section_z=airline#section#create(['%v'])
let g:airline#extensions#ale#enabled=1
let g:airline#extensions#default#section_truncate_width={
  \ 'b': 79, 'x': 60, 'y': 45, 'z': 45, 'warning': 80, 'error': 80
  \ }

"" ALE Settings

""" Lint Settings
let g:ale_sign_column_always=1
let g:ale_javascript_eslint_use_global=1
let g:ale_javascript_eslint_options='--cache'
let g:ale_javascript_eslint_executable='eslint_d'

""" Fix Settings
let g:ale_fix_on_save=1
let g:ale_fixers = {
\   'javascript': ['eslint', 'remove_trailing_lines'],
\ }

"" CtrlP Settings
let g:ctrlp_show_hidden=1
let g:ctrlp_clear_cache_on_exit=0
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\.git$\|node_modules\|tmp\|bower_components\|pdfjs\|out$',
  \ 'file': '\.so$\|\.swp|\.dat$|\.DS_Store$'
  \ }

"" Vim Javascript Settings
set conceallevel=1
set concealcursor=c
let g:javascript_plugin_jsdoc=1
let g:javascript_conceal_function="λ"

"" Tmuxline settings
let g:tmuxline_preset='full'

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
