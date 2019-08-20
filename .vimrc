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

for s:p in ['undo', 'backups', 'tmp']
  call s:assertdir(s:joinpaths($vimdir, s:p))
endfor

let s:deinroot = s:joinpaths($HOME, '.cache', 'dein')
let s:deindir = s:joinpaths(s:deinroot, 'repos', 'github.com', 'Shougo', 'dein.vim')
" install dein if it's not installed already
if !isdirectory(glob(s:deinroot))
  " check for missing dependencies
  s:missing_deps = []
  for s:dep in ['git', 'node', 'npm']
    if !executable(s:dep)
      call add(s:missing_deps, s:dep)
    endif
  endfor
  if len(s:missing_deps)
    echoerr 'Missing dependencies: ' . join(s:missing_deps, ', ')
    finish
  endif

  echom 'Installing dein'
  execute '!git clone https://github.com/Shougo/dein.vim ' . s:deindir
endif

let &runtimepath .= ',' . s:deindir
if dein#load_state(s:deinroot)
  call dein#begin(s:deinroot)

  " Let dein manage dein
  " Required:
  call dein#add(s:deindir)

  " Add or remove your plugins here like this:
  call dein#add('dim13/gocode.vim')
  call dein#add('pgdouyon/vim-yin-yang')
  call dein#add('sansbrina/vim-garbage-oracle')
  call dein#add('pbrisbin/vim-colors-off')

  call dein#add('tpope/vim-sleuth')
  call dein#add('tpope/vim-surround')
  call dein#add('sheerun/vim-polyglot')
  call dein#add('editorconfig/editorconfig-vim')
  call dein#add('/usr/local/opt/fzf')
  call dein#add('junegunn/fzf.vim')
  call dein#add('tpope/vim-fugitive')
  call dein#add('tpope/vim-rsi')
  call dein#add('kchmck/vim-coffee-script')
  call dein#add('tommcdo/vim-lion')
  call dein#add('neoclide/coc.nvim', {'rev': 'release'})
  call dein#add('tpope/vim-dadbod')
  call dein#add('sbdchd/neoformat')

  " Required:
  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif

function! CleanPlugins()
  for l:path in dein#check_clean()
    echom 'Deleting ' . l:path
    call delete(fnameescape(l:path), 'rf')
  endfor
endfunction

let s:coc_extensions = [
      \ 'coc-json',
      \ 'coc-tsserver',
      \ 'coc-html',
      \ 'coc-css',
      \ 'coc-python',
      \ 'coc-emmet',
      \ 'coc-git',
      \ 'coc-vimlsp',
      \ 'coc-prettier',
      \ 'coc-tabnine',
      \ ]

function! InstallCocExtensions()
  for l:extension in s:coc_extensions
    execute 'CocInstall ' . l:extension
  endfor
endfunction

filetype plugin indent on
syntax on

""" colorscheme configuration
set background=light
colorscheme yang

if has('gui') && !has('nvim')
  set guifont=IBMPlexMono-Text:h15
endif

set autoindent
set autoread   " reload files when changed externally
set backupdir=$vimdir/backups
set belloff=all
set colorcolumn=160
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
set shiftwidth=2
set signcolumn=yes
set smartcase
set smartindent
set splitbelow
set splitright
set tabstop=4
set termguicolors
set undodir=$vimdir/undo
set undofile
set updatetime=300
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
set statusline+=%{get(b:,'coc_current_function','')}
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

command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" ' . shellescape(<q-args>) . '| tr -d "\017"', 1, <bang>0)
noremap <silent> <C-p> :FZF<CR>

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

augroup comment_textwidth
  autocmd!
  " set the textwidth to the value of colorcolumn when in a comment
  autocmd TextChanged,TextChangedI * :call s:AdjustTextWidth()
augroup END

function! s:AdjustTextWidth() abort
  let l:syn_element = synIDattr(synID(line('.'), col('.') - 1, 1), 'name')
  let &textwidth = syn_element =~? 'comment' ? &cc : 0
endfunction

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
xmap <leader>f <Plug>(coc-format-selected)
nmap <leader>f :call CocAction('format')<CR>
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <S-TAB> <Plug>(coc-range-select-backword)
nmap <silent> <C-k> <Plug>(coc-diagnostic-info)

augroup cocsettings
  autocmd!
  autocmd CursorHold * silent call CocActionAsync('highlight')
augroup END

function! s:show_documentation()
  if index(['vim', 'help'], &filetype) >= 0
    execute 'h ' . expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction


" FZF mappings
nnoremap <silent> <C-P> :Files<CR>
nnoremap <silent> <leader>B :Buffers<CR>
nnoremap <silent> <leader>Gf :GFiles<CR>
nnoremap <silent> <leader>G? :GFiles?<CR>
nnoremap <silent> <leader>Gb :BCommits<CR>
nnoremap <silent> <leader>Gc :Commits<CR>
nnoremap <silent> <leader>H :History:<CR>

" rst stuff
function! RSTMakeTitle(level) abort
  let l:underline_char = ['=', '=', '-', '\~', '#', '$', '+'][a:level]
  normal yyp
  execute 's/./' . l:underline_char . '/g'
  let @/=''
  normal! o
  normal! o
endfunction

augroup filetype_rst
  autocmd!

  autocmd filetype rst nnoremap <leader>t :<C-U>call RSTMakeTitle(v:count)<CR>
augroup END

" neoformat config
let g:neoformat_python_black = {
      \ 'exe': 'tan',
      \ 'args': ['-'],
      \ 'stdin': 1,
      \ 'no_append': 1,
      \ }

let g:neoformat_enabled_python = ['black']
