" Author: Attila Oláh
" Email: attilaolah@gmail.com

" Pathogen, should be at the top.
execute pathogen#infect()

syntax on
filetype plugin indent on

" Highlight colour:
highlight Search cterm=NONE ctermfg=grey ctermbg=blue
highlight SpellBad cterm=NONE ctermfg=black ctermbg=yellow

" Show line numbers:
set number

" Shorter tabs:
set tabstop=4
" This may be overwritten per file:
set shiftwidth=4

" Enable wild menu:
set wildmenu

" Incremen/decrement numbers using +/-:
nnoremap + <C-a>
nnoremap - <C-x>

" Folding shortcuts:
nnoremap <Space> za
vnoremap <Space> za
set foldlevelstart=99

" CoffeeScript options:
let coffee_compiler = $HOME . '/.vim/coffee-script/bin/coffee'
let coffee_linter = $HOME . '/.vim/coffeelint/bin/coffeelint'

" 120 character ruler
set colorcolumn=120
" Make sure characters under the ruler are clearly visible
highlight ColorColumn ctermbg=red ctermfg=white
match ColorColumn /\%120v./

" Tagbar shortcut
nmap <C-t> :TagbarToggle<CR>

" Swap j/k, easier to navigate in dvp layout:
nnoremap j k
vnoremap j k
nnoremap k j
vnoremap k j

" Alignment
vnoremap a :EasyAlign<Return><Space><Return>
vnoremap A :EasyAlign<Return>

" Go: run gfmt before saving
let gofmt_command = "goimports"
autocmd FileType go compiler go
autocmd FileType go autocmd BufWritePre <buffer> Fmt
autocmd BufNewFile *.go $read ~/.vim/templates/new.go

" Source a vimrc from git project root, https://gist.github.com/4617337
let project_root = system("git rev-parse --show-toplevel")
" System commands seem to have a trailing newline, so lets get rid of that
let chomped_project_root = project_root[:-2]
let project_vimrc = chomped_project_root."/.vimrc"
if filereadable(project_vimrc)
  execute "source" project_vimrc
endif

nnoremap <silent> ,g :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
if executable('pt')
  let g:unite_source_grep_command = 'pt'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor'
  let g:unite_source_grep_recursive_opt = ''
endif
