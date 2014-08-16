" Author: Attila Oláh
" Email: attilaolah@gmail.com

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

Plugin 'Lokaltog/powerline'
Plugin 'Shougo/unite.vim'
Plugin 'Shougo/vimproc.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'altercation/vim-colors-solarized'
Plugin 'attilaolah/pyflakes-vim'
Plugin 'davidhalter/jedi-vim'
Plugin 'fatih/vim-go'
Plugin 'groenewege/vim-less'
Plugin 'hail2u/vim-css3-syntax'
Plugin 'jstemmer/gotags'
Plugin 'junegunn/vim-easy-align'
Plugin 'kchmck/vim-coffee-script'
Plugin 'majutsushi/tagbar'
Plugin 'mintplant/vim-literate-coffeescript'
Plugin 'nelstrom/vim-markdown-folding'
Plugin 'ngmy/vim-rubocop'
Plugin 'scrooloose/syntastic'
Plugin 'skammer/vim-css-color'
Plugin 'slim-template/vim-slim'
Plugin 'sunaku/vim-ruby-minitest'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'tpope/vim-abolish'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-haml'
Plugin 'tpope/vim-liquid'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-sleuth'
Plugin 'tpope/vim-speeddating'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'

" UltiSnip engine
Plugin 'SirVer/ultisnips'
" Snippets are separated from the engine
Plugin 'honza/vim-snippets'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

syntax on

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

" Go: template
autocmd BufNewFile *.go $read ~/.vim/templates/new.go

" Ruby: autocomplete for minitest
set completefunc=syntaxcomplete#Complete

" UltiSnip: Trigger configuration:
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
" If you want :UltiSnipsEdit to split your window:
let g:UltiSnipsEditSplit="vertical"


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
