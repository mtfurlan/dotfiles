set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'edkolev/tmuxline.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'vim-latex/vim-latex'
Plugin 'tpope/vim-sleuth'
Plugin 'tpope/vim-fugitive'
Plugin 'Valloric/MatchTagAlways'
Plugin 'christoomey/vim-tmux-navigator'
"Plugin 'JamshedVesuna/vim-markdown-preview'
Plugin 'suan/vim-instant-markdown'
Plugin 'scrooloose/syntastic'
Plugin 'scrooloose/nerdtree'
Plugin 'leafgarland/typescript-vim'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'vim-scripts/Conque-GDB'
Plugin 'vivien/vim-linux-coding-style'

call vundle#end()
filetype plugin indent on


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

" ============== Plugin Configs ===============
" ===The vimairline plugin stuff===
set laststatus=2
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_theme='wombat'

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
set hidden

" ===vim-markdown-preview settings===
let vim_markdown_preview_github=1
let g:instant_markdown_autostart = 0
map <C-P> :InstantMarkdownPreview<CR>

" === Tmuxline ===
"	\'c'    : '#H',
let g:tmuxline_preset = {
    \'a'    : '#S',
    \'b'    : '#W',
    \'win'  : '#I #W',
    \'cwin' : '#I #W',
    \'x'    : '#(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "time to empty|percentage" |xargs echo)',
    \'y'    : ['%Y-%m-%d', '%H:%M'],
    \'z'    : '#h',
    \'options': {
        \'status-justify': 'left'
    \}
\}

" === Syntastic ===
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers=['eslint']
if executable('node_modules/.bin/eslint')
  let b:syntastic_javascript_eslint_exec = 'node_modules/.bin/eslint'
endif
let g:syntastic_mode_map = { 'mode': 'passive' }

let g:linuxsty_patterns = [ ]

" ===Nerdtree binding===
map <C-n> :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen=1


" ============== Display stuff ============
syntax on
set scrolloff=5
set background=dark
" not sure what this one is?
set t_Co=256

" Set search hilight and colour
set hlsearch
hi Search cterm=NONE ctermfg=grey ctermbg=blue

" show trailing whitespace
:highlight ExtraWhitespace ctermbg=red guibg=red
:match ExtraWhitespace /\s\+\%#\@<!$/

" auto remove whitespace
" http://stackoverflow.com/a/1618401/2423187
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

autocmd FileType javascript,html,css,perl,c,cpp,java,php,ruby,python autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

" === Column Limit ===
" https://stackoverflow.com/a/21406581
augroup collumnLimit
  autocmd!
  autocmd BufEnter,WinEnter,FileType *
        \ highlight CollumnLimit ctermbg=DarkGrey guibg=DarkGrey
  let collumnLimit = 79 " feel free to customize
  let pattern =
        \ '\%<' . (collumnLimit+1) . 'v.\%>' . collumnLimit . 'v'
  autocmd BufEnter,WinEnter,FileType *
        \ let w:m1=matchadd('CollumnLimit', pattern, -1)
augroup END

" ================ Misc ===============
" disable folding, was an issue in tex stuff
set nofoldenable
set pastetoggle=<F3>

" Thing from robin for clipboard stuff
" Don't think it works
set clipboard=unnamedplus

" default tab settings, should get overridden...
command Tab set tabstop=4 noexpandtab shiftwidth=4
command NoTab set tabstop=4 expandtab shiftwidth=4 softtabstop=4
set tabstop=4
