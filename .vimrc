" Author: Attila Oláh
" Email: attilaolah@gmail.com

set nocompatible              " be iMproved, required
filetype off                  " required

" curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
call plug#begin('~/.vim/plug')

Plug 'Lokaltog/powerline'
Plug 'Shougo/unite.vim'
Plug 'Shougo/vimproc.vim'
Plug 'airblade/vim-gitgutter'
Plug 'altercation/vim-colors-solarized'
Plug 'bling/vim-airline'
Plug 'editorconfig/editorconfig-vim'
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'groenewege/vim-less'
Plug 'hail2u/vim-css3-syntax'
Plug 'jstemmer/gotags'
Plug 'junegunn/vim-easy-align'
Plug 'kchmck/vim-coffee-script'
Plug 'majutsushi/tagbar'
Plug 'nelstrom/vim-markdown-folding'
Plug 'ngmy/vim-rubocop'
Plug 'python-mode/python-mode', { 'branch': 'develop' }
Plug 'scrooloose/syntastic'
Plug 'slim-template/vim-slim'
Plug 'sunaku/vim-ruby-minitest'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-haml'
Plug 'tpope/vim-liquid'
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'

" Initialize plugin system
call plug#end()

" To default to Python3 syntax
"let g:pymode_python = 'python3'

" NOTE: apparently there is some bug in vim-go, so force this:
autocmd BufWritePre *.go call go#fmt#Format(1)

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

" Ruby: autocomplete for minitest
set completefunc=syntaxcomplete#Complete

" Airline: Smart, 'straight' tabs:
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = " "
let g:airline#extensions#tabline#left_alt_sep = "|"

" Source a vimrc from git project root, https://gist.github.com/4617337
let project_root = system("git rev-parse --show-toplevel")
" System commands seem to have a trailing newline, so lets get rid of that
let chomped_project_root = project_root[:-2]
let project_vimrc = chomped_project_root."/.vimrc"
if filereadable(project_vimrc)
  execute "source" project_vimrc
endif

" ,g: Grep (using ag)
nnoremap <silent> ,g :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor'
  let g:unite_source_grep_recursive_opt = ''
endif
