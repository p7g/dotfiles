scriptencoding utf-8

let g:mapleader = '\'
let g:maplocalleader = '|'

" remap hjkl for Colemak (without using other keys)
noremap h k
noremap k j
noremap j h
noremap <C-w>h <C-w>k
noremap <C-w>k <C-w>j
noremap <C-w>j <C-w>h

inoremap <C-J> <Left>
inoremap <C-L> <Right>
inoremap <C-H> <Up>
inoremap <C-K> <Down>

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
command! DiffWithSaved call s:DiffWithSaved()

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

function! SynGroup()
  let l:s = synID(line('.'), col('.'), 1)
  echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun
command! SynGroup :call SynGroup()
