set nocompatible
filetype off
set mouse=
set ttymouse=

" https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')
" from cowboy to investigate later
"Plug 'tpope/vim-sensible'                                                       " Core config
"Plug 'rafi/awesome-vim-colorschemes'                                            " Color schemes
"Plug 'tpope/vim-surround'                                                       " Quotes / parens / tags
"Plug 'tpope/vim-rhubarb'                                                        " Github helper
"Plug 'tpope/vim-vinegar'                                                        " File browser (?)
"Plug 'tpope/vim-repeat'                                                         " Enable . repeat in plugins
"Plug 'tpope/vim-commentary'                                                     " (gcc) Better commenting
"Plug 'tpope/vim-unimpaired'                                                     " Pairs of mappings with [ ]
"Plug 'tpope/vim-eunuch'                                                         " Unix helpers
"Plug 'nathanaelkane/vim-indent-guides'                                          " (,ig) Visible indent guides
"Plug 'krisajenkins/vim-pipe'                                                    " (,r) Run a buffer through a command
"Plug 'krisajenkins/vim-postgresql-syntax'

Plug 'elzr/vim-json'
Plug 'edkolev/tmuxline.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" fucks with <C-J>
"Plug 'vim-latex/vim-latex'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-fugitive'
if ( has( 'python' ) || has( 'python3' ) )
Plug 'Valloric/MatchTagAlways'
endif
Plug 'tmux-plugins/vim-tmux'
Plug 'christoomey/vim-tmux-navigator'
Plug 'shime/vim-livedown' " markdown viewer
Plug 'dense-analysis/ale'
Plug 'scrooloose/nerdtree'
Plug 'editorconfig/editorconfig-vim'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'vimwiki/vimwiki'
Plug 'airblade/vim-gitgutter'
Plug 'mileszs/ack.vim'
Plug 'AndrewRadev/linediff.vim'
Plug 'chrisbra/csv.vim'
Plug 'wellle/context.vim'

let hostname = substitute(system('hostname'), '\n', '', '')
if hostname == "boethiah"
  Plug 'posva/vim-vue'
  Plug 'udalov/kotlin-vim'
  Plug 'hashivim/vim-terraform'
  Plug 'google/vim-searchindex'
  Plug 'leafgarland/typescript-vim'
endif

call plug#end()

filetype plugin indent on

let mapleader = ","


" ================ Shortcuts ====================
" edit this file
:nnoremap <leader>ev :vsplit $MYVIMRC<cr>

" re-source this file
:nnoremap <leader>sv :source $MYVIMRC<cr>

" insert tab character with shift tab
:inoremap <S-Tab> <C-V><Tab>

" ============= hex mode ===================
" command! UnXXD %s/^\%(\x*:\)\? *\(\%(\x\+\%(\s\|$\)\)\+\)\%(.\{3,}\)\?/\1/ | %!xxd -r -p
" ex command for toggling hex mode - define mapping if desired
command -bar Hexmode call ToggleHex()

" TODO: not quite 1:1 mapping

" C-H taken by tmux nav
"nnoremap <C-H> :Hexmode<CR>
"inoremap <C-H> <Esc>:Hexmode<CR>
"vnoremap <C-H> :<C-U>Hexmode<CR>
" helper function to toggle hex mode
function ToggleHex()
  " hex mode should be considered a read-only operation
  " save values for modified and read-only for restoration later,
  " and clear the read-only flag for now
  let l:modified=&mod
  let l:oldreadonly=&readonly
  let &readonly=0
  let l:oldmodifiable=&modifiable
  let &modifiable=1
  if !exists("b:editHex") || !b:editHex
    " save old options
    let b:oldft=&ft
    let b:oldbin=&bin
    " set new options
    setlocal binary " make sure it overrides any textwidth, etc.
    silent :e " this will reload the file without trickeries
              "(DOS line endings will be shown entirely )
    let &ft="xxd"
    " set status
    let b:editHex=1
    " switch to hex editor
    %!xxd -g1
  else
    " restore old options
    let &ft=b:oldft
    if !b:oldbin
      setlocal nobinary
    endif
    " set status
    let b:editHex=0
    " return to normal editing
    %!xxd -r -p
  endif
  " restore values for modified and read only state
  let &mod=l:modified
  let &readonly=l:oldreadonly
  let &modifiable=l:oldmodifiable
endfunction


" https://github.com/skwp/dotfiles/blob/master/vimrc
" ================ General Config ====================
set backspace=indent,eol,start "Allow backspace in insert mode
set history=1000 "Store lots of :cmdline history
set showcmd "Show incomplete cmds down the bottom
set showmode "Show current mode down the bottom
set visualbell "No sounds
set autoread "Reload files changed outside vim
set hidden

" === put temp files somewhere else ===
silent !mkdir -p ~/.cache/vim/backup > /dev/null 2>&1
silent !mkdir -p ~/.cache/vim/swap > /dev/null 2>&1
silent !mkdir -p ~/.cache/vim/undo > /dev/null 2>&1
silent !mkdir -p ~/.cache/vim/netrw_home > /dev/null 2>&1
set backupdir=~/.cache/vim/backup/
set directory=~/.cache/vim/swap/
set undodir=~/.cache/vim/undo/
let g:netrw_home = expand('~/.cache/vim/netrw_home')

" ================ Persistent Undo ==================
" Keep undo history across sessions, by storing in file.
" Only works all the time.
if has('persistent_undo')
  set undofile
endif

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
let g:airline#extensions#ale#enabled = 1

let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_enter = 0
let g:ale_set_signs = 0
"let g:ale_set_highlights = 0
let g:ale_open_list = 1
let g:ale_virtualtext_cursor = 'current'

" ===vim markdown preview settings===
let g:livedown_browser = "google-chrome"
let g:livedown_open = 0
map <C-P> :LivedownToggle<CR>

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


" ===Nerdtree binding===
map <C-n> :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen=1
let NERDTreeShowHidden = 1

" ===EditorConfig===
" To ensure that this plugin works well with Tim Pope's fugitive, use the
" following patterns array:
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" elzr/vim-json don't hide quotes
let g:vim_json_syntax_conceal = 0


" ============== Display stuff ============
syntax on
set scrolloff=5
set background=dark
" not sure what this one is?
set t_Co=256

" Set search hilight and colour
set hlsearch
set incsearch
hi Search cterm=NONE ctermfg=black ctermbg=blue

" show trailing whitespace
:highlight ExtraWhitespace ctermbg=red guibg=red
:match ExtraWhitespace /\s\+\%#\@<!$/

" === Column Limit ===
" https://stackoverflow.com/a/21406581
augroup collumnLimit
  autocmd!
  autocmd BufEnter,WinEnter,FileType *
        \ highlight CollumnLimitSoft ctermbg=DarkGrey guibg=DarkGrey
  let softLimit = 80
  let softPattern =
        \ '\%<' . (softLimit+2) . 'v.\%>' . (softLimit+1) . 'v'
  autocmd BufEnter,WinEnter,FileType *
        \ let w:m1=matchadd('CollumnLimitSoft', softPattern, -1)


  autocmd BufEnter,WinEnter,FileType *
        \ highlight CollumnLimitHard ctermbg=DarkRed guibg=DarkRed
  let hardLimit = 120
  let hardPattern =
        \ '\%<' . (hardLimit+2) . 'v.\%>' . (hardLimit+1) . 'v'
  autocmd BufEnter,WinEnter,FileType *
        \ let w:m1=matchadd('CollumnLimitHard', hardPattern, -1)
augroup END


" ================ Wiki ===============
let g:vimwiki_list = [{'path': '~/sync/general/notes/', 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_folding='expr'
let g:vimwiki_url_maxsave = 0
let g:vimwiki_diary_months = {
      \ 1: '01 January', 2: '02 February', 3: '03 March',
      \ 4: '04 April', 5: '05 May', 6: '06 June',
      \ 7: '07 July', 8: '08 August', 9: '09 September',
      \ 10: '10 October', 11: '11 November', 12: '12 December'
      \ }

" =============== Search ==============
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif
cnoreabbrev Ack Ack!
noremap <Leader>a :Ack! <cword>
noremap <Leader>s :Ack!<Space>
cnoreabbrev ag Ack!
cnoreabbrev aG Ack!
cnoreabbrev Ag Ack!
cnoreabbrev AG Ack!

" ================ Misc ===============
" disable folding, was an issue in tex stuff
set nofoldenable
" TODO: replace/add to pastetoggle with
" https://coderwall.com/p/if9mda/automatically-set-paste-mode-in-vim-when-pasting-in-insert-mode
set pastetoggle=<F3>

" disable system clipboard stuff
set clipboard=

" :reg will display all registers
:nnoremap "p :reg <bar> exec 'normal! "'.input('>').'p'<CR>

" auto-complete thing
set wildmenu

" default tab settings, should get overridden...
command Tab set tabstop=4 noexpandtab shiftwidth=4
command NoTab set tabstop=4 expandtab shiftwidth=4 softtabstop=4
if get(g:, '_has_set_default_indent_settings', 0) == 0
  set expandtab
  set tabstop=4
  set shiftwidth=4
  let g:_has_set_default_indent_settings = 1
endif


" Don't hide characters in markdown
let g:markdown_syntax_conceal = 0
let g:vimwiki_conceallevel=0

command FixTab call FixTabFun()
fun! FixTabFun()
  set tabstop=4
  set shiftwidth=4
  set expandtab
endfun

" auto remove whitespace
" http://stackoverflow.com/a/1618401/2423187
fun! StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
command StripTrailing call StripTrailingWhitespaces()

augroup autoStripTrailing
    autocmd!
    autocmd FileType typescript,javascript,html,css,perl,c,cpp,java,php,ruby,python autocmd BufWritePre <buffer> :call StripTrailingWhitespaces()
augroup END


let g:gitgutter_enabled = 0

nnoremap <leader>n :call ToggleGutter()<cr>

function! ToggleGutter()
  if &number
    GitGutterDisable
    set nonumber
    set norelativenumber
  else
    set number
    set relativenumber
    GitGutterEnable
  endif
endfunction

set fileformat=unix
set fileformats=unix,dos
"set nobinary


" to show all whitespace tabs spaces
":set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣
":set list

" reload vimrc on save
augroup myvimrc
    au!
    au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END

function! GSourceFun(...)
  if a:0
    let res = system('git source ' . expand('%') . ' ' . line('.'))
  else
    let res = system('git source ' . expand('%'))
  endif
  let res = substitute(res, '\n$', '', '')
  echo res
endfunction
command! -nargs=? GSource call GSourceFun(<f-args>)


function! ProfileStart()
  profile start profile.log
  profile func *
  profile file *
endfunction
command ProfileStart call ProfileStart()
function! ProfileStop()
  profile pause
  noautocmd qall!
endfunction
command ProfileStop call ProfileStop()
