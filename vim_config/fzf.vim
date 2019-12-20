scriptencoding utf-8

" FZF mappings
nnoremap <silent> <C-P> :Files<CR>
nnoremap <silent> <leader>B :Buffers<CR>
nnoremap <silent> <leader>Gf :GFiles<CR>
nnoremap <silent> <leader>G? :GFiles?<CR>
nnoremap <silent> <leader>Gb :BCommits<CR>
nnoremap <silent> <leader>Gc :Commits<CR>
nnoremap <silent> <leader>H :History:<CR>

command! -bang -nargs=* Find call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --fixed-strings '
      \   . '--ignore-case --follow --glob ''!**/.git'' --glob ''!**/node_modules'' '
      \   . '--color ''always'' '
      \   . shellescape(<q-args>)
      \   . ' | tr -d "\017"',
      \   1,
      \   <bang>0,
      \ )
noremap <C-f> :Find 
noremap <silent> <C-p> :FZF<CR>
