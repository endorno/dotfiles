"Skip initialization for vim-tiny or vim-small
if 0 | endif

" display
 " ----------------------
 " colorscheme railscasts
 set number " show line number
 set showmode " show mode
 set title " show filename
 set ruler
 "set list " show eol,tab,etc...
 "set listchars=tab:>-,trail:-,extends:>,precedes:< " eol:$
 "highlight SpecialKey cterm=NONE ctermfg=7 guifg=7
 "highlight JpSpace cterm=underline ctermfg=7 guifg=7
 "au BufRead,BufNew * match JpSpace /　/
 set laststatus=2
 " set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
 set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
 "レイアウトを維持しながら画面を閉じるコマンド kwbdを追加
 :com! Kwbd let kwbd_bn= bufnr("%")|enew|exe "bdel ".kwbd_bn|unlet kwbd_bn
 syntax enable
 syntax on
"colorscheme solarized
 set background=dark


"モードによってカーソルを切り替える（iterm2,screen用）
if &term =~ "screen"
  let &t_SI = "\eP\e]50;CursorShape=1\x7\e\\"
  let &t_EI = "\eP\e]50;CursorShape=0\x7\e\\"
elseif &term =~ "xterm"
  let &t_SI = "\e]50;CursorShape=1\x7"
  let &t_EI = "\e]50;CursorShape=0\x7"
endif

 " edit
 " ----------------------
 set autoindent
 set smartindent
 set expandtab
 set smarttab
 set tabstop=2 shiftwidth=2 softtabstop=0
 set showmatch " show mactch brace
 set wildmenu
 set clipboard=unnamed " share OS clipboard
 set autoread
 set hidden
 set showcmd
 set backspace=indent,eol,start
 "改行時にコメントを自動では続けない
 autocmd FileType * setlocal formatoptions-=ro

 highlight link ZenkakuSpace Error
 match ZenkakuSpace /　/

 " move( like emacs)
 " ----------------------
"----------------------------------------------------
" Emacs風関係
"----------------------------------------------------
" コマンド入力中断
imap <silent> <C-g> <ESC><ESC><ESC><CR>i

" 画面分割
imap <silent> <C-x>1 <ESC>:only<CR>i
imap <silent> <C-x>2 <ESC>:sp<CR>i
imap <silent> <C-x>3 <ESC>:vsp<CR>i
imap <silent> <C-x>o <ESC><C-w>w<CR>i
imap <silent> <C-x>p <ESC><C-w>p<CR>i
" 消去、編集
inoremap <expr> <C-k> "\<C-g>u".(col('.') == col('$') ? '<C-o>gJ' : '<C-o>D')
cnoremap <C-k> <C-\>e getcmdpos() == 1 ? '' : getcmdline()[:getcmdpos()-2]<CR>

imap <C-y> <ESC>pa
imap <C-d> <Del>
imap <C-h> <BackSpace>
" 移動
imap <C-a>  <Home>
imap <C-e>  <End>
imap <C-b>  <Left>
imap <C-f>  <Right>
imap <C-n>  <Down>
imap <C-p>  <UP>
"imap <ESC>< <ESC>ggi
"imap <ESC>> <ESC>Gi
"行頭、行末で次の行へ移動できる
:set whichwrap=b,s,<,>,[,],h,l
" ファイル
imap <C-c><C-c>  <ESC>:qa<CR>
imap <C-x><C-c>  <ESC>:qa!<CR>
imap <C-w><C-w>  <ESC>:w<CR>
imap <C-x><C-w>  <ESC>:w!<CR>
imap <C-x><C-f>  <ESC>:e

" エラーリカバリ
" imap <C-/> <ESC>ui

" その他
map  <C-x><C-e>  :Explore<CR>
 " search
 " ----------------------
 set incsearch
 set ignorecase
 set smartcase
 " set hlsearch

 " no bell
 set visualbell
 set t_vb=

 " backup
 " --------------------
 set backup
 set backupdir=~/.vim/.vim_backup
 set noswapfile
 "set directory=~/.vim/.vim_swap

 " key map
 " --------------------
 let mapleader = "\\"
 noremap <CR> o<ESC>
 set pastetoggle=<F2>
 " auto command
 " --------------------
 augroup BufferAu
    autocmd!
    " change current directory
    autocmd BufNewFile,BufRead,BufEnter * if isdirectory(expand("%:p:h")) && bufname("%") !~ "NERD_tree" | cd %:p:h | endif
 augroup END

 " Plugin setting
 " --------------------

 " NERD Commenter " コメント化を自動で行う
 "let NERDSpaceDelims = 1 "コメント文字とスクリプトの間のスペースの数
 nmap ,, <Plug>NERDCommenterToggle
 vmap ,, <Plug>NERDCommenterToggle
 ""nmap ,a <Plug>NERDCommenterAppend " dfas
 vmap ,p <Plug>NERDCommenterSexy

 "NERD Tree
 nmap <F9> :NERDTreeToggle
 "ファイル指定が無ければ自動でNERDTreeを開く
  let file_name = expand("%")
  if has('vim_starting') &&  file_name == ""
    autocmd VimEnter * NERDTree ./
  endif
 "最後に残った窓がnerd treeなら終了
  autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
 " rails.vim
 let g:rails_level=3

 " Perl
 autocmd FileType perl,cgi :compiler perl
 "template fiel for mojolicious
 au BufRead,BufNewFile *.html.ep  set filetype=html
 "TODO change to only perl source
 noremap <C-i> :Perldoc<CR>
 setlocal iskeyword-=/
 setlocal iskeyword+=:

 let g:quickrun_config = {}
 let g:quickrun_config['*'] = {'runner': 'vimproc','split': 'below'}
 nmap <Leader>r <plug>(quickrun)
 "
 "" unite.vim {{{
 " 起動時にインサートモードで開始しない
 let g:unite_enable_start_insert = 0

 " The prefix key.
 nnoremap    [unite]   <Nop>
 "nmap    <Leader>f [unite]
 nmap <silent>f [unite]

 " unite.vim keymap
 " https://github.com/alwei/dotfiles/blob/3760650625663f3b08f24bc75762ec843ca7e112/.vimrc
 "nnoremap <silent> [unite]f :<C-u>Unite -no-quit -vertical -winwidth=40<Space>file<CR>
 nnoremap <silent> [unite]b :<C-u>Unite<Space>buffer<CR>
 nnoremap <silent> [unite]m :<C-u>Unite<Space>file_mru<CR>
 nnoremap <silent> [unite]r :<C-u>UniteResume<CR>
 nnoremap <C-e> :NERDTreeToggle<CR>
 "nnoremap <silent> [unite]f  :VimFiler -buffer-name=explorer -split -winwidth=45 -toggle -no-quit<Cr>
 let g:vimfiler_default_columns = ''

 " vinarise
 let g:vinarise_enable_auto_detect = 1
 " unite-build map

 " C-g で終了する
 au FileType unite nnoremap <silent> <buffer> <C-g> :q<CR>
 au FileType unite inoremap <silent> <buffer> <C-g> <ESC>:q<CR>"
 autocmd! FileType vimfiler call g:my_vimfiler_settings()

 function! s:my_vimfiler_settings()
   "nmap     <buffer><expr><Cr> vimfiler#smart_cursor_map("\<Plug>(vimfiler_expand_tree)", "\<Plug>(vimfiler_edit_file)")
   "nmap     <buffer><expr><Cr> vimfiler#smart_cursor_map("\<Plug>(vimfiler_cd_vim_current_dir)", "\<Plug>(vimfiler_edit_file)")
   nnoremap <buffer>v          :call vimfiler#mappings#do_action('my_vsplit')<Cr>
   "nmap f
 endfunction

 let s:my_action = { 'is_selectable' : 1 }
 function! s:my_action.func(candidates)
   wincmd p
   exec 'vsplit '. a:candidates[0].action__path
 endfunction
 "call unite#custom_action('file', 'my_vsplit', s:my_action)
 "" "}}}

 let g:neosnippet#disable_runtime_snippets = {
         \   '_' : 1,
         \ }
