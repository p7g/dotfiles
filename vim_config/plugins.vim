scriptencoding utf-8

let g:colorschemes = [
      \ 'dim13/gocode.vim',
      \ 'pgdouyon/vim-yin-yang',
      \ 'sansbrina/vim-garbage-oracle',
      \ 'pbrisbin/vim-colors-off',
      \ 'owickstrom/vim-colors-paramount',
      \ 'p7g/vim-bow-wob',
      \ 'jeffkreeftmeijer/vim-dim',
      \ 'noahfrederick/vim-noctu',
      \ 'fenetikm/falcon',
      \ 'challenger-deep-theme/vim',
      \ 'djjcast/mirodark',
      \ 'junegunn/seoul256.vim',
      \ 'rakr/vim-two-firewatch',
      \ 'whatyouhide/vim-gotham',
      \ 'arzg/vim-substrata',
      \ 'relastle/bluewery.vim',
      \ 'ludokng/vim-odyssey',
      \ ]

let g:plugins = [
      \ 'tpope/vim-sleuth',
      \ 'tpope/vim-surround',
      \ 'tpope/vim-fugitive',
      \ 'tpope/vim-rsi',
      \ 'tpope/vim-dadbod',
      \ 'tpope/vim-repeat',
      \ 'tpope/vim-abolish',
      \ 'sheerun/vim-polyglot',
      \ 'editorconfig/editorconfig-vim',
      \ ['junegunn/fzf', {'build': './install --all'}],
      \ 'junegunn/fzf.vim',
      \ 'kchmck/vim-coffee-script',
      \ 'tommcdo/vim-lion',
      \ ['neoclide/coc.nvim', {'rev': 'release'}],
      \ 'sbdchd/neoformat',
      \ 'vim-perl/vim-perl6',
      \ 'gu-fan/riv.vim',
      \ 'gu-fan/InstantRst',
      \ '~/projects/rust-bytecode-vm/vim-plugin',
      \ ]

let s:deinroot = Joinpaths($HOME, '.cache', 'dein')
let s:deindir = Joinpaths(s:deinroot, 'repos', 'github.com', 'Shougo', 'dein.vim')
" install dein if it's not installed already
if !isdirectory(glob(s:deinroot))
  " check for missing dependencies
  let s:missing_deps = []
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
  call dein#add(s:deindir)

  for s:plugin in g:colorschemes + g:plugins
    if type(s:plugin) == v:t_list
      let [s:name, s:options] = s:plugin
      call dein#add(s:name, s:options)
    else
      call dein#add(s:plugin)
    endif
  endfor

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
command! CleanPlugins :call CleanPlugins()

""" colorscheme configuration
set background=dark
colorscheme odyssey
