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
set grepprg=rg\ --vimgrep
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

fun! CocStatus()
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
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END


" --- key bindings
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

" resize split with ctrl-arrows
nnoremap <silent> <C-Up> :resize +5<CR>
nnoremap <silent> <C-Down> :resize -5<CR>
nnoremap <silent> <C-Left> :vertical resize -5<CR>
nnoremap <silent> <C-Right> :vertical resize +5<CR>

" clear search highlight with <leader>space
nnoremap <silent> <leader><space> :let @/=""<CR>


" --- filetype augroups
"
augroup filetype_overrides
  autocmd!
  autocmd BufRead *.variables set filetype=less
  autocmd BufRead .eslintrc set filetype=json5
augroup END

augroup filetype_javascript
  autocmd!
  " run the current file/selection with <localleader>r
  autocmd FileType javascript noremap <localleader>r :w !node -<CR>
augroup END

" disable changes to indentation settings when opening a python file
let g:python_recommended_style = 0
augroup filetype_python
  autocmd!
  " run the current file/selection with <localleader>r
  autocmd FileType python noremap <localleader>r :w !python -<CR>
  autocmd FileType python setlocal noexpandtab shiftwidth=4 tabstop=4 softtabstop=4
  autocmd FileType python setlocal formatoptions+=croql
augroup END

augroup comment_textwidth
  autocmd!
  " set the textwidth to the value of colorcolumn when in a comment
  autocmd FileType markdown,rst let b:dontAdjustTextWidth = 1
  autocmd TextChanged,TextChangedI * :call AdjustTextWidth()
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

let s:colorschemes = [
      \ 'dim13/gocode.vim',
      \ 'junegunn/seoul256.vim',
      \ 'arzg/vim-colors-xcode',
      \ 'cormacrelf/vim-colors-github',
      \ ]

let s:plugins = [
      \ ['neoclide/coc.nvim', {'branch': 'release'}],
      \ 'tpope/vim-sleuth',
      \ 'tpope/vim-surround',
      \ 'tpope/vim-fugitive',
      \ 'tpope/vim-rsi',
      \ 'tpope/vim-dadbod',
      \ 'tpope/vim-repeat',
      \ 'tpope/vim-abolish',
      \ 'sheerun/vim-polyglot',
      \ 'editorconfig/editorconfig-vim',
      \ ['junegunn/fzf', {'do': 'yes \| ./install --all'}],
      \ 'junegunn/fzf.vim',
      \ 'tommcdo/vim-lion',
      \ 'vim-scripts/Sunset',
      \ 'kristijanhusak/vim-dadbod-ui',
      \ 'tpope/vim-dotenv',
      \ 'rhysd/conflict-marker.vim',
      \ ]

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

for s:plugin in s:colorschemes + s:plugins
  if type(s:plugin) == v:t_list
    let [s:name, s:options] = s:plugin
    execute 'Plug ' . string(s:name) . ', ' . string(s:options)
  else
    execute 'Plug ' . string(s:plugin)
  endif
endfor 

call plug#end()


" --- colorscheme stuff

set background=light
colorscheme github

let g:sunset_latitude = 45
let g:sunset_longitude = -75

function! Sunset_daytime_callback()
  set background=light
  colorscheme github
endfunction

function! Sunset_nighttime_callback()
  set background=dark
  colorscheme github
endfunction


" --- coc.nvim configuration

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
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>a :<C-u>CocList outline<CR>
nmap <leader>q :<C-u>CocList -I symbols<CR>
nnoremap <silent> K :call <SID>show_documentation()<CR>
xmap <silent> <leader>f <Plug>(coc-format-selected)
nmap <silent> <leader>f :call CocAction('format')<CR>
nmap <silent> <C-k> <Plug>(coc-diagnostic-info)

xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

function! s:show_documentation()
  if index(['vim', 'help'], &filetype) >= 0
    execute 'help ' . expand('<cword>')
  else
    call CocAction('hover')
  endif
endfunction


" fzf mappings

nnoremap <silent> <C-p> :FZF<CR>
