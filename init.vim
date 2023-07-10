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


" highlight settings -------------------------------------------------------------------------------
function! StressCurMatch()
    let l:target = '\c\%#'.@/
    call matchadd('FocusCurMatch', l:target)
endfunction

" centre the screen on the current search result
nnoremap <silent> n n:call StressCurMatch()<CR>
nnoremap <silent> N N:call StressCurMatch()<CR>
cnoremap <silent><expr> <CR> getcmdtype() =~ '[/?]' ? '<CR>:call StressCurMatch()<CR>' : '<CR>'

hi FocusCurMatch ctermfg=white ctermbg=red cterm=bold

function! ToggleHlsearch()
    if &hlsearch
        set nohlsearch
        hi clear FocusCurMatch
    else
        set hlsearch
        hi FocusCurMatch ctermfg=white ctermbg=red cterm=bold
    end
endfunction

" highlight search
nnoremap <silent><space><space> <cmd>call ToggleHlsearch()<CR>


" netrw settings -----------------------------------------------------------------------------------
" not show the help banner on top 
let g:netrw_banner = 0

" make explorer show files like a tree
let g:netrw_liststyle = 3

" see help doc to know more about this global var
let g:netrw_browse_split = 4

" explorer vertical split max win width
let g:max_explore_win_width=25

" skip the netrw win when the netrw hidden
function! SkipNetrwWin()
    augroup skipNetrwWin
        autocmd!
        autocmd BufEnter NetrwTreeListing wincmd w
    augroup END
endfunction

" open explorer by specific size
function! OpenExplorerOnSize(size)
    let t:win_width=a:size
    exec "botright "t:win_width."vsplit"
    exec "Explore"
    setlocal winfixwidth
endfunction

function! ToggleExplorer()
    let l:expl_win_num = bufwinnr(bufnr('NetrwTreeListing'))
    " handling the case where explorer takes up the entire window
    let l:enewFlag = 0
    if l:expl_win_num == 1
        enew
        let l:expl_win_num = -1
        let l:enewFlag = 1
    endif
    " if expl_win_num exists
    if l:expl_win_num != -1
        " if cursor is not in explorer
        if l:expl_win_num != winnr()
            let t:cur_work_win_num = winnr()
        endif
        " if explorer is not hidden
        if winwidth(l:expl_win_num)!=0
            let t:win_width=0
            exec t:cur_work_win_num."wincmd w"
            call SkipNetrwWin()
        else
            let t:win_width=g:max_explore_win_width
            " disable skip netrw win
            autocmd! skipNetrwWin
            exec l:expl_win_num."wincmd w"
        endif
        exec "vertical ".l:expl_win_num."resize ".t:win_width
    else
        call OpenExplorerOnSize(g:max_explore_win_width)
        if l:enewFlag == 1
            wincmd w
        endif
    endif
endfunction

nnoremap <silent><SPACE>e <cmd>call ToggleExplorer()<CR>

function! ExploreWhenEnter()
    let l:expl_win_num = bufwinnr(bufnr('NetrwTreeListing'))
    " if expl_win_num not exists
    if l:expl_win_num == -1
        if exists('#skipNetrwWin#BufEnter')
            autocmd! skipNetrwWin
        endif
        " record the win num of workspace except explorer where cursor in
        let t:cur_work_win_num = winnr()
        call OpenExplorerOnSize(g:max_explore_win_width)
        let l:explore_win_num = winnr()
        wincmd w
        " hide the explorer
        exec "vertical ".l:expl_win_num."resize 0"
        call SkipNetrwWin()
    else
        if winwidth(l:expl_win_num)!=0
            if exists('#skipNetrwWin#BufEnter')
                autocmd! skipNetrwWin
            endif
        else
            call SkipNetrwWin()
        endif
    endif
endfunction

augroup initExplore
    autocmd!
    autocmd TabEnter,VimEnter * call ExploreWhenEnter()
augroup END


" colorscheme settings ------------------------------------------------------------------------------
hi Normal ctermfg=white ctermbg=NONE cterm=NONE
hi Error ctermfg=darkyellow ctermbg=NONE cterm=NONE
hi Folded ctermfg=yellow ctermbg=darkgray cterm=NONE
hi LineNr ctermfg=darkgray ctermbg=NONE cterm=NONE
hi Comment ctermfg=darkgray ctermbg=NONE cterm=italic
hi Visual ctermfg=lightred ctermbg=darkgray cterm=NONE
hi VertSplit ctermfg=darkgray ctermbg=NONE cterm=NONE
hi CursorLine ctermfg=black ctermbg=lightgray cterm=NONE
hi CursorLineNr ctermfg=darkyellow ctermbg=NONE cterm=NONE
hi PmenuSel ctermfg=black ctermbg=lightred cterm=NONE
hi Pmenu ctermfg=black ctermbg=gray cterm=NONE
hi Identifier ctermfg=lightgray ctermbg=NONE cterm=bold
set fillchars+=eob:\ 


" bottem statusline settings -----------------------------------------------------------------------
set statusline=%*\ %.50F\ %m\               " show filename and filepath
set statusline+=%=%l/%L:%c\ \ %*            " show the column and raw num where cursor in
set statusline+=%3p%%\ \                    " show proportion of the text in front of the cursor to the total text
set statusline+=%{&ff}\[%{&fenc}]\ %*       " show encoding type of file
set statusline+=\ %{strftime('%H:%M')}\ \   " show current time
set statusline+=[%{winnr()}]                " show winNum of current
hi Statusline ctermfg=lightyellow ctermbg=darkgray cterm=bold
hi StatuslineNC ctermfg=lightmagenta ctermbg=darkgray cterm=bold


set list
set listchars=tab:┊\ ,eol:\ 
set listchars+=trail:\ 
set listchars+=leadmultispace:┊\ \ \ 


" tabline settings ---------------------------------------------------------------------------------
" tabline contents 
function! Tabline()
    let l:s = ''
    for i in range(tabpagenr('$'))
        let l:tab = i + 1
        let l:winnr = tabpagewinnr(l:tab)
        let l:buflist = tabpagebuflist(l:tab)
        let l:bufnr = l:buflist[l:winnr - 1]
        let l:bufname = bufname(l:bufnr)
        let l:bufmodified = getbufvar(l:bufnr, "&mod")
        " tabpage title settings
        let l:s .= '%' . l:tab . 'T'
        let l:s .= (l:tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
        let l:s .= ' ' . l:tab .' '
        let l:s .= (l:bufname != '' ? '['. fnamemodify(l:bufname, ':t') . '] ' : '[No Name] ')
        " modified flag
        if l:bufmodified
            let l:s .= '[+] '
        endif
    endfor
    " remove the close button
    let l:s .= '%#TabLineFill#'
    if (exists("g:tablineclosebutton"))
        let l:s .= '%=%999XX'
    endif
    return l:s
endfunction
set tabline=%!Tabline()

" tabline colorscheme
hi TabLine ctermfg=lightmagenta ctermbg=darkgray cterm=bold
hi TabLineFill ctermfg=NONE ctermbg=darkgray cterm=bold
hi TabLineSel ctermfg=lightyellow ctermbg=darkgray cterm=bold

nnoremap <silent><S-TAB> <cmd>tabnext<CR>


" set ripgrep root dir
let g:rootDir=getcwd()

function! ChangeDir(path)
    if isdirectory(expand(a:path))
        if a:path=="."
            let g:rootDir=expand("%:p:h")
            exec "cd ".g:rootDir
        else
            let g:rootDir=a:path
            exec "cd ".g:rootDir
        endif
        echo getcwd()
    else
        echo ">> Error Path!"
    endif
endfunction

command! -nargs=1 -complete=command C call ChangeDir(<f-args>)

let t:redirPreviewWinnr = 1

function! OpenRedirWindow()
    let l:findWinNum=bufwinnr(bufnr('^FuzzyFilenameSearch'.tabpagenr()))
    let l:rgWinNum=bufwinnr(bufnr('^RipgrepWordSearch'.tabpagenr()))
    let l:bufferListWinNum=bufwinnr(bufnr('^BufferList'.tabpagenr()))
    if l:findWinNum != -1
        exec l:findWinNum."wincmd w"
        enew
    elseif l:rgWinNum != -1
        exec l:rgWinNum."wincmd w"
        enew
    elseif l:bufferListWinNum !=-1
        exec l:bufferListWinNum."wincmd w"
        enew
    else
        let t:redirPreviewWinnr = winnr()
        botright 10new
    endif
endfunction

function! QuitRedirWindow()
    let l:findWinNum=bufwinnr(bufnr('^FuzzyFilenameSearch'.tabpagenr()))
    let l:rgWinNum=bufwinnr(bufnr('^RipgrepWordSearch'.tabpagenr()))
    let l:bufferListWinNum=bufwinnr(bufnr('^BufferList'.tabpagenr()))
    if l:findWinNum != -1
        exec l:findWinNum."close"
    elseif l:rgWinNum != -1
        exec l:rgWinNum."close"
    elseif l:bufferListWinNum !=-1
        exec l:bufferListWinNum."close"
    else
        echo ">> No OpenRedirWindow!"
    endif
endfunction

nnoremap <silent><space>q <cmd>call QuitRedirWindow()<CR>

" Fuzzy Match filenames -----------------------------------------------------------------------------
" Go to the file on line
function! FindJump(path)
    exec "cd ".g:rootDir
    let l:path=a:path
    exec t:redirPreviewWinnr."wincmd w"
    if filereadable(expand(l:path))
        exec "edit ".l:path
    else
        echo ">> File Not Exist!"
    endif
endfunction

" autocmd to jump to file with CR only in FuzzyFilenameSearch buffer
function! FindJumpMap()
    augroup findJumpMap
        autocmd!
        autocmd FileType FuzzyFilenameSearch nnoremap <buffer><silent><CR> <cmd>call FindJump(getline('.'))<CR>
    augroup END
    nnoremap <silent><S-down> <cmd>call FindNext()<CR>
    nnoremap <silent><S-up> <cmd>call FindPre()<CR>
endfunction

" redirect the command output to a buffer
function! FindRedir(cmd)
    call FindJumpMap()
    call OpenRedirWindow()
    exec "edit FuzzyFilenameSearch".tabpagenr()."\ ->\ ".t:findSubStr
    exec "read ".a:cmd
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=FuzzyFilenameSearch
endfunction

command! -nargs=1 -complete=command FindRedir silent! call FindRedir(<q-args>)

" Show Files fuzzily searched with git
function! FindWithGit(substr)
    let t:findSubStr=a:substr
    exec "FindRedir !rg --files \| rg --ignore-case ".a:substr
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" Show Files searched fuzzily without git
function! FindWithoutGit(substr)
    let t:findSubStr=a:substr
    exec "FindRedir !rg --no-ignore --files \| rg --ignore-case ".a:substr
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" Fg means 'file git', search file names fuzzily with git
command! -nargs=1 -complete=command Fg silent! call FindWithGit(<q-args>)

" Fs means 'file search', search file names fuzzily
command! -nargs=1 -complete=command Fs silent! call FindWithoutGit(<q-args>)

" To show file preview, underlying of FindNext, imitate 'cNext' command
function! FindShow(direction)
    let l:findWinNum=bufwinnr(bufnr('^FuzzyFilenameSearch'.tabpagenr()))
    if l:findWinNum == -1
        echo ">> No FuzzyFilenameSearch Buffer!"
    else
        if l:findWinNum != t:redirPreviewWinnr
            let l:findWinId=win_getid(l:findWinNum)
            call win_execute(l:findWinId, "normal! ".a:direction)
            call win_execute(l:findWinId, "let t:findPreviewPath=getline('.')")
            call FindJump(t:findPreviewPath)
        else
            call FindJump(getline('.'))
        endif
    endif
endfunction

" imitate 'cNext'
function! FindNext()
    call FindShow("+")
endfunction

" imitate 'cprevious'
function! FindPre()
    call FindShow("-")
endfunction


" Global Fuzzy Match words -------------------------------------------------------------------------
" Go to the file on line
function! RgJump(location)
    exec "cd ".g:rootDir
    let l:location = split(a:location, ":")
    exec t:redirPreviewWinnr."wincmd w"
    try
        exec "edit ".l:location[0]
        cal cursor(l:location[1], l:location[2])
        call matchadd('FocusCurMatch', '\c\%#'.@/)
    catch
        echo ">> File Not Exist!"
    endtry
endfunction

" autocmd to jump to file with CR only in RipgrepWordSearch buffer
function! RgJumpMap()
    augroup rgJumpMap
        autocmd!
        autocmd FileType RipgrepWordSearch nnoremap <buffer><silent><CR> <cmd>call RgJump(getline('.'))<CR>
    augroup END
    nnoremap <silent><S-down> <cmd>call RgNext()<CR>
    nnoremap <silent><S-up> <cmd>call RgPre()<CR>
endfunction

" redirect the command output to a buffer
function! RgRedir(cmd)
    call RgJumpMap()
    call OpenRedirWindow()
    exec "edit RipgrepWordSearch".tabpagenr()."\ ->\ ".t:rgrepSubStr
    exec "read "a:cmd
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=RipgrepWordSearch
endfunction

command! -nargs=1 -complete=command RgRedir silent! call RgRedir(<q-args>)

" Show Words fuzzily searched with git
function! RgWithGit(substr)
    let t:rgrepSubStr=a:substr
    exec "RgRedir !rg '".a:substr."' ".getcwd()." --ignore-case --vimgrep --no-heading"
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" Show Files fuzzily searched without git
function! RgWithoutGit(substr)
    let t:rgrepSubStr=a:substr
    exec "RgRedir !rg '".a:substr."' ".getcwd()." --ignore-case --vimgrep --no-heading --no-ignore"
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" Wg means 'word git', search file fuzzily names with git
command! -nargs=1 -complete=command Wg silent! call RgWithGit(<q-args>)

" Ws means 'word search', search file fuzzily names without git
command! -nargs=1 -complete=command Ws silent! call RgWithoutGit(<q-args>)

" To show file preview, underlying of RgNext, imitate 'cNext' command
function! RgShow(direction)
    let l:rgWinNum=bufwinnr(bufnr('^RipgrepWordSearch'.tabpagenr()))
    if l:rgWinNum == -1
        echo ">> No RipgrepWordSearch Buffer!"
    else
        if l:rgWinNum != t:redirPreviewWinnr
            let l:rgWinId=win_getid(l:rgWinNum)
            call win_execute(l:rgWinId, "normal! ".a:direction)
            call win_execute(l:rgWinId, "let t:rgPreviewLocation=getline('.')")
            call RgJump(t:rgPreviewLocation)
        else
            call RgJump(getline('.'))
        endif
    endif
endfunction

" imitate 'cNext'
function! RgNext()
    call RgShow("+")
endfunction

" imitate 'cprevious'
function! RgPre()
    call RgShow("-")
endfunction


" Go to the buffer on line
function! BufferListJump(bufInfo)
    exec "cd ".g:rootDir
    let l:bufNum=split(a:bufInfo,"\ ")[0]
    exec t:redirPreviewWinnr."wincmd w"
    try
        exec "buffer".l:bufNum
    catch
        echo ">> Buffer Not Exist!"
    endtry
endfunction

" autocmd to jump to buffer with CR only in BufferList buffer
function! BufferListJumpMap()
    augroup BufferListJumpMap
        autocmd!
        autocmd FileType BufferList nnoremap <buffer><silent><CR> <cmd>call BufferListJump(getline('.'))<CR>
    augroup END
    nnoremap <silent><S-down> <cmd>call BufferListNext()<CR>
    nnoremap <silent><S-up> <cmd>call BufferListPre()<CR>
endfunction

" redirect the command output to a buffer
function! BufferListRedir()
    call BufferListJumpMap()
    call OpenRedirWindow()
    exec "edit BufferList".tabpagenr()
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=BufferList
    put = execute('buffers')
    exec "normal! gg"
    let l:empty=2
    while empty > 0
        if getline('.') == ""
            exec "normal! dd"
        endif
        let l:empty-=1
    endwhile
endfunction

nnoremap <silent><space>l <cmd>call BufferListRedir()<CR>

" To show the buffer selected, underlying of BufferListNext, imitate 'cNext' command
function! BufferListShow(direction)
    let l:bufferListWinNum=bufwinnr(bufnr('^BufferList'.tabpagenr()))
    if l:bufferListWinNum==-1
        echo ">> No BufferList Buffer!"
    else
        if l:bufferListWinNum != t:redirPreviewWinnr
            let l:bufferListWinId=win_getid(l:bufferListWinNum)
            call win_execute(l:bufferListWinId, "normal! ".a:direction)
            call win_execute(l:bufferListWinId, "let t:bufferListPreviewInfo=getline('.')")
            call BufferListJump(t:bufferListPreviewInfo)
        else
            call BufferListJump(getline('.'))
        endif
    endif
endfunction

" imitate 'cNext'
function! BufferListNext()
    call BufferListShow("+")
endfunction

" imitate 'cprevious'
function! BufferListPre()
    call BufferListShow("-")
endfunction


function! HasFolds()
    let l:numLines = line('$')
    for l:lineNum in range(1, l:numLines)
        if foldclosed(l:lineNum) != -1
            return 1
        endif
    endfor
    return 0
endfunction

function! SearchFoldEpxr()
    if getline(v:lnum) =~ @/
        return 0
    elseif getline(v:lnum-1) =~ @/ || getline(v:lnum+1) =~ @/
        return 1
    else
        return 2
    endif
endfunction

" Folding according to search result
function! ToggleSearchFolding()
    if HasFolds()
        setlocal foldmethod=syntax foldcolumn=0
        exec "normal! zR"
    else
        setlocal foldexpr=SearchFoldEpxr() foldmethod=expr foldlevel=0 foldcolumn=2
        exec "normal! zM"
    endif
endfunction

nnoremap <silent><SPACE>z <cmd>call ToggleSearchFolding()<CR>


" quick action to move the cursor to the begin or end of the line
nnoremap <expr>0 col('.') == 1 ? '$' : '0'
vnoremap <expr>0 col('.') == 1 ? '$' : '0'

" move code block up or down
nnoremap <silent><M-down> <cmd>m .+1<CR>==
nnoremap <silent><M-up> <cmd>m .-2<CR>==
vnoremap <silent><M-down> :m '>+1<CR>gv=gv
vnoremap <silent><M-up> :m '<-2<CR>gv=gv

"" %s/\s\+$//e
function! RmTrailingSpace()
    exec "%s/\s\+$//e"
endfunction

command! RmTrailingSpace call RmTrailingSpace()


" vim-plug(4) ---------------------------------------------------------------------------------------
call plug#begin($HOME.'/.local/share/nvim/site/autoload')
Plug 'tpope/vim-fugitive'
call plug#end()


augroup MarkdownPreview
    autocmd!
    auto Filetype markdown source $HOME/.config/nvim/markdown.vim
augroup END


set completeopt=menuone,noselect
" hide commplete info under the statusline
set shortmess+=c

" use tab for navigating the autocomplete menu
inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

" use up and down keys for navigating the autocomplete menu
inoremap <expr> <down> pumvisible() ? "\<C-n>" : "\<down>"
inoremap <expr> <up> pumvisible() ? "\<C-p>" : "\<up>"

function! OpenLSPCompletion()
    if v:char =~ '[A-Za-z_.]' && !pumvisible() 
        call feedkeys("\<C-x>\<C-o>", "n")
    endif
endfunction

function! OpenNoLSPCompletion()
    if v:char =~ '[A-Za-z_]' && !pumvisible() 
        call feedkeys("\<C-n>", "n")
    endif
endfunction

function! AutoComplete()
    if &filetype =~# 'python\|lua\|cpp\|c\|java'
        if exists('#openNoLSPCompletion#InsertCharPre')
            autocmd! openNoLSPCompletion
        endif
        augroup openLSPCompletion
            autocmd!
            autocmd InsertCharPre * silent! call OpenLSPCompletion()
        augroup END
    else
        if exists('#openLSPCompletion#InsertCharPre')
            autocmd! openLSPCompletion
        endif
        augroup openNoLSPCompletion
            autocmd!
            autocmd InsertCharPre * silent! call OpenNoLSPCompletion()
        augroup END
    endif
endfunction

augroup initAutoComplete
    autocmd!
    autocmd BufWinEnter * call AutoComplete()
augroup END


source $HOME/.config/nvim/lua/lsp.lua
source $HOME/.config/nvim/format.vim


