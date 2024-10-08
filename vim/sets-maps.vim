syntax on

" hovel settings -----------------------------------------------------------------------------------
" share system clipboard
set clipboard+=unnamedplus,unnamed

" show line number
set number
set relativenumber

" case insensitive
set ignorecase

" only support command mode, no click
set mouse=a

let $LANG = 'en_US'

" tab settings
set tabstop=4
set shiftwidth=4
set softtabstop=4

" let tap become four spaces
set expandtab

" autoindent
set autoindent

" foldmethod
set foldmethod=syntax
set nofoldenable

" auto sync 
set autoread

" disable error bells
set noerrorbells 
set novisualbell

" set double key separation time
set timeoutlen=200

" set no swap file
set noswapfile

set cursorline
set cursorlineopt=number

" When scrolling vertically, the cursor is kept 5 rows away from the top/bottom
""set scrolloff=5

" Notice : nvim has remove these features
" Use a line cursor within insert mode and a block cursor everywhere else.
"
" Reference chart of values:
"   Ps = 0  -> blinking block.
"   Ps = 1  -> blinking block (default).
"   Ps = 2  -> steady block.
"   Ps = 3  -> blinking underline.
"   Ps = 4  -> steady underline.
"   Ps = 5  -> blinking bar (xterm).
"   Ps = 6  -> steady bar (xterm).
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" Break line at predefined characters
set linebreak
" Character to show before the lines that have been soft-wrapped
set showbreak=↪\ 


" jump to the last position when reopening a file
augroup resCur
  autocmd!
  autocmd BufReadPost * call setpos(".", getpos("'\""))
augroup END

set incsearch
set hlsearch

vnoremap y "+y
vnoremap d "+d
vnoremap p "+p
vnoremap yy "+yy
vnoremap dd "+dd

nnoremap y "+y
nnoremap d "+d
nnoremap p "+p
nnoremap yy "+yy
nnoremap dd "+dd

" visual block short-cut
nnoremap vv <C-v>

" paste in command mod
cnoremap <C-v> <C-r>"

" show current buffer path
cnoreabbrev fd echo expand("%:p:h")

if has('nvim')
    cnoreabbrev vt vs \| term
    cnoreabbrev st sp \| term
else
    cnoreabbrev vt vert term
    cnoreabbrev st term
endif


" auto pair ---------------------------------------------------------------------------------------
inoremap { {}<LEFT>
inoremap ( ()<LEFT>
inoremap [ []<LEFT>
inoremap ' ''<LEFT>
inoremap " ""<LEFT>
inoremap ` ``<LEFT>

" {} and ()completion when press enter in the middle of them
function! InsertCRBrace()
    call feedkeys("\<BS>",'n')
    let l:frontChar = getline('.')[col('.') - 2]
    if l:frontChar == "{" || l:frontChar == "("
        call feedkeys("\<CR>\<C-c>\O", 'n')
    else
        call feedkeys("\<CR>", 'n')
    endif
endfunction
inoremap <expr> <CR> InsertCRBrace()


" map ;; to esc -----------------------------------------------------------------------------------
function! ESC_IMAP()
    " If the char in front the cursor is ";"
    if getline('.')[col('.') - 2]== ";" 
        call feedkeys("\<BS>\<BS>\<C-c>", 'n')
    else
        call feedkeys("\<BS>\;", 'n')
    endif
endfunction
inoremap <expr> ; ESC_IMAP()

vnoremap ;; <C-c>
snoremap ;; <C-c>
xnoremap ;; <C-c>
cnoremap ;; <C-c>
onoremap ;; <C-c>

" exit windows
tnoremap ;; <C-\><C-n>

if has('nvim')
    " internal terminal settings
    augroup internal_terminal
        autocmd!
        autocmd TermOpen * setlocal nonumber norelativenumber
    augroup END
else
    augroup internal_terminal
        autocmd!
        autocmd TerminalOpen * setlocal nonumber norelativenumber
    augroup END
endif
" switch windows -----------------------------------------------------------------------------------
nnoremap <silent><TAB> <cmd>wincmd w<CR>


" Search only in displayed scope -------------------------------------------------------------------
function! QuickMovement()
    let l:top = line('w0')
    let l:bottom = line('w$')
    let l:toLefts=""
    for i in range(1,strlen("/ | :call LimitSearchScope()"))
        let l:toLefts = l:toLefts."\<LEFT>"
    endfor
    call feedkeys(":silent! ".l:top.",".l:bottom."g// | :call LimitSearchScope()".l:toLefts)
endfunction

function! LimitSearchScope()
    let l:top = line('w0') - 1
    let l:bottom = line('w$') + 1
    call feedkeys("H^")
    call feedkeys("/\\%>".l:top."l".@/."\\%<".l:bottom."l\<CR>")
endfunction

nnoremap <silent> s :call QuickMovement()<CR>


" highlight settings -------------------------------------------------------------------------------
hi FocusCurMatch ctermfg=white ctermbg=red cterm=bold
function! StressCurMatch()
    let l:target = '\c\%#'.@/
    call matchadd('FocusCurMatch', l:target)
endfunction

" centre the screen on the current search result
nnoremap <silent> n n:call StressCurMatch()<CR>
nnoremap <silent> N N:call StressCurMatch()<CR>
nnoremap <silent><expr> <SPACE><SPACE> @/=='' ?
    \ ':let @/=@s<CR>' :
    \ ':let @/=""<CR>
        \:call clearmatches()<CR>'
cnoremap <silent><expr> <CR> getcmdtype() =~ '[/?]' ?
    \ '<CR>:let @s=@/<CR>
        \:call StressCurMatch()<CR>' :
    \ '<CR>'
" cnoremap <silent><expr> <CR> getcmdtype() =~ '[/?]' ? '<CR>:call StressCurMatch()<CR>' : '<CR>'


" wild* settings -----------------------------------------------------------------------------------
set wildmenu
set wildoptions=pum
set wildcharm=<TAB>
if has('nvim')
    cnoremap <expr> <up> wildmenumode() ? "\<left>" : "\<up>"
    cnoremap <expr> <down> wildmenumode() ? "\<right>" : "\<down>"
    cnoremap <expr> <left> wildmenumode() ? "\<SPACE>\<BS>" : "\<left>"
    cnoremap <expr> <right> wildmenumode() ? "\<SPACE>\<BS>" : "\<right>"
endif


" quick action to move the cursor to the begin or end of the line
nnoremap <expr>0 col('.') == 1 ? '$' : '0'
vnoremap <expr>0 col('.') == 1 ? '$' : '0'

" move code block up or down
nnoremap <silent><M-down> <cmd>m .+1<CR>==
nnoremap <silent><M-up> <cmd>m .-2<CR>==
vnoremap <silent><M-down> :m '>+1<CR>gv=gv
vnoremap <silent><M-up> :m '<-2<CR>gv=gv

" %s/\s\+$//e
function! RmTrailingSpace()
    %s/\s\+$//e
endfunction

command! RmTrailingSpace call RmTrailingSpace()

nnoremap <silent><S-TAB> <cmd>tabnext<CR>

" spetial chars
set fillchars+=eob:\ 
set fillchars+=vert:\│

set list
set listchars=tab:┊\ ,eol:\ 
set listchars+=trail:\ 
set listchars+=leadmultispace:┊\ \ \ 
