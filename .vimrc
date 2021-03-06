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
function! Assertdir(path)
  if !isdirectory(a:path)
    let l:path = shellescape(a:path)
    if s:haswin
      silent execute '!New-Item -Path "' . l:path . '" -Type Directory'
    else
      silent execute '!mkdir -p ' . l:path
    endif
  endif
endfunction

function! Joinpaths(...)
  return join(a:000, s:pathsep)
endfunction

" When resolving the current file location, resolve symlinks before getting the
" dirname, since this vimrc file will be symlinked somewhere else but the
" vim_config path is in this dotfiles directory
let s:current_dir = fnamemodify(resolve(expand('<sfile>')), ':p:h')
function! s:include(...)
  for l:path in a:000
    execute 'source ' . Joinpaths(s:current_dir, l:path)
  endfor
endfunction

" try to figure out where the .vim equivalent directory is
if has('nvim')
  let $vimdir = stdpath('config')
else
  let $vimdir = resolve(expand('<sfile>:p:h'))
  if $vimdir ==# $HOME
  if s:haswin
    let s:path = Joinpaths($HOME, 'vimfiles')
  else
    let s:path = Joinpaths($HOME, '.vim')
  endif
  call Assertdir(s:path)
  let $vimdir = s:path
  endif
endif

for s:p in ['undo', 'backups', 'tmp']
  call Assertdir(Joinpaths($vimdir, s:p))
endfor

" Base includes with settings, keybindings not dependent on plugins, and some
" autogroups that also don't depend on plugins
let s:includes = [
      \ 'vim_config/settings.vim',
      \ 'vim_config/bindings.vim',
      \ 'vim_config/filetype.vim',
      \ ]

" A 'fast' mode which doesn't include any plugins (it's very fast)
if $__VIM_MODE ==? 'fast'
  " Pick a half-decent colorscheme in the absence of those installed with dein
  colorscheme darkblue
else
  " include all the plugins and stuff
  let s:includes += [
        \ 'vim_config/plugins.vim',
        \ 'vim_config/coc.vim',
        \ 'vim_config/fzf.vim',
        \ ]
endif

call call('s:include', s:includes)

filetype plugin indent on
syntax on
