set nocompatible

filetype plugin indent on

execute pathogen#infect()
"Bundle 'edkolev/tmuxline.vim'
"Bundle 'bling/vim-airline'
"Bundle 'christoomey/vim-tmux-navigator'



set t_Co=256

set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
set autoindent smartindent cindent
syntax on
set background=dark
set pastetoggle=<F3>

set scrolloff=5

set mouse=

" https://github.com/skwp/dotfiles/blob/master/vimrc
" ================ General Config ====================
set backspace=indent,eol,start "Allow backspace in insert mode
set history=1000 "Store lots of :cmdline history
set showcmd "Show incomplete cmds down the bottom
set showmode "Show current mode down the bottom
set visualbell "No sounds
set autoread "Reload files changed outside vim

" ================ Persistent Undo ==================
" Keep undo history across sessions, by storing in file.
" Only works all the time.
if has('persistent_undo')
	silent !mkdir ~/.vim/backups > /dev/null 2>&1
	set undodir=~/.vim/backups
	set undofile
endif

" ===Remvoe silly temp files ===
set backupdir=~/.vim/tmp,.
set directory=~/.vim/tmp,.

" The vimairline plugin stuff
set laststatus=2
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"
let g:airline_theme='wombat'

let g:airline#extensions#tabline#enabled = 1
set hidden


" autoremove trailing whitespace
autocmd FileType css,tex,c,cpp,java,php,pl,html autocmd BufWritePre <buffer> :%s/\s\+$//e


command SpellOn setlocal spell spelllang=en_us

set nofoldenable    " disable folding
