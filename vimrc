" Author: Attila Oláh
" Email: attilaolah@gmail.com

" Pathogen, should be at the top.
execute pathogen#infect()

syntax on
filetype plugin indent on

" Longer lines in .py files:
let g:flake8_max_line_length=120
" Run Flake8 before saving .py files:
autocmd BufWritePost *.py call Flake8()

" Show line numbers:
set number
" Show whitespace:
set list

" Shorter tabs:
set tabstop=4
" This may be overwritten per file:
set shiftwidth=4

" Enable wird menu:
set wildmenu

" Incremen/decrement numbers using +/-:
nnoremap + <C-a>
nnoremap - <C-x>

" Folding shortcuts:
set foldlevelstart=0
nnoremap <Space> za
vnoremap <Space> za
