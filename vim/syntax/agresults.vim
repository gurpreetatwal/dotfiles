" Define custom syntax for ag results
syntax match agFilename "^\S\+/\S\+.*\.\w\+$"
syntax match agLineNo /^\d\+:/

" Set highlighting for each part
highlight agFilename ctermfg=lightgreen cterm=bold guifg=#98C379 guibg=NONE
highlight agLineNo ctermfg=Yellow cterm=bold guifg=#D19A66 guibg=NONE
