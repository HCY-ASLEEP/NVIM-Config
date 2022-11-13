" -------------------------------------------------------------------------------------------------------------
" ---------------------------------------------common-start----------------------------------------------------
" -------------------------------------------------------------------------------------------------------------

set number
set mouse=c

"" Tab settings
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

set autoindent
set hlsearch
set clipboard+=unnamedplus
set foldmethod=syntax
set nofoldenable

" 自动同步
set autoread

"" split line
set fillchars=eob:\ 

"" set double key separation time
set timeoutlen=200

" Vim jump to the last position when reopening a file
" ! You must mkdir viewdir first !
set viewdir=~/.vimviews/
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent! loadview 

"" auto pair
inoremap { {}<LEFT>
inoremap ( ()<LEFT>
inoremap [ []<LEFT>
inoremap ' ''<LEFT>
inoremap " ""<LEFT>

" {} and ()completion when press enter in the middle of them
function! InsertBrace()
    call feedkeys("\<BS>",'n')
    let l:frontChar = getline('.')[col('.') - 2]
    if l:frontChar == "{" || l:frontChar == "("
        call feedkeys("\<CR>\<ESC>\O", 'n')
    else
        call feedkeys("\<CR>", 'n')
    endif
endfunction
inoremap <expr> <ENTER> InsertBrace()

"" map ;; to esc
function! ESC_IMAP()
    "" If the char in front the cursor is ";"
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
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

"" visual block short-cut
nnoremap vv <C-v>

"" paste in command mod
cnoremap <C-v> <C-r>"

"" show current buffer path
echo expand("%:p:h")

cnoreabbrev fd echo expand("%:p:h")
cnoreabbrev vt vs<ENTER>:term
cnoreabbrev st sp<ENTER>:term

""buffer vertical split
cnoreabbrev vb vertical<SPACE>sb

"" redirect the command output to a buffer
function! Redir(cmd)
	redir => output
	execute a:cmd
	redir END
	let output = split(output, "\n")
	enew
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
	call setline(1, output)
    call feedkeys(":set cursorline\<CR>")
endfunction
command! -nargs=1 -complete=command  Redir silent call Redir(<q-args>)

"" set default fuzzy find root folder to "~"
let g:rootdir="~"

" change fuzzy find file root folder to path where the buffer current locates
function! SetRoordir(newPath)
    if a:newPath=="."
        let g:rootdir=expand("%:p:h")
    else
        let g:rootdir=a:newPath
    endif
endfunction
command! -nargs=1 -complete=command  SetRoordir silent call SetRoordir(<q-args>)
cnoreabbrev sr SetRoordir

"" Show Files searched fuzzily
function! FuzzyFileSearch(substr)
    call feedkeys(":Redir !find ".g:rootdir." -path '*".a:substr."*'\<ENTER>" ,'n')
    call feedkeys("/".a:substr."\<ENTER>")
endfunction

nnoremap ff :call<SPACE>FuzzyFileSearch("")<LEFT><LEFT>

"" Go to the file on line
function! JumpToFile()
    let l:path=getline('.')
    if filereadable(l:path)
        echo "SpecificFile exists"
        exec "edit ".l:path
    else
        echo "File loaded error, can not call JumpToFile"
    endif
endfunction
nnoremap <ENTER> :call JumpToFile()<ENTER>:set<SPACE>nocursorline<ENTER>:noh<ENTER>

"" 底部状态栏设置
set statusline=%*\ %.50F\               "显示文件名和文件路径
set statusline+=%=%l/%L:%c\ %*          "显示光标所在行和列
set statusline+=%3p%%\ \                "显示光标前文本所占总文本的比例
set statusline+=%y%m%r%h%w\ \ %*        "显示文件类型及文件状态
set statusline+=%{&ff}\[%{&fenc}]\ %*   "显示文件编码类型
set statusline+=\ %{strftime('%H:%M')}  "显示时间 

"" 设置 netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4

let t:max_win_width=20

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
        let l:cur_win_num = winnr()

        if l:expl_win_num != -1
            while l:expl_win_num != l:cur_win_num
                wincmd w
                let l:cur_win_num = winnr()
            endwhile
            
            if t:win_width!=0
                let t:win_width=0
                exec "vertical resize ".t:win_width
                wincmd w
            else
                let t:win_width=t:max_win_width
                exec "vertical resize ".t:win_width
            endif
        else 
            call OpenExplorerOnSize(t:max_win_width)            
        endif
    else
        call OpenExplorerOnSize(t:max_win_width)
    endif
endfunction

nmap ee :call ToggleExplorer()<CR>

function! ExploreVimEnter()
    call OpenExplorerOnSize(0)
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
Plug 'joshdick/onedark.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-fugitive'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
call plug#end()

let g:onedark_terminal_italics=1
autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE 
colorscheme onedark

auto Filetype markdown cnoreabbrev mt MarkdownPreviewToggle
auto Filetype markdown let g:mkdp_theme = "light"


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


"-------------------------------------------------------------------------------------------------------------
"-------------------------------------------------coc-end-----------------------------------------------------
"-------------------------------------------------------------------------------------------------------------





"-------------------------------------------------------------------------------------------------------------
"-----------------------------------------markdown-dialogue-start---------------------------------------------
"-------------------------------------------------------------------------------------------------------------

function! INSERT_A_PICTURE()
  call feedkeys("\<BS>\<img src\=\"\"\/\>\<LEFT>\<LEFT>\<LEFT>",'n')  
endfunction

function! LEFT_TEXT_DIALOUGE()
  call feedkeys("\<BS>\<ENTER><div align=\"left\"><div style=\"width: 60%; border-style: solid; border-width: 1px; border-radius: 16px; position: relative; padding:30px; text-align:center\"\><span style=\"width: 0px; height: 0px; border-style: solid; border-color: transparent black transparent transparent; border-width: 10px; position: absolute; top: 10px; left: -20px;\"\>\</span><span style=\"width: 0px; height: 0px; border-style: solid; border-color: transparent white transparent transparent; border-width: 10px; position: absolute; top: 10px; left: -19px;\"\>\</span\>\<ENTER>\<ENTER></div></div><br/>\<UP>",'n')
endfunction

function! RIGHT_TEXT_DIALOUGE()
  call feedkeys("\<BS>\<ENTER><div align=\"right\"\>\<div style=\"width: 60%; border-style: solid; border-width: 1px; border-radius: 16px; position: relative; padding:30px; text-align:center\"\>\<span style=\"width: 0px; height: 0px; border-style: solid; border-color: transparent transparent transparent black; border-width: 10px; position: absolute; top: 10px; right: -20px;\"></span><span style=\"width: 0px; height: 0px; border-style: solid; border-color: transparent transparent transparent white; border-width: 10px; position: absolute; top: 10px; right: -19px\"></span>\<ENTER>\<ENTER></div></div><br/>\<UP>",'n')
endfunction

function! LEFT_PICTURE_DIALOUGE()
  call feedkeys("\<BS>\<ENTER><div align=\"left\"><div style=\"width: 80%; border-style: solid; border-width: 1px; border-radius: 16px; position: relative; padding:30px; text-align:center\"><span style=\"width: 0px; height: 0px; border-style: solid; border-color: transparent transparent transparent black; border-width: 10px; position: absolute; top: 10px; right: -20px;\"></span><span style=\"width: 0px; height: 0px; border-style: solid; border-color: transparent transparent transparent white; border-width: 10px; position: absolute; top: 10px; right: -19px\"></span>\<ENTER>\<ENTER></div></div><br/>\<UP>\<img src\=\"\"\/\>\<LEFT>\<LEFT>\<LEFT>",'n')
endfunction

function! RIGHT_PICTURE_DIALOUGE()
  call feedkeys("\<BS>\<ENTER><div align=\"right\"><div style=\"width: 80%; border-style: solid; border-width: 1px; border-radius: 16px; position: relative; padding:30px; text-align:center\"><span style=\"width: 0px; height: 0px; border-style: solid; border-color: transparent transparent transparent black; border-width: 10px; position: absolute; top: 10px; right: -20px;\"></span><span style=\"width: 0px; height: 0px; border-style: solid; border-color: transparent transparent transparent white; border-width: 10px; position: absolute; top: 10px; right: -19px\"></span>\<ENTER>\<ENTER></div></div><br/>\<UP>\<img src\=\"\"\/\>\<LEFT>\<LEFT>\<LEFT>",'n')
endfunction



auto Filetype markdown inoremap <expr> <c-left> LEFT_TEXT_DIALOUGE()
auto Filetype markdown inoremap <expr> <c-right> RIGHT_TEXT_DIALOUGE()
auto Filetype markdown inoremap <expr> <c-up> LEFT_PICTURE_DIALOUGE()
auto Filetype markdown inoremap <expr> <c-down> RIGHT_PICTURE_DIALOUGE()
auto Filetype markdown inoremap <expr> <c-p> INSERT_A_PICTURE()

"-------------------------------------------------------------------------------------------------------------
"-----------------------------------------markdown-dialogue-end-----------------------------------------------
"-------------------------------------------------------------------------------------------------------------








