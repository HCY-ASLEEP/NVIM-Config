" hovel settings -----------------------------------------------------------------------------------
" share system clipboard
set clipboard+=unnamedplus

" show line number
set number

" case insensitive
set ignorecase

" only support command mode, no click
set mouse=c

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

" jump to the last position when reopening a file
" ! You must mkdir viewdir first !
set viewdir=~/.vimviews/
augroup keepBufView
    autocmd!
    autocmd BufWinLeave * silent! mkview
    autocmd BufWinEnter * silent! loadview 
augroup END

" visual block short-cut
nnoremap vv <C-v>

" paste in command mod
cnoremap <C-v> <C-r>"

" show current buffer path
cnoreabbrev fd echo expand("%:p:h")

cnoreabbrev vt vs \| term
cnoreabbrev st sp \| term


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

" internal terminal settings
augroup internal_terminal
    autocmd!
    autocmd TermOpen * set nonumber norelativenumber
augroup END

" switch windows -----------------------------------------------------------------------------------
nnoremap <silent><TAB> <cmd>wincmd w<CR>


" wild* settings -----------------------------------------------------------------------------------
set wildcharm=<TAB>
cnoremap <expr> <up> wildmenumode() ? "\<left>" : "\<up>"
cnoremap <expr> <down> wildmenumode() ? "\<right>" : "\<down>"
cnoremap <expr> <left> wildmenumode() ? "\<SPACE>\<BS>" : "\<left>"
cnoremap <expr> <right> wildmenumode() ? "\<SPACE>\<BS>" : "\<right>"


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
    exec "%s/\s\+$//e"
endfunction

command! RmTrailingSpace call RmTrailingSpace()

nnoremap <silent><S-TAB> <cmd>tabnext<CR>