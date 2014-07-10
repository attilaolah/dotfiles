" Author: Attila Oláh
" Email: attilaolah@gmail.com

" Pathogen, should be at the top.
execute pathogen#infect()

syntax on
filetype plugin indent on

highlight LineNr       cterm=NONE ctermfg=black ctermbg=NONE
highlight Search       cterm=NONE ctermfg=grey  ctermbg=blue
highlight SpellBad     cterm=NONE ctermfg=black ctermbg=yellow
highlight CursorColumn cterm=NONE ctermfg=NONE  ctermbg=black
highlight ColorColumn  cterm=NONE ctermfg=NONE  ctermbg=black

highlight GitGutterAdd          cterm=NONE ctermbg=black ctermfg=darkgreen
highlight GitGutterChange       cterm=NONE ctermbg=black ctermfg=darkyellow
highlight GitGutterDelete       cterm=NONE ctermbg=black ctermfg=darkred
highlight GitGutterChangeDelete cterm=NONE ctermbg=black ctermfg=darkred
highlight SignColumn            cterm=NONE ctermbg=black

let g:gitgutter_sign_modified_removed = '~'
let g:gitgutter_sign_removed_first_line = '^'

set tabstop=4
set shiftwidth=4
set number
set colorcolumn=120

match ColorColumn /\%120v./

" Enable wild menu
set wildmenu

" +, -: Incremen/decrement numbers using +/-
nnoremap + <C-a>
nnoremap - <C-x>

" Space: Folding shortcuts
nnoremap <Space> za
vnoremap <Space> za
set foldlevelstart=99

" CoffeeScript options
let coffee_compiler = $HOME . '/.vim/coffee-script/bin/coffee'
let coffee_linter   = $HOME . '/.vim/coffeelint/bin/coffeelint'

" Ctrl+T: Tagbar shortcut
nmap <C-t> :TagbarToggle<CR>

" Ctrl+C: Cursor line and column
nmap <C-c> :set cursorline! cursorcolumn!<CR>

" Swap j/k, easier to navigate in dvp layout:
nnoremap j k
vnoremap j k
nnoremap k j
vnoremap k j

" A, a: Alignment
vnoremap A :EasyAlign<Return>
vnoremap a :EasyAlign<Return><Space><Return>

" Go: run gfmt before saving
let gofmt_command = "goimports"
autocmd FileType go compiler go
autocmd FileType go autocmd BufWritePre <buffer> Fmt
autocmd BufNewFile *.go $read ~/.vim/templates/new.go

" Ruby: autocomplete for minitest
set completefunc=syntaxcomplete#Complete

" Source a vimrc from git project root, https://gist.github.com/4617337
let project_root = system("git rev-parse --show-toplevel")
" System commands seem to have a trailing newline, so lets get rid of that
let chomped_project_root = project_root[:-2]
let project_vimrc = chomped_project_root."/.vimrc"
if filereadable(project_vimrc)
  execute "source" project_vimrc
endif

" ,g: Grep (using pt)
nnoremap <silent> ,g :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
if executable('pt')
  let g:unite_source_grep_command = 'pt'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor'
  let g:unite_source_grep_recursive_opt = ''
endif
