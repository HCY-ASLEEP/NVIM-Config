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

set timeoutlen=200


" Vim jump to the last position when reopening a file
set viewdir=~/.vimviews/
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent! loadview 


inoremap { {}<LEFT>
inoremap ( ()<LEFT>
inoremap [ []<LEFT>
inoremap ' ''<LEFT>
inoremap " ""<LEFT>

" {} and ()completion
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
    let l:frontChar = getline('.')[col('.') - 2]
    if l:frontChar == ";" 
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

"" visual block short-cut
nnoremap vv <C-v>


"" paste in command mod
cnoremap <C-v> <C-r>"

echo expand("%:p:h")

cnoreabbrev fd echo expand("%:p:h")
cnoreabbrev vst vs<ENTER>:term
cnoreabbrev spt sp<ENTER>:term

""buffer vertical split
cnoreabbrev vb vertical<SPACE>sb


"" Show Files searched fuzzily
function! Redir(cmd)
	redir => output
	execute a:cmd
	redir END
	let output = split(output, "\n")
	enew
	let w:scratch = 1
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
	call setline(1, output)
    call feedkeys(":set cursorline\<CR>")
endfunction
command! -nargs=1 -complete=command  Redir silent call Redir(<q-args>)

nnoremap <Space>f :Redir<SPACE>!find<SPACE>~<SPACE>-name<SPACE>'**'<LEFT><LEFT>


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
nnoremap <ENTER> :call JumpToFile()<ENTER>:set nocursorline<ENTER>


"" 底部状态栏设置
set statusline=%*\ %.50F\               "显示文件名和文件路径
set statusline+=%=%y%m%r%h%w\ \ \ %*        "显示文件类型及文件状态
set statusline+=%{&ff}\[%{&fenc}]\ \ \ %*   "显示文件编码类型
set statusline+=%l/%L,%c\ \ %*            "显示光标所在行和列
set statusline+=%3p%%                   "显示光标前文本所占总文本的比例



"-------------------------------------------------------------------------------------------------------------
"-----------------------------------------------common-end----------------------------------------------------
"-------------------------------------------------------------------------------------------------------------








"""-------------------------------------------------------------------------------------------------------------
""----------------------------------------------netrw_start----------------------------------------------------
""-------------------------------------------------------------------------------------------------------------

let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 20

set autochdir

" Toggle Vexplore with <F2>
function! ToggleVExplorer()
    if exists("t:expl_buf_num")
        let expl_win_num = bufwinnr(t:expl_buf_num)
        let cur_win_num = winnr()

        if expl_win_num != -1
            while expl_win_num != cur_win_num
                exec "wincmd w"
                let cur_win_num = winnr()
            endwhile

            close
        endif

        unlet t:expl_buf_num
    else
         Vexplore
         let t:expl_buf_num = bufnr("%")
    endif
endfunction

map <F2> :call ToggleVExplorer()<CR>



""-------------------------------------------------------------------------------------------------------------
""-----------------------------------------------netrw-end-----------------------------------------------------
""-------------------------------------------------------------------------------------------------------------







"-------------------------------------------------------------------------------------------------------------
"--------------------------------------------vim-plug-start---------------------------------------------------
"-------------------------------------------------------------------------------------------------------------



call plug#begin('/home/asleep/.local/share/nvim/site/autoload')
Plug 'joshdick/onedark.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-fugitive'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
call plug#end()

"有些插件需要安装 nerd fonts！
"nerd fonts 包括了 powerline fonts！
"建议安装 DejaVuSansMonoNerd！

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

function! EMPTY_LINE()
  call feedkeys("\<BS>\<ENTER>######\<SPACE>\<ENTER>\<ENTER>", 'n')
endfunction

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



auto Filetype markdown inoremap <expr> <c-j> LEFT_TEXT_DIALOUGE()
auto Filetype markdown inoremap <expr> <c-k> RIGHT_TEXT_DIALOUGE()
auto Filetype markdown inoremap <expr> <c-h> LEFT_PICTURE_DIALOUGE()
auto Filetype markdown inoremap <expr> <c-l> RIGHT_PICTURE_DIALOUGE()
auto Filetype markdown inoremap <expr> <c-o> EMPTY_LINE()
auto Filetype markdown inoremap <expr> <c-p> INSERT_A_PICTURE()

"-------------------------------------------------------------------------------------------------------------
"-----------------------------------------markdown-dialogue-end-----------------------------------------------
"-------------------------------------------------------------------------------------------------------------

