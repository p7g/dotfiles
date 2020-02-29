scriptencoding utf-8

let s:coc_extensions = [
      \ 'coc-json',
      \ 'coc-tsserver',
      \ 'coc-html',
      \ 'coc-css',
      \ 'coc-python',
      \ 'coc-emmet',
      \ 'coc-eslint',
      \ 'coc-git',
      \ 'coc-vimlsp',
      \ 'coc-prettier',
      \ 'coc-rls',
      \ 'coc-clock',
      \ 'coc-terminal',
      \ 'coc-calc',
      \ 'coc-go',
      \ ]

function! InstallCocExtensions()
  for l:extension in s:coc_extensions
    execute 'CocInstall ' . l:extension
  endfor
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
nmap <leader>a :<C-u>CocList outline<CR>
nmap <leader>q :<C-u>CocList -I symbols<CR>
nnoremap <silent> K :call <SID>show_documentation()<CR>
xmap <silent> <leader>f <Plug>(coc-format-selected)
nmap <silent> <leader>f :call CocAction('format')<CR>
nmap <silent> <C-k> <Plug>(coc-diagnostic-info)
nmap <silent> <leader>clock :ClockToggle<CR>
nmap <silent> <leader>calc <Plug>(coc-calc-result-replace)
nmap <silent> <leader>tt <Plug>(coc-terminal-toggle)
nmap <silent> <leader>td :CocCommand terminal.Destroy<CR>

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" augroup cocsettings
"   autocmd!
"   autocmd CursorHold * silent call CocActionAsync('highlight')
" augroup END

function! s:show_documentation()
  if index(['vim', 'help'], &filetype) >= 0
    execute 'h ' . expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

let s:clockOn = 0
function! s:toggleClock()
  if s:clockOn
    CocCommand clock.disable
  else
    CocCommand clock.enable
  endif
  let s:clockOn = !s:clockOn
endfunction
command! ClockToggle call s:toggleClock()
