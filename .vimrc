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

function! CoqStatus()
    let l:diagnostics = v:lua.require'lsp-status'.diagnostics()
    let l:status = []
    if l:diagnostics.errors > 0
        eval l:status->add('❌ ' . l:diagnostics.errors)
    endif
    if l:diagnostics.warnings > 0
        eval l:status->add('⚠️ ' . l:diagnostics.warnings)
    endif
    if l:diagnostics.info > 0
        eval l:status->add('ℹ️ ' . l:diagnostics.info)
    endif
    return l:status->join('  ')
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
set statusline+=\ %{CoqStatus()}
set statusline+=%=        " switch to right side
set statusline+=%P        " percentage through file
set statusline+=\         " space after percentage


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
inoremap <C-Space> <nop>
noremap <C-Space> <nop>

" quickfix stuff
nnoremap <silent><expr> <leader>q empty(filter(getwininfo(), 'v:val.quickfix')) ? ':copen<CR>' : ':cclose<CR>'
nnoremap <silent> ]q :cnext<CR>
nnoremap <silent> [q :cprev<CR>

" loclist stuff
nnoremap <silent><expr> <leader>l empty(filter(getwininfo(), 'v:val.loclist')) ? ':lopen<CR>' : ':lclose<CR>'
nnoremap <silent> ]l :lnext<CR>
nnoremap <silent> [l :lprev<CR>


" --- Commands

command! -bang Bonly :call <SID>bufonly('<bang>')
function! s:bufonly(bang)
    let l:currentbuf = bufnr('%')
    let l:bufs = getbufinfo()

    " Abort early if not called with ! and there are changed buffers
    for l:buf in l:bufs
        if l:buf['bufnr'] == l:currentbuf
            continue
        elseif l:buf['changed'] && a:bang ==# ''
            echohl ErrorMsg
            echomsg bufname(l:buf['bufnr']) 'has unsaved changes, use ! to force delete'
            echohl None
            return
        endif
    endfor

    let g:_bufonly_delete_count = 0
    let l:cmd = 'if bufnr() != ' . l:currentbuf
                \ . ' | bdelete' . a:bang
                \ . ' | let g:_bufonly_delete_count += 1'
                \ . ' | endif'
    execute 'bufdo ' . l:cmd
    echomsg g:_bufonly_delete_count 'buffer(s) deleted'
    unlet g:_bufonly_delete_count
endfunction

command! ProfileStart :call <SID>profile_start()
command! ProfileStop :call <SID>profile_stop()
function! s:profile_start()
    profile start $vimdir/profile.out
    profile func *
    profile file *
endfunction
function! s:profile_stop()
    profile stop
endfunction


" --- augroups

" automatically change to non-relative numbers when not active buffer
augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave * call <SID>set_relativenumber(1)
    autocmd BufLeave,FocusLost,InsertEnter   * call <SID>set_relativenumber(0)
augroup END
function! s:set_relativenumber(on)
    if !exists("b:disable_numbertoggle")
       let &relativenumber = a:on
    endif
endfunction

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

augroup comment_textwidth
    autocmd!
    " set the textwidth to the value of colorcolumn when in a comment
    autocmd FileType markdown,rst,gitcommit let b:dont_adjust_tw = 1
    autocmd TextChanged,TextChangedI * call <SID>adjust_text_width()
augroup END

function! s:adjust_text_width() abort
    if exists('b:dont_adjust_tw')
        return
    endif
    let l:syn_element = synID(line('.'), col('.') - 1, 1)->synIDattr('name')
    let &l:textwidth = l:syn_element =~? 'comment' ? &l:colorcolumn - 1 : 0
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
if glob(s:autoload_path . '/plug.vim')->empty()
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
Plug 'arzg/vim-colors-xcode'
Plug 'cocopon/iceberg.vim'
Plug 'cormacrelf/vim-colors-github'
Plug 'dim13/gocode.vim'
Plug 'junegunn/seoul256.vim'
Plug 'morhetz/gruvbox'
Plug 'robertmeta/nofrils'
Plug 'sainnhe/everforest'

Plug 'mcchrish/zenbones.nvim'
    let g:duckbones_compat = 1
    let g:forestbones_compat = 1
    let g:kanagawabones_compat = 1
    let g:neobones_compat = 1
    let g:nordbones_compat = 1
    let g:randombones_compat = 1
    let g:rosebones_compat = 1
    let g:seoulbones_compat = 1
    let g:tokyobones_compat = 1
    let g:vimbones_compat = 1
    let g:zenbones_compat = 1

" Plugins
Plug 'AndrewRadev/splitjoin.vim'
Plug 'airblade/vim-gitgutter'
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/fzf', {'do': {-> fzf#install()}}
Plug 'junegunn/gv.vim'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'nvim-lua/lsp-status.nvim'
Plug 'tommcdo/vim-lion'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dadbod'
Plug 'tpope/vim-dotenv'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'

Plug 'chrisbra/unicode.vim'
    nnoremap <silent> ga :UnicodeName<CR>

Plug 'junegunn/fzf.vim'
    nnoremap <silent> <C-p> :FZF<CR>

Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
    let g:coq_settings = {
                \ 'auto_start': 'shut-up',
                \ 'xdg': has('nvim') ? v:true : v:false,
                \ 'keymap.recommended': v:false,
                \ 'keymap.bigger_preview': v:null,
                \ }

Plug 'neovim/nvim-lspconfig'
    nnoremap <silent> <leader>d :lua vim.diagnostic.setloclist()<CR>
    nnoremap <silent> ]c :lua vim.diagnostic.goto_next()<CR>
    nnoremap <silent> [c :lua vim.diagnostic.goto_prev()<CR>
    nnoremap <silent> gd :lua vim.lsp.buf.definition()<CR>
    nnoremap <silent> gD :lua vim.lsp.buf.declaration()<CR>
    nnoremap <silent> gi :lua vim.lsp.buf.implementation()<CR>
    nnoremap <silent> gy :lua vim.lsp.buf.type_definition()<CR>
    nnoremap <silent> K :lua vim.lsp.buf.hover()<CR>
    nnoremap <silent> gr :lua vim.lsp.buf.references()<CR>
    nnoremap <silent> rn :lua vim.lsp.buf.rename()<CR>

Plug 'p7g/Sunset'
    let g:sunset_latitude = 45
    let g:sunset_longitude = -75
    " Reload sunset every day so that it recomputes the sunrise and sunset times
    " for the current day.
    let s:current_day_of_year = strftime('%j')
    function! s:reinit_sunset_if_new_day()
        let l:doy = strftime('%j')
        if l:doy != s:current_day_of_year
            call Sunset_recalculate()
        endif
    endfunction
    augroup sunset_reload
        autocmd!
        autocmd CursorHold * nested call <SID>reinit_sunset_if_new_day()
    augroup END

Plug 'p7g/vim-prettier'
    let g:prettier#quickfix_enabled = 0

    augroup prettier_init
        autocmd!
        autocmd FileType javascript,javascriptreact,typescript,typescriptreact
                    \ nnoremap <buffer><silent> <leader>f <Plug>(Prettier) |
                    \ xnoremap <buffer><silent> <leader>f <Plug>(PrettierFragment)
    augroup END

Plug 'psf/black', {'branch': 'stable'}
    augroup black_init
        autocmd!
        autocmd FileType python nnoremap <buffer><silent> <leader>f :Black<CR>
    augroup END

Plug 'rhysd/conflict-marker.vim'  " try to fix ct not being unbound
    command! ConflictMarkerUnbind :call <SID>conflict_marker_unmap()
    function! s:conflict_marker_unmap()
        nunmap <buffer>]x <Plug>(conflict-marker-next-hunk)
        nunmap <buffer>[x <Plug>(conflict-marker-prev-hunk)
        nunmap <buffer>ct <Plug>(conflict-marker-themselves)
        nunmap <buffer>co <Plug>(conflict-marker-ourselves)
        nunmap <buffer>cn <Plug>(conflict-marker-none)
        nunmap <buffer>cb <Plug>(conflict-marker-both)
        nunmap <buffer>cB <Plug>(conflict-marker-both-rev)
    endfunction

Plug 'rhysd/git-messenger.vim'
    nnoremap <silent> gb :GitMessenger<CR>

Plug 'sheerun/vim-polyglot'
    let g:python_pep8_indent_searchpair_timeout = 75

Plug 'vim-scripts/ReplaceWithRegister'
    nmap gp <Plug>ReplaceWithRegisterOperator
    nmap gpp <Plug>ReplaceWithRegisterLine
    xmap gp <Plug>ReplaceWithRegisterVisual

call plug#end()

lua <<EOF
local lspconfig = require("lspconfig")

lspconfig.pyright.setup{}
lspconfig.eslint.setup{}
lspconfig.tsserver.setup{}
EOF

colorscheme rosebones
