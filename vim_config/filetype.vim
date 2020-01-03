scriptencoding utf-8

" filetype stuff

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

augroup filetype_php
  autocmd!
  " run the current file/selection with <localleader>r
  autocmd FileType php noremap <localleader>r :w !php -r
        \ '$f = file_get_contents("php://stdin");'
        \ . '$pos = strpos($f, "<?php");'
        \ . '$code = $pos === 0 ? substr($f, $pos + strlen("<?php")) : $f;'
        \ . 'eval($code);'<CR>
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

augroup filetype_ruby
  autocmd!
  " run the current file/selection with <localleader>r
  autocmd FileType ruby noremap <localleader>r :w !ruby -<CR>
augroup END

augroup filetype_julia
  autocmd!
  " run the current file/selection with <localleader>r
  autocmd FileType julia noremap <localleader>r :w !julia<CR>
augroup END

augroup comment_textwidth
  autocmd!
  " set the textwidth to the value of colorcolumn when in a comment
  autocmd FileType markdown,rst let b:dontAdjustTextWidth = 1
  autocmd TextChanged,TextChangedI * :call AdjustTextWidth()
augroup END

let g:comment_width = 80
function! AdjustTextWidth() abort
  if exists('b:dontAdjustTextWidth')
    return
  endif
  let l:syn_element = synIDattr(synID(line('.'), col('.') - 1, 1), 'name')
  let &textwidth = syn_element =~? 'comment' ? g:comment_width : 0
endfunction

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
