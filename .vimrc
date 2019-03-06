scriptencoding utf-8
set fileencoding=utf-8 termencoding=utf-8 encoding=utf-8

" try to figure out where the .vim equivalent directory is
let $vimdir = resolve(expand('<sfile>:p:h'))
if $vimdir ==# $HOME
  if isdirectory($HOME . '.vim')
    let $vimdir = $HOME . '.vim'
  elseif isdirectory($HOME . 'vimfiles')
    let $vimdir = $HOME . 'vimfiles'
  endif
endif

" install vim-plug if it's not installed already
if empty(glob($vimdir . '/autoload/plug.vim'))
  silent !curl -fLo $vimdir/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  augroup install_vim_plug
    autocmd!
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  augroup END
endif

call plug#begin($vimdir . '/plugged')

" colorschemes
Plug 'ajh17/Spacegray.vim'
Plug 'cseelus/vim-colors-tone'
Plug 'atelierbram/Base2Tone-vim'
Plug 'dim13/gocode.vim'

" plugins
Plug 'tpope/vim-sleuth'
Plug 'w0rp/ale'
Plug 'sheerun/vim-polyglot'
Plug 'editorconfig/editorconfig-vim'

call plug#end()

filetype plugin indent on
syntax on

colorscheme spacegray

set autoindent
set autoread   " reload files when changed externally
set backupdir=$vimdir/backups
set colorcolumn=80
set directory=$vimdir/tmp
set expandtab
set ignorecase
set incsearch
set laststatus=2
set list
set listchars=tab:»\ ,nbsp:~,trail:·,space:·,eol:¬,extends:…,precedes:…
set matchtime=1
set nospell
set novisualbell
set number
set numberwidth=4
set relativenumber
set shiftround
set shiftwidth=2
set smartcase
set smartindent
set splitbelow
set splitright
set tabstop=2
set termguicolors
set undodir=$vimdir/undo
set undofile
set wrap
set writebackup

set statusline=%#LineNr#  " match number column hightlighting
set statusline+=\         " space before any text
set statusline+=%t        " filename, no directory
set statusline+=\         " space
set statusline+=%m        " modified flag
set statusline+=%r        " readonly flag
set statusline+=%h        " helpfile flag
set statusline+=%w        " preview window flag
set statusline+=%q        " quickfix window flag
set statusline+=%=        " switch to right side
set statusline+=%P        " percentage through file
set statusline+=\         " space after percentage

let g:mapleader = '\'
let g:maplocalleader = '|'

" remap hjkl for Colemak (without using other keys)
noremap h k
noremap k j
noremap j h
noremap <C-w>h <C-w>k
noremap <C-w>k <C-w>j
noremap <C-w>j <C-w>h

" press enter or shift enter to add a new line above/below
nnoremap <CR> o<Esc>
nnoremap <S-CR> O<Esc>

" clear search highlight with <leader>space
nnoremap <silent> <leader><space> :let @/=""<CR>

" automatically change to non-relative numbers when not active buffer
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" filetype stuff

augroup filetype_javascript
  autocmd!
  " run the current file/selection with <localleader>r
  autocmd FileType javascript noremap <localleader>r :w !node -<CR>
augroup END

augroup filetype_php
  autocmd!
  " run the current file/selection with <localleader>r
  autocmd FileType php noremap <localleader>r :w !php -r
        \ '$f = file_get_contents("php://stdin");
        \ eval(substr($f, strpos($f, "<?php") + 5));'
        \ <CR>
augroup END

" ale config
if !exists('g:ale_linters')
  let g:ale_linters = {}
endif

" lint a little less often to prevent linters blowing up your PC
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1

" show which linter is giving the error
let g:ale_echo_msg_format = '%linter%: %s'

" only use mcs to lint c#
let g:ale_linters.cs = ['mcs']
