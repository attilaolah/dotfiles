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
