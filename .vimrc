scriptencoding utf-8
set fileencoding=utf-8 termencoding=utf-8 encoding=utf-8


" --- settings

if has('nvim')
  let $vimdir = stdpath('config')
else
  let $vimdir = resolve($HOME . '/.vim')
endif

set autoindent
set autoread   " reload files when changed externally
set backupdir=$vimdir/backups
set belloff=all
set cmdheight=1
set colorcolumn=80
set directory=$vimdir/tmp
set expandtab
set noexrc
set grepprg=rg\ --vimgrep\ --glob\ '!**/node_modules'
set guioptions=
set hidden
set ignorecase
set incsearch
set laststatus=2
set list
set listchars=tab:»\ ,nbsp:~,trail:·,space:·,eol:¬,extends:…,precedes:…
set matchtime=1
set noshowmode
set nospell
set novisualbell
set number
set numberwidth=1
set relativenumber
set secure
set shiftround
set shiftwidth=4
set shortmess+=c
set signcolumn=yes
set smartcase
set smartindent
set splitbelow
set splitright
set tabstop=4
" set termguicolors
set undodir=$vimdir/undo
set undofile
set updatetime=300
set wrap
set writebackup

function! CocStatus()
  if exists('*coc#status')
    return coc#status()
  endif
  return ''
endfun

set statusline=%#LineNr#  " match number column hightlighting
set statusline+=\         " space before any text
set statusline+=%f        " filename, no directory
set statusline+=\         " space
set statusline+=%m        " modified flag
set statusline+=%r        " readonly flag
set statusline+=%h        " helpfile flag
set statusline+=%w        " preview window flag
set statusline+=%q        " quickfix window flag
set statusline+=\ %{CocStatus()}
set statusline+=%=        " switch to right side
set statusline+=%P        " percentage through file
set statusline+=\         " space after percentage

" automatically change to non-relative numbers when not active buffer

function! s:set_relativenumber(on)
    if !exists("b:disable_numbertoggle")
       let &relativenumber = a:on
    endif
endfunction

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * call <SID>set_relativenumber(1)
  autocmd BufLeave,FocusLost,InsertEnter   * call <SID>set_relativenumber(0)
augroup END


" --- key bindings
let g:mapleader = '\'
let g:maplocalleader = '|'

" remap hjkl for Colemak (without using other keys)
" j l   ← →
" h     ↑
"  k     ↓
noremap h k
noremap k j
noremap j h
noremap <C-w>h <C-w>k
noremap <C-w>k <C-w>j
noremap <C-w>j <C-w>h

" press enter or shift enter to add a new line above/below
nnoremap <CR> o<Esc>

" resize split with ctrl-arrows
nnoremap <silent> <C-Up> :resize +5<CR>
nnoremap <silent> <C-Down> :resize -5<CR>
nnoremap <silent> <C-Left> :vertical resize -5<CR>
nnoremap <silent> <C-Right> :vertical resize +5<CR>

" clear search highlight with <leader>space
nnoremap <silent> <leader><space> :let @/ = ""<CR>

" because it's annoying when you press ctrl+space by accident
inoremap <C-@> <nop>
noremap <C-@> <nop>

" --- filetype augroups
"
augroup filetype_overrides
  autocmd!
  autocmd BufRead *.variables setlocal filetype=less
  autocmd BufRead .eslintrc setlocal filetype=json5
augroup END

augroup filetype_javascript
  autocmd!
  " run the current file/selection with <localleader>r
  autocmd FileType javascript noremap <buffer> <localleader>r :w !node -<CR>
augroup END

" disable changes to indentation settings when opening a python file
let g:python_recommended_style = 0
let g:python3_host_prog = 'python3.9'
let g:python_host_prog = 'python2'
augroup filetype_python
  autocmd!
  " run the current file/selection with <localleader>r
  autocmd FileType python noremap <buffer> <localleader>r :w !python -<CR>
  autocmd FileType python setlocal noexpandtab shiftwidth=4 tabstop=4
                                 \ softtabstop=4 formatoptions+=croql
augroup END

augroup filetype_gitcommit
  autocmd!
  autocmd FileType gitcommit let b:dontAdjustTextWidth = 1
augroup END

augroup comment_textwidth
  autocmd!
  autocmd FileType markdown,rst let b:dontAdjustTextWidth = 1
augroup END

let g:comment_width = 79
function! AdjustTextWidth() abort
  if exists('b:dontAdjustTextWidth')
    return
  endif
  let l:syn_element = synIDattr(synID(line('.'), col('.') - 1, 1), 'name')
  let &textwidth = syn_element =~? 'comment' ? g:comment_width : 0
endfunction


" --- that's all the fast stuff, now for the slow stuff

if $__VIM_MODE ==? 'fast'
  colorscheme blue
  finish
endif


" --- plugins

if has('nvim')
  let s:autoload_path = expand('~/.local/share/nvim/site/autoload')
  let s:plugged_dir = stdpath('config') . '/plugged'
else
  let s:autoload_path = expand('~/.vim/autoload')
  let s:plugged_dir = expand('~/.vim/plugged')
endif

" Ensure plug.vim is installed
if empty(glob(s:autoload_path . '/plug.vim'))
  let s:error = system(
        \ 'curl -fLo '
        \ . shellescape(s:autoload_path . '/plug.vim')
        \ . ' --create-dirs'
        \ . ' https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        \ )
  if v:shell_error
      echom 'Failed to get plug.vim: ' . s:error
      finish
  endif
endif

call plug#begin(s:plugged_dir)

" Colorschemes
Plug 'dim13/gocode.vim'
Plug 'junegunn/seoul256.vim'
Plug 'arzg/vim-colors-xcode'
Plug 'cormacrelf/vim-colors-github'
Plug 'morhetz/gruvbox'
Plug 'sainnhe/everforest'
Plug '4513echo/vim-colors-hatsunemiku'
Plug 'cocopon/iceberg.vim'
Plug 'robertmeta/nofrils'

" Plugins
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-dadbod'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-abolish'
Plug 'sheerun/vim-polyglot'
Plug 'editorconfig/editorconfig-vim'
Plug 'tommcdo/vim-lion'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'tpope/vim-dotenv'
Plug 'rhysd/conflict-marker.vim'
Plug 'junegunn/vim-peekaboo'
Plug 'tpope/vim-commentary'
Plug 'chrisbra/unicode.vim'

Plug 'rhysd/git-messenger.vim'
    nnoremap <silent> gb :GitMessenger<CR>

Plug 'junegunn/fzf', {'do': 'yes \| ./install --all'}
Plug 'junegunn/fzf.vim'
    nnoremap <silent> <C-p> :FZF<CR>

Plug 'vim-scripts/Sunset'
    colorscheme gruvbox
    let g:sunset_latitude = 45
    let g:sunset_longitude = -75
    " Reload sunset every day so that it recomputes the sunrise and sunset times
    " for the current day.
    let s:current_day_of_year = strftime('%j')
    function! s:reinit_sunset_if_new_day()
        let l:doy = strftime('%j')
        if l:doy != s:current_day_of_year
            unlet g:loaded_sunset
            call plug#load('vim-scripts/Sunset')
        endif
    endfunction
    augroup sunset_reload
        autocmd!
        autocmd CursorHold * nested call <SID>reinit_sunset_if_new_day()
    augroup END

Plug 'junegunn/goyo.vim'
    " Disable numbertoggle when in focus mode.
    autocmd! User GoyoEnter let b:disable_numbertoggle = 1
    autocmd! User GoyoLeave unlet b:disable_numbertoggle

Plug 'neoclide/coc.nvim', {'branch': 'release'}
    let s:coc_extensions = [
        \ 'coc-json',
        \ 'coc-tsserver',
        \ 'coc-html',
        \ 'coc-css',
        \ 'coc-pyright',
        \ 'coc-eslint',
        \ 'coc-git',
        \ 'coc-vimlsp',
        \ 'coc-prettier',
        \ 'coc-rls',
        \ 'coc-go',
        \ ]

    function! InstallCocExtensions()
        execute 'CocInstall ' . join(s:coc_extensions, ' ')
    endfunction

    nmap <leader>d :CocList diagnostics<CR>
    nmap <silent> [c <Plug>(coc-diagnostic-prev)
    nmap <silent> ]c <Plug>(coc-diagnostic-next)
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gr <Plug>(coc-references)
    nmap <leader>rn <Plug>(coc-rename)
    nnoremap <silent> K :call <SID>show_documentation()<CR>
    xmap <silent> <leader>f <Plug>(coc-format-selected)
    nmap <silent> <leader>f :call CocAction('format')<CR>
    nmap <silent> <C-k> <Plug>(coc-diagnostic-info)

    function! s:show_documentation()
        if index(['vim', 'help'], &filetype) >= 0
            execute 'help ' . expand('<cword>')
        else
            call CocAction('doHover')
        endif
    endfunction

call plug#end()
