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
    let l:path = shellescape(a:path)
    if s:haswin
      silent execute '!New-Item -Path "' . l:path . '" -Type Directory'
    else
      silent execute '!mkdir -p ' . l:path
    endif
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

for p in ['undo', 'backups', 'tmp']
  call s:assertdir(s:joinpaths($vimdir, p))
endfor

function! s:downloadfile(src, dest)
  if s:haswin
    silent execute
          \ '![Net.WebClient]::new().DownloadFile('
          \ . "'" . shellescape(a:src) . "'"
          \ . "\$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('"
          \    . shellescape(a:dest)
          \ . "'))"
  else
    silent execute '!curl -fLo ' . shellescape(a:dest) . ' --create-dirs '
          \ . shellescape(a:src)
  endif
endfunction

" install vim-plug if it's not installed already
if empty(glob(s:joinpaths($vimdir, 'autoload', 'plug.vim')))
  echom 'Installing vim-plug'
  let $vimplugloc = s:joinpaths($vimdir, 'autoload', 'plug.vim')
  let s:plugurl = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  call s:downloadfile(s:plugurl, $vimplugloc)
  augroup install_vim_plug
    autocmd!
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  augroup END
endif

call plug#begin(s:joinpaths($vimdir, 'plugged'))

" colorschemes
Plug 'KKPMW/oldbook-vim'
Plug 'Nequo/vim-allomancer'
Plug 'ajh17/Spacegray.vim'
Plug 'arcticicestudio/nord-vim'
Plug 'atelierbram/Base2Tone-vim'
Plug 'axvr/photon.vim'
Plug 'cseelus/vim-colors-tone'
Plug 'dim13/gocode.vim'
Plug 'liuchengxu/space-vim-theme'
Plug 'pbrisbin/vim-colors-off'
Plug 'pgdouyon/vim-yin-yang'
Plug 'reedes/vim-colors-pencil'
Plug 'robertmeta/nofrils'
Plug 'sansbrina/vim-garbage-oracle'
Plug 'w0ng/vim-hybrid'

" plugins
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/fzf', {'dir': '~/.fzf', 'do': './install --all'}
Plug 'junegunn/fzf.vim'
Plug 'kchmck/vim-coffee-script'
Plug 'killphi/vim-ebnf'
Plug 'nbouscal/vim-stylish-haskell'
Plug 'neoclide/coc.nvim', {'tag': '*', 'branch': 'release'}
Plug 'sheerun/vim-polyglot'
Plug 'tjvr/vim-nearley'
Plug 'tommcdo/vim-lion'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-dadbod'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'vim-erlang/vim-erlang-compiler'
Plug 'vim-erlang/vim-erlang-runtime'
Plug 'w0rp/ale'

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

""" colorscheme configuration
set background=light

" nord
let g:nord_italic = 1
let g:nord_underline = 1
let g:nord_italic_comments = 1

" nofrils
let g:nofrils_strbackgrounds = 1
let g:nofrils_heavycomments = 1

colorscheme off

if has('gui') && !has('nvim')
  set guifont=IBMPlexMono-Text:h15
endif

set autoindent
set autoread   " reload files when changed externally
set backupdir=$vimdir/backups
set belloff=all
set colorcolumn=80
set directory=$vimdir/tmp
set expandtab
set exrc
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
set secure
set shiftround
set shiftwidth=4
set smartcase
set smartindent
set splitbelow
set splitright
set tabstop=4
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

" resize split with ctrl-arrows
nnoremap <silent> <C-Up> :resize +5<CR>
nnoremap <silent> <C-Down> :resize -5<CR>
nnoremap <silent> <C-Left> :vertical resize -5<CR>
nnoremap <silent> <C-Right> :vertical resize +5<CR>

" <leader>ts removes trailing whitespace
nnoremap <silent> <leader>ts :%s/\s\+$//ge<CR>

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
  let l:filetype = &filetype
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  execute 'setlocal ' .
        \ 'buftype=nofile ' .
        \ 'bufhidden=wipe ' .
        \ 'nobuflisted ' .
        \ 'noswapfile ' .
        \ 'readonly ' .
        \ 'filetype=' . l:filetype
endfunction
command! D call s:DiffWithSaved()

" <leader>b shows current buffers
nnoremap <leader>b :buffers<CR>

" <leader>c shows positional stats
nnoremap <leader>c g<C-g>

" open vimrc quickly
nnoremap <leader>vrc :vsplit $MYVIMRC<CR>
nnoremap <leader>src :split  $MYVIMRC<CR>
nnoremap <leader>rc  :edit   $MYVIMRC<CR>
" source vimrc quickly
nnoremap <leader>st :source $MYVIMRC<CR>

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
        \ '$f = file_get_contents("php://stdin");'
        \ . '$pos = strpos($f, "<?php");'
        \ . '$code = $pos === 0 ? substr($f, $pos + strlen("<?php")) : $f;'
        \ . 'eval($code);'<CR>
augroup END

" ale config
let g:ale_enabled = 0

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

" only use mcs to lint c#
let g:ale_linters.cs = ['mcs']

let g:ale_virtualenv_dir_names = ['~/.local/venvs']

" change cursor depending on mode in term
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" FZF mappings
nnoremap <silent> <C-P> :Files<CR>
nnoremap <silent> <leader>B :Buffers<CR>
nnoremap <silent> <leader>Gf :GFiles<CR>
nnoremap <silent> <leader>G? :GFiles?<CR>
nnoremap <silent> <leader>Gb :BCommits<CR>
nnoremap <silent> <leader>Gc :Commits<CR>
nnoremap <silent> <leader>H :History:<CR>
