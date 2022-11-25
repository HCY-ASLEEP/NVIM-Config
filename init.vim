" -------------------------------------------------------------------------------------------------------------
" ---------------------------------------------common-start----------------------------------------------------
" -------------------------------------------------------------------------------------------------------------

set number
set mouse=c

" Tab settings
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

set autoindent
set hlsearch
set clipboard+=unnamedplus
set foldmethod=syntax
set nofoldenable

" auto sync 
set autoread

" split line
set fillchars=eob:\ 

" set double key separation time
set timeoutlen=200

" Vim jump to the last position when reopening a file
" ! You must mkdir viewdir first !
set viewdir=~/.vimviews/
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent! loadview 

" auto pair
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
        call feedkeys("\<CR>\<ESC>\O", 'n')
    else
        call feedkeys("\<CR>", 'n')
    endif
endfunction
inoremap <expr> <ENTER> InsertCRBrace()

" map ;; to esc
function! ESC_IMAP()
    " If the char in front the cursor is ";"
    if getline('.')[col('.') - 2]== ";" 
        call feedkeys("\<BS>\<BS>\<ESC>", 'n')
    else
        call feedkeys("\<BS>\;", 'n')
    endif
endfunction
inoremap <expr> ; ESC_IMAP()

nnoremap ;; <ESC>
vnoremap ;; <ESC>
snoremap ;; <ESC>
xnoremap ;; <ESC>
cnoremap ;; <ESC>
onoremap ;; <ESC>

" exit windows
tnoremap ;; <C-\><C-n>

" switch windows
nnoremap <TAB> <C-w>w
function! SwitchWin(winNum)
    exec a:winNum."wincmd w"
endfunction
nnoremap t :call<SPACE>SwitchWin()<LEFT>

" visual block short-cut
nnoremap vv <C-v>

" paste in command mod
cnoremap <C-v> <C-r>"

" show current buffer path
echo expand("%:p:h")

cnoreabbrev fd echo expand("%:p:h")
cnoreabbrev vt vs<ENTER>:term
cnoreabbrev st sp<ENTER>:term

"buffer vertical split
cnoreabbrev vb vertical<SPACE>sb

" lines above are specific settings for colorscheme koehler
colorscheme koehler
hi ModeMsg ctermfg=darkyellow ctermbg=NONE cterm=NONE
hi Error ctermfg=darkyellow ctermbg=NONE cterm=NONE
hi LineNr ctermfg=darkgray ctermbg=NONE cterm=NONE
hi Search ctermbg=darkgray 

" common settings for colorscheme
hi VertSplit ctermfg=NONE ctermbg=NONE cterm=NONE
hi Statusline ctermfg=NONE ctermbg=NONE cterm=bold 
hi StatuslineNC ctermfg=NONE ctermbg=NONE cterm=NONE

" let fillchars become space
set fillchars=vert:\ 

" bottem statusline settings
set statusline=%*\ %.50F\               " show filename and filepath
set statusline+=%=%l/%L:%c\ %*          " show the column and raw num where cursor in
set statusline+=%3p%%\ \                " show proportion of the text in front of the cursor to the total text
set statusline+=%y%m%r%h%w\ \ %*        " show filetype and filestatus
set statusline+=%{&ff}\[%{&fenc}]\ %*   " show encoding type of file
set statusline+=\ %{strftime('%H:%M')}  " show current time
set statusline+=\ \ [%{winnr()}]        " show winNum of current


" 设置 netrw
" not show the help banner on top 
let g:netrw_banner = 0
" make explorer show files like a tree
let g:netrw_liststyle = 3
" see help doc to know more about this global var
let g:netrw_browse_split = 4

" explorer vertical split max win width
let t:max_win_width=25
" record the win num of workspace except explorer where cursor in
let t:cur_work_win_num = winnr()

" open explorer by specific size
function! OpenExplorerOnSize(size)
    let t:win_width=a:size
    set splitright
    exec t:win_width."vsplit"
    set nosplitright
    Explore
    let t:expl_buf_num = bufnr("%")
endfunction

function! ToggleExplorer()
    if exists("t:expl_buf_num")
        let l:expl_win_num = bufwinnr(t:expl_buf_num)
        " if expl_win_num exists
        if l:expl_win_num != -1
            " if cursor is not in explorer
            if l:expl_win_num != winnr()
               let t:cur_work_win_num = winnr() 
            endif
            " if explorer is hidden
            if t:win_width!=0
                let t:win_width=0
                exec t:cur_work_win_num."wincmd w"
            else
                let t:win_width=t:max_win_width
                exec l:expl_win_num."wincmd w"
            endif
            exec "vertical ".l:expl_win_num."resize ".t:win_width
        else 
            call OpenExplorerOnSize(t:max_win_width)            
        endif
    else
        call OpenExplorerOnSize(t:max_win_width)
    endif
endfunction

nnoremap <silent>ee :call ToggleExplorer()<CR>

function! ExploreVimEnter()
    call OpenExplorerOnSize(t:max_win_width)
    wincmd w
endfunction

autocmd VimEnter * call ExploreVimEnter()

"-------------------------------------------------------------------------------------------------------------
"-----------------------------------------------common-end----------------------------------------------------
"-------------------------------------------------------------------------------------------------------------




"-------------------------------------------------------------------------------------------------------------
"--------------------------------------------vim-plug-start---------------------------------------------------
"-------------------------------------------------------------------------------------------------------------

call plug#begin('/home/asleep/.local/share/nvim/site/autoload')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-fugitive'
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
" load markdown plugin according filetype
Plug 'iamcco/markdown-preview.nvim', { 'for': ['markdown'], 'do': 'cd app && yarn install' }
call plug#end()

let g:Lf_WindowPosition = 'popup'
let g:Lf_ShowDevIcons = 0
cnoreabbrev ls LeaderfBuffer
cnoreabbrev fp LeaderfFile
cnoreabbrev ft LeaderfBufTag
cnoreabbrev ff LeaderfFunction

"-------------------------------------------------------------------------------------------------------------
"-----------------------------------------------vim-plug-end--------------------------------------------------
"-------------------------------------------------------------------------------------------------------------



"-------------------------------------------------------------------------------------------------------------
"------------------------------------------------coc-start----------------------------------------------------
"-------------------------------------------------------------------------------------------------------------

inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#next(1) :"\<Tab>" 

nnoremap gd <Plug>(coc-definition)
nnoremap gt <Plug>(coc-type-definition)
nnoremap gi <Plug>(coc-implementation)
nnoremap gr <Plug>(coc-references)

" Use K to show documentation in preview window.
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction
nnoremap <silent> K :call ShowDocumentation()<CR>

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nnoremap <space>r <Plug>(coc-rename)

" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>

" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>

" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>

" It is neccessory to claim this command when use colorscheme koehler
" Pum menu selected bg
hi CocMenuSel ctermbg=237 guibg=#13354A

"-------------------------------------------------------------------------------------------------------------
"-------------------------------------------------coc-end-----------------------------------------------------
"-------------------------------------------------------------------------------------------------------------


" This is my markdown settings
auto Filetype markdown source /home/asleep/.config/nvim/markdown.vim
