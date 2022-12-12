" Author: Attila Oláh
" Email: attilaolah@gmail.com

set nocompatible              " be iMproved, required
filetype off                  " required

" curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
call plug#begin('~/.vim/plug')

Plug 'airblade/vim-gitgutter'
Plug 'altercation/vim-colors-solarized'
Plug 'bling/vim-airline'
Plug 'bronson/vim-visual-star-search'
Plug 'dag/vim-fish'
Plug 'DingDean/wgsl.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'groenewege/vim-less'
Plug 'hail2u/vim-css3-syntax'
Plug 'jstemmer/gotags'
Plug 'junegunn/fzf'
Plug 'junegunn/vim-easy-align'
Plug 'kchmck/vim-coffee-script'
Plug 'leafgarland/typescript-vim'
Plug 'Lokaltog/powerline'
Plug 'majutsushi/tagbar'
Plug 'nelstrom/vim-markdown-folding'
Plug 'ngmy/vim-rubocop'
Plug 'python-mode/python-mode', { 'branch': 'develop' }
Plug 'scrooloose/syntastic'
Plug 'Shougo/unite.vim'
Plug 'Shougo/vimproc.vim'
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

" NOTE: apparently there is some bug in vim-go, so force this
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

set hlsearch
set ignorecase
set smartcase

match ColorColumn /\%120v./

" Enable wild menu
set wildmenu

" Leader stuff
let mapleader = ","

nnoremap <leader>oe :e <C-R>=expand("%:p:h") . "/" <cr>
nnoremap <leader>os :sp <C-R>=expand("%:p:h") . "/" <cr>
nnoremap <leader>ov :vs <C-R>=expand("%:p:h") . "/" <cr>

vnoremap <leader>oe y:e <C-R>"<cr>
vnoremap <leader>os y:sp <C-R>"<cr>
vnoremap <leader>ov y:vs <C-R>"<cr>
vnoremap <leader>. :normal .<cr>

vnoremap <leader>c y:call system('echo -n ' . shellescape(getreg('"')) . ' \| xclip -selection clipboard')<cr>

vnoremap <leader>s :sort<cr>
nnoremap <leader>e :lopen<cr>
nnoremap <leader><space> :nohl<cr>:lclose<cr>

nnoremap <leader>sp <C-w>t<C-w>K
nnoremap <leader>vs <C-w>t<C-w>H

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

" Change j/k to h/t
nnoremap h j
vnoremap h j
nnoremap t k
vnoremap t k

" A, a: Alignment
vnoremap A :EasyAlign<Return>
vnoremap a :EasyAlign<Return><Space><Return>

" Ruby: autocomplete for minitest
set completefunc=syntaxcomplete#Complete

" Airline: Smart, 'straight' tabs
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
