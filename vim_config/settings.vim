scriptencoding utf-8

if has('gui') && !has('nvim')
  set guifont=IBMPlexMono-Text:h19
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
set numberwidth=4
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
set termguicolors
set undodir=$vimdir/undo
set undofile
set updatetime=300
set wrap
set writebackup

set statusline=%#LineNr#  " match number column hightlighting
set statusline+=\         " space before any text
set statusline+=%f        " filename, no directory
set statusline+=\         " space
set statusline+=%m        " modified flag
set statusline+=%r        " readonly flag
set statusline+=%h        " helpfile flag
set statusline+=%w        " preview window flag
set statusline+=%q        " quickfix window flag

if exists('*coc#status')
  set statusline+=\ %{coc#status()}
endif

set statusline+=%{get(b:,'coc_current_function','')}
set statusline+=%=        " switch to right side
set statusline+=%P        " percentage through file
set statusline+=\         " space after percentage

" automatically change to non-relative numbers when not active buffer
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END
