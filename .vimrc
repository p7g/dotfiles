scriptencoding utf-8
set fileencoding=utf-8 termencoding=utf-8 encoding=utf-8

let s:haswin = has('win32') || has('win64')

" set shell
if s:haswin
  set shell=powershell
endif

if s:haswin
  let s:pathsep = '\'
else
  let s:pathsep = '/'
endif

" create a directory if it doesn't already exist
function! s:assertdir(path)
  if !isdirectory(a:path)
    silent execute '!mkdir -p ' . a:path
  endif
endfunction

function! s:joinpaths(...)
  return join(a:000, s:pathsep)
endfunction

" try to figure out where the .vim equivalent directory is
let $vimdir = resolve(expand('<sfile>:p:h'))
if $vimdir ==# $HOME
  if s:haswin
    let s:path = s:joinpaths($HOME, 'vimfiles')
  else
    let s:path = s:joinpaths($HOME, '.vim')
  endif
  call s:assertdir(s:path)
  let $vimdir = s:path
endif

call s:assertdir(s:joinpaths($vimdir, 'undo'))
call s:assertdir(s:joinpaths($vimdir, 'backups'))
call s:assertdir(s:joinpaths($vimdir, 'tmp'))

" install vim-plug if it's not installed already
if empty(glob(s:joinpaths($vimdir, 'autoload', 'plug.vim')))
  echom 'Installing vim-plug'
  let $vimplugloc = s:joinpaths($vimdir, 'autoload', 'plug.vim')
  if s:haswin
    echom 'Using Powershell'
    let $autoloaddir = s:joinpaths($vimdir, 'autoload')
    silent execute '!md ' . $autoloaddir
    silent execute 
          \  '![Net.WebClient]::new().DownloadFile('
          \ .   "'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',"
          \ .   "$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('"
          \      . $vimplugloc
          \ . "'))"
  else
    echom 'Using curl'
    silent execute '!curl -fLo ' . $vimplugloc . ' --create-dirs '
          \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  endif
  augroup install_vim_plug
    autocmd!
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  augroup END
endif

call plug#begin(s:joinpaths($vimdir, '/plugged'))

" colorschemes
Plug 'ajh17/Spacegray.vim'
Plug 'cseelus/vim-colors-tone'
Plug 'atelierbram/Base2Tone-vim'
Plug 'dim13/gocode.vim'
Plug 'axvr/photon.vim'
Plug 'pgdouyon/vim-yin-yang'
Plug 'sansbrina/vim-garbage-oracle'
Plug 'pbrisbin/vim-colors-off'

" plugins
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'w0rp/ale'
Plug 'sheerun/vim-polyglot'
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/fzf', {'dir': '~/.fzf', 'do': './install --all'}
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rsi'
Plug 'kchmck/vim-coffee-script'
Plug 'neoclide/coc.nvim', {'tag': '*', 'do': './install.sh'}
Plug 'tpope/vim-dadbod'

" coc plugins:
" - coc-json
" - coc-tsserver
" - coc-html
" - coc-css
" - coc-python
" - coc-highlight
" - coc-emmet
" - coc-git
" - coc-vimlsp

call plug#end()

filetype plugin indent on
syntax on

set background=light
colorscheme off

set autoindent
set autoread   " reload files when changed externally
set backupdir=$vimdir/backups
set belloff=all
set colorcolumn=80
set directory=$vimdir/tmp
set expandtab
if !has('nvim')
  set guifont=IBMPlexMono-Text:h15
endif
set grepprg=rg\ --vimgrep
set guioptions=
set ignorecase
set incsearch
set laststatus=2
set list
set listchars=tab:»\ ,nbsp:~,trail:·,space:·,eol:¬,extends:…,precedes:…
set matchtime=1
set nohidden
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
set statusline+=\ %{coc#status()}
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


" o/O
"
" Start insert mode with [count] blank lines. The default behaviour repeats
" the insertion [count] times, which is not so useful.
"
" Credit: https://stackoverflow.com/a/27820229
function! s:NewLineInsertExpr(isUndoCount, command)
  if !v:count
    return a:command
  endif

  let l:reverse = {'o': 'O', 'O': 'o'}
  " First insert a temporary '$' marker at the next line (which is necessary
  " to keep the indent from the current line), then insert <count> empty lines
  " in between. Finally, go back to the previously inserted temporary '$' and
  " enter insert mode by substituting this character.
  " Note: <C-\><C-n> prevents a move back into insert mode when triggered via
  " |i_CTRL-O|.
  return (a:isUndoCount && v:count ? "\<C-\>\<C-n>" : '') .
        \ a:command . "$\<Esc>m`" .
        \ v:count . l:reverse[a:command] . "\<Esc>" .
        \ 'g``"_s'
endfunction
nnoremap <silent> <expr> o <SID>NewLineInsertExpr(1, 'o')
nnoremap <silent> <expr> O <SID>NewLineInsertExpr(1, 'O')


" diff the current state of a buffer with the most recently saved version of
" the file
function! s:DiffWithSaved()
  let filetype = &filetype
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  execute 'setlocal ' .
        \ 'buftype=nofile ' .
        \ 'bufhidden=wipe ' .
        \ 'nobuflisted ' .
        \ 'noswapfile ' .
        \ 'readonly ' .
        \ 'filetype=' . filetype
endfunction
command! D call s:DiffWithSaved()

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
let g:ale_python_flake8_executable = '~/.local/venvs/fellow/bin/flake8'
let g:ale_python_black_executable = '~/.local/venvs/fellow/bin/tan'
let g:ale_python_mypy_executable = '~/.local/venvs/fellow/bin/mypy'
let g:ale_python_pylint_executable = '~/.local/venvs/fellow/bini/pylint'
let g:ale_linters.python = ['flake8', 'mypy', 'black', 'pylint']
let g:ale_linters.coffee = ['eslint', 'coffee', 'coffeelint']

" coc config
nmap <leader>d :CocList diagnostics<CR>
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if index(['vim', 'help'], &filetype) >= 0
    execute 'h ' . expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
