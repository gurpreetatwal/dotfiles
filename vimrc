" Helper function for conditionally loading plugins
function! Cond(cond, ...)
  let opts = get(a:000, 0, {})
  return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

" Plugins
call plug#begin()
Plug 'SirVer/ultisnips'                 " snippet engine
Plug 'Valloric/MatchTagAlways', { 'for' : ['html', 'xhtml', 'xml', 'jinja'] }           " highlights surrounding html tag
Plug 'airblade/vim-gitgutter'         " add support for viewing and editing git hunks
Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'npm install -g typescript-language-server && bash install.sh' }
Plug 'ctrlpvim/ctrlp.vim'
Plug 'edkolev/tmuxline.vim'
Plug 'ekalinin/Dockerfile.vim'          " syntax + snippets for Dockerfile
Plug 'gurpreetatwal/vim-avro'
Plug 'honza/vim-snippets'               " pre-written snippets
Plug 'joshdick/onedark.vim'             " color scheme based on Atom's One Dark theme
Plug 'junegunn/goyo.vim'              " creates padding around the window for focused writing
Plug 'junegunn/limelight.vim'         " highlights the current paragraph and dims all others
Plug 'lepture/vim-jinja'              " syntax for jinja/nunjucks (*.njk) files
Plug 'othree/eregex.vim'
Plug 'prisma/vim-prisma'
Plug 'scrooloose/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'sjl/gundo.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'              " git plugin
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-repeat'                " map '.' so that it can repeat command meant for plugins like surround
Plug 'tpope/vim-rhubarb'               " github integration for vim-fugitive
Plug 'tpope/vim-surround'              " add/remove/change surrounding things like: quotes, html tags, brackets, etc
Plug 'tpope/vim-unimpaired'            " key binds for common commands like :bnext, :lnext, etc.
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

"" Vim plugins
" Plug 'example', Cond(!has('nvim'))

"" Neovim plugins
Plug 'Shougo/deoplete.nvim', Cond(has('nvim'), { 'do': ':UpdateRemotePlugins' })
Plug 'carlitux/deoplete-ternjs', Cond(has('nvim'), {'do': 'npm install -g tern@latest', 'for': ['javascript', 'typescript']})
Plug 'w0rp/ale', Cond(has('nvim'))
call plug#end()

" General Vim Settings
set encoding=utf-8
set number                        " line numbers
set relativenumber                " show relative line numbers
set incsearch                     " highlight search matches as you type
set wildmenu                      " show autocomplete menu for vim commands
set wildignore=*.o,*.obj,*.so,__pycache__
set backspace=indent,eol,start    " backspace works as intended
set autoread                      " reload files if changed by other program
set cursorline                    " show horizontal cursor line
set scrolloff=5                   " always show 5 lines above and below cursor
set sidescrolloff=5               " always show 10 characters to left and right of line
set splitbelow
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

" Indentation
set tabstop=8                           " set <Tab> to have a width of 8
set shiftwidth=2                        " how many spaces each shift (<, >, =) will use for indent
set expandtab                           " make <Tab> in insert mode insert spaces
set smarttab                            " insert 'shiftwidth' at beginning of line, 'tabstop' elsewhere
set autoindent                          " copy indent from current line when starting a new line

" Colors
if (has("termguicolors"))
 set termguicolors                " enable 24 bit colors
endif
if !has('nvim')                   " needed to make 24 bit color work with vim
  set t_8b=[48;2;%lu;%lu;%lum
  set t_8f=[38;2;%lu;%lu;%lum
endif

set hlsearch                      " highlight search matches
set background=dark               " must go before the colorscheme
let g:onedark_terminal_italics=1        " italics
colorscheme onedark

"" Make background transparent
" highlight Normal ctermbg=NONE guibg=NONE
" highlight NonText ctermbg=NONE guibg=NONE

" Custom keybindings
"" General
nnoremap <C-g> :GundoToggle<CR>
nnoremap <C-n><C-n> :NERDTreeToggle<CR>
nnoremap <C-n>f :NERDTreeFind<CR>
noremap <A-z> :Goyo<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>x :x<CR>
nnoremap <leader>z :tabnew %<CR>
nnoremap <leader>c ^lf(li<CR><ESC>$hf)i<CR><ESC>
imap jk <Esc>
iabbrev <expr> uuidgen system('uuidgen')[:-2]

"" Copy & Paste into sytem buffer
map <leader>y "+y
map <leader>d "+d
map <leader>p "+p
map <leader>P "+P
map <leader>x "+x

" Plugin Settings
"" Commentary
autocmd FileType cpp setlocal commentstring=//%s

"" Goyo
function! s:goyo_enter()
  silent !tmux set status off
  silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  set scrolloff=999
  let b:prevSpell=&spell
  set spell
  Limelight
endfunction

function! s:goyo_leave()
  silent !tmux set status on
  silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  set scrolloff=5
  Limelight!
  if b:prevSpell
    set spell
  endif
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()
let g:goyo_width=100

"" NerdTree
let g:NERDTreeNatualSort=1          " sort 1, 2, 10, 20, 100 vs 1, 10, 100, 2, 20
let g:NERDTreeRespectWildIgnore=1   " respect wildignore option

"" fugitive
map <leader>gb :GBrowse!<CR>
map <leader>gB :GBrowse<CR>

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

"" Deoplete
if has('nvim')
  let g:deoplete#enable_at_startup=1
  let g:deoplete#sources#ternjs#types=1
  let g:deoplete#sources#ternjs#docs=1
  let g:deoplete#sources#ternjs#include_keywords=1
  call deoplete#custom#option('smartcase', v:true)
  call deoplete#custom#option('num_processes', 4)
  call deoplete#custom#var('file', 'enable_buffer_path', 1)
  call deoplete#custom#source('ultisnips', 'rank', 1000)
  call deoplete#custom#source('tern', 'rank', 1100) " LanguageClient has rank of 1000
endif

"" Airline Settings
set laststatus=2                " show airline even if no split exists
set showtabline=2               " show tabline even if no tabs open
set noshowmode                  " airline shows mode
let g:airline_theme='onedark'
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

"" Ultisnips Settings
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsListSnippets="<C-l>"
let g:UltiSnipsJumpForwardTrigger='<tab>'
let g:UltiSnipsJumpBackwardTrigger ='<s-tab>'
set runtimepath+=~/dotfiles/vim                             " required b/c https://github.com/SirVer/ultisnips/issues/711#issuecomment-246815553
let g:UltiSnipsSnippetsDir='~/dotfiles/vim/UltiSnips'
let g:UltiSnipsSnippetDirectories=['~/dotfiles/vim/UltiSnips', 'UltiSnips']

"" LanguageClient Settings
set hidden
let g:LanguageClient_autoStart = 1
let g:LanguageClient_diagnosticsList = "Location"      " use Location list instead of window list as errors are scoped to one file

" Minimal LSP configuration for JavaScript
let g:LanguageClient_serverCommands = {
      \ 'javascript.jsx': ['typescript-language-server --stdio'],
      \ 'typescript': ['typescript-language-server --stdio'],
      \ }
autocmd FileType javascript.jsx setlocal omnifunc=LanguageClient#complete
nnoremap <F5> :call LanguageClient_contextMenu()<CR>

"" ALE Settings

""" Lint Settings
let g:ale_linters={
  \ 'zsh':  ['all'],
  \ 'python': ['mypy', 'pylint'],
  \ }
let g:ale_sign_column_always=1
let g:ale_javascript_eslint_use_global=1
let g:ale_javascript_eslint_options='--cache'
let g:ale_javascript_eslint_executable='eslint_d'
autocmd FileType zsh let g:ale_sh_shellcheck_options = '-s bash'                " zsh is not a supported shell

""" Fix Settings
fun! PrismaFormat(buffer) abort
  return {
        \ 'command': 'cp ' . expand('%') . ' /tmp/schema.prisma && npx prisma format --schema /tmp/schema.prisma > /dev/null && cat /tmp/schema.prisma '
        \}
endfun
execute ale#fix#registry#Add('prisma', 'PrismaFormat', ['prisma'], 'Format Prisma schema files')

let g:ale_fix_on_save=1
let g:ale_fixers = {
\   '*': ['remove_trailing_lines'],
\   'css': ['prettier'],
\   'html': ['tidy', 'prettier'],
\   'javascript': ['prettier', 'eslint'],
\   'typescript': ['prettier'],
\   'json': ['prettier'],
\   'markdown': ['prettier'],
\   'prisma': ['prisma'],
\   'sass': ['prettier'],
\   'terraform': ['terraform'],
\   'yaml': ['prettier'],
\ }

"" CtrlP Settings
if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  let g:ctrlp_use_caching = 0
endif

let g:ctrlp_show_hidden=1
let g:ctrlp_clear_cache_on_exit=0
let g:ctrlp_custom_ignore={
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


" Make Shift-K work correctly for nvim  + git (I don't really know how this
" works....)
if exists('*shellescape') && exists('b:git_dir') && b:git_dir != ''
  if b:git_dir =~# '/\.git$' " Not a bare repository
    let &l:path = escape(fnamemodify(b:git_dir,':h'),'\, ').','.&l:path
  endif
  let &l:path = escape(b:git_dir,'\, ').','.&l:path
  let &l:keywordprg = ':sp | term git --git-dir='.shellescape(b:git_dir).' show'
else
  setlocal keywordprg=git\ show
endif

if has('gui_running')
  let &l:keywordprg = substitute(&l:keywordprg,'^git\>','git --no-pager','')
endif

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

" Alias W -> w
fun! SetupCommandAlias(from, to)
  exec 'cnoreabbrev <expr> '.a:from
        \ .' ((getcmdtype() is# ":" && getcmdline() is# "'.a:from.'")'
        \ .'? ("'.a:to.'") : ("'.a:from.'"))'
endfun
call SetupCommandAlias("W","w")
