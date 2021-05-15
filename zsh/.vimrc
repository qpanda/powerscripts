syntax on
filetype plugin indent on
highlight SpecialKey ctermfg=8 guifg=DimGrey

nmap <Leader>q :q<CR>
nmap <Leader>Q :qa<CR>
nmap <Leader>x :x<CR>
nmap <Leader>X :xa<CR>
nmap <Leader>w :set wrap!<CR>
nmap <Leader>W :set nowrap<CR>
nmap <Leader>s :set list!<CR>
nmap <Leader>S :set list<CR>
nmap <Leader>p :set paste!<CR>
nmap <Leader>P :set nopaste<CR>
nmap <Leader>h :set hlsearch!<CR>
nmap <Leader>H :set nohlsearch<CR>
nmap <Leader>l :diffget local<CR>
nmap <Leader>L :1,$+1diffget local<CR>
nmap <Leader>r :diffget remote<CR>
nmap <Leader>R :1,$+1diffget remote<CR>
nmap <Leader>b :diffget base<CR>
nmap <Leader>B :1,$+1diffget base<CR>

set autoread
set belloff=all
set history=10000
set sessionoptions-=options
set ttimeoutlen=50
set ttyfast
set viminfo+=!
set ffs=unix,dos,mac
set encoding=utf-8
set fileencoding=utf-8

set nobackup
set noswapfile
set nowritebackup

set display=lastline
set laststatus=2
set ruler
set showcmd
set breakindent
set linebreak
set listchars=nbsp:·,space:·,trail:·,tab:»›,extends:>,precedes:<

set autoindent
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4

set incsearch
set ignorecase
set smartcase
set hlsearch

set backspace=indent,eol,start
set formatoptions=tcqj
set complete-=i
set sidescroll=1
set smarttab

set wildmenu
set wildmode=list:longest,full
