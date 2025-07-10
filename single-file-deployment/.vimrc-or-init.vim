" +-----------------------------------------------+
" |                                               |
" |                  COLORSCHEME                  |
" |                                               |
" +-----------------------------------------------+


colorscheme retrobox
if !has('nvim')
    syntax on
endif

" +-----------------------------------------------+
" |                                               |
" |         LOAD LANGUAGE SERVER (NEOVIM)         |
" |                                               |
" +-----------------------------------------------+


" let g:config_path=expand("<sfile>:p:h")
" exec "source ".g:config_path."/lsp.lua"


" +-----------------------------------------------+
" |                                               |
" |              BASIC SETS AND MAPS              |
" |                                               |
" +-----------------------------------------------+


let s:SpacePrefixDict={}
nnoremap <Space> :call <SID>SpacePrefix()<CR>

function! s:SpacePrefix()
    echo "Waiting for next key after <Space> ... "
    let l:key = nr2char(getchar())  " 等待输入一个字符
    redraw
    echo "Pressed '<Space>".l:key."'"
    if has_key(s:SpacePrefixDict, l:key)
        exec s:SpacePrefixDict[l:key]
    else
        exec "normal <Space>".l:key
    endif
endfunction

let s:rgPathSeparator = '/'
if !empty($MSYSTEM)
    let &shellcmdflag = '-c'
    set shellxquote=(
    set shellslash
    let s:rgPathSeparator = '//'
endif

" case insensitive
set ignorecase

" only support command mode, no click
set mouse=a

let $LANG = 'en_US'

" let tap become four spaces
set expandtab

" indent
set autoindent
set cindent

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

" show pressed keys in vim normal mode statusline
set showcmd

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


" jump to the last position when reopening a file
augroup resCur
  autocmd!
  autocmd BufReadPost * call setpos(".", getpos("'\""))
augroup END

set jumpoptions=stack

set incsearch
set hlsearch

" show line number
set number
set relativenumber


if has('nvim') && exists('$TMUX')
    " share system clipboard
    set clipboard+=unnamedplus,unnamed
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
endif

" visual block short-cut
nnoremap vv <C-v>

" paste in command mod
cnoremap <C-p> <C-r>"

" show current buffer path
cnoreabbrev bp echo expand("%:p:h")

if has('nvim')
    cnoreabbrev vt vs \| term
    cnoreabbrev st sp \| term
else
    cnoreabbrev vt vert term
    cnoreabbrev st term
endif


" auto pair ---------------------------------------------------------------------------------------
inoremap { {}<Left>
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap ' ''<Left>
inoremap " ""<Left>
inoremap ` ``<Left>

" {} and () completion when press enter in the middle of them
" Part of path autocompletion also included in this function
function! s:InsertCRBrace()
    let l:frontChar = getline('.')[col('.') - 2]
    if l:frontChar == "{" || l:frontChar == "("
        return "\<CR>\<C-c>\O"
    endif
    if l:frontChar =~ '[/]'
        let l:pathCompletionKey = "\<C-x>\<C-f>"
        if pumvisible()
            return l:pathCompletionKey
        endif
        return l:pathCompletionKey."\<CR>"
    endif
    return "\<CR>"
endfunction

inoremap <expr> <CR> <SID>InsertCRBrace()


" map ;; to esc -----------------------------------------------------------------------------------
function! s:ESC_IMAP()
    " If the char in front the cursor is ";"
    if getline('.')[col('.') - 2]== ";"
        return "\<BS>\<C-c>"
    else
        return ";"
    endif
endfunction
inoremap <expr> ; <SID>ESC_IMAP()

vnoremap ;; <C-c>
snoremap ;; <C-c>
xnoremap ;; <C-c>
cnoremap ;; <C-c>
onoremap ;; <C-c>

" exit windows
tnoremap ;; <C-\><C-n>

function! s:ActionBeforeTermianlOpen()
    setlocal nonumber norelativenumber
    tnoremap <silent><buffer><S-Tab> <C-\><C-n>:tabnext<CR>
endfunction

if has('nvim')
    " internal terminal settings
    augroup internal_terminal
        autocmd!
        autocmd TermOpen * call s:ActionBeforeTermianlOpen() | call feedkeys("i")
        autocmd BufEnter * if &buftype == 'terminal' | call feedkeys("i") | endif
    augroup END
else
    augroup internal_terminal
        autocmd!
        autocmd TerminalOpen * call s:ActionBeforeTermianlOpen()
        autocmd BufEnter * if &buftype == 'terminal' | call feedkeys("i") | endif
    augroup END
endif

nnoremap <silent><S-Tab> :tabnext<CR>


" switch windows -----------------------------------------------------------------------------------
let s:SpacePrefixDict['w']='wincmd w'


" Search only in displayed scope -------------------------------------------------------------------
function! s:LimitSearchScope()
    let l:top = line('w0') - 1
    let l:bottom = line('w$') + 1
    call feedkeys("H^")
    call feedkeys("/\\%>".l:top."l".@/."\\%<".l:bottom."l\<CR>")
endfunction

function! s:QuickMovement()
    let l:top = line('w0')
    let l:bottom = line('w$')
    let l:toLefts=""
    let l:suffix="/ | LimitSearchScope"
    let l:toLefts=repeat("\<Left>",strlen(l:suffix))
    call feedkeys(":silent! ".l:top.",".l:bottom."g/".l:suffix.l:toLefts)
endfunction

command! LimitSearchScope call s:LimitSearchScope()
nnoremap <silent> f :call <SID>QuickMovement()<CR>


function! s:SearchList()
    let l:suffix="/g % | copen"
    let l:toLefts=repeat("\<Left>",strlen(l:suffix))
    call feedkeys(":vimgrep /".l:suffix.l:toLefts)
endfunction
nnoremap <silent> s :call <SID>SearchList()<CR>


" highlight settings -------------------------------------------------------------------------------
hi! def link FocusCurMatch DiffText
function! s:StressCurMatch()
    let l:target = '\c\%#'.@/
    call matchadd('FocusCurMatch', l:target)
endfunction

function! s:ToggleHlsearch()
    if @/==''
        let @/=@s 
    else
        let @/=""
        call clearmatches()
    endif
endfunction

" centre the screen on the current search result
nnoremap <silent> n n:call <SID>StressCurMatch()<CR>
nnoremap <silent> N N:call <SID>StressCurMatch()<CR>
let s:SpacePrefixDict[' ']='call s:ToggleHlsearch()'
cnoremap <silent><expr> <CR> getcmdtype() =~ '[/?]' ?
    \ '<CR>:let @s=@/<CR>
        \:call <SID>StressCurMatch()<CR>' :
    \ '<CR>'
" cnoremap <silent><expr> <CR> getcmdtype() =~ '[/?]' ? '<CR>:call StressCurMatch()<CR>' : '<CR>'


" wild* settings -----------------------------------------------------------------------------------
set wildmenu
set wildoptions=pum
set wildcharm=<Tab>
if has('nvim')
    cnoremap <expr> <Up> wildmenumode() ? "\<Left>" : "\<Up>"
    cnoremap <expr> <Down> wildmenumode() ? "\<Right>" : "\<Down>"
    cnoremap <expr> <Left> wildmenumode() ? "\<Space>\<BS>" : "\<Left>"
    cnoremap <expr> <Right> wildmenumode() ? "\<Space>\<BS>" : "\<Right>"
endif


" quick action to move the cursor to the begin or end of the line
nnoremap <expr>0 col('.') == 1 ? '$' : '0'
vnoremap <expr>0 col('.') == 1 ? '$' : '0'

" move code block up or down
nnoremap <silent><S-Down> :m .+1<CR>==
nnoremap <silent><S-Up> :m .-2<CR>==
vnoremap <silent><S-Down> :m '>+1<CR>gv=gv
vnoremap <silent><S-Up> :m '<-2<CR>gv=gv

" %s/\s\+$//e
function! s:RmTrailingSpace()
    %s/\s\+$//e
endfunction

command! RmTrailingSpace call s:RmTrailingSpace()


" spetial chars
set fillchars+=eob:\ 
set fillchars+=vert:\│

set list
function! s:SetListchars(tabLen)
    setglobal listchars=tab:\┊\ ,eol:\ 
    setglobal listchars+=trail:\ 
    setglobal listchars+=precedes:…
    setglobal listchars+=extends:…
    exec "setglobal listchars+=leadmultispace:\┊".repeat("\\ ", a:tabLen-1) 
endfunction

function! s:SetTabLen(n)
    call s:SetListchars(a:n)
    " tab settings
    exec "set tabstop=".a:n
    exec "set shiftwidth=".a:n
    exec "set softtabstop=".a:n
endfunction
command! -nargs=1 Tl call s:SetTabLen(<args>)
Tl 4


" Break line at predefined characters
set linebreak
" Character to show before the lines that have been soft-wrapped
set showbreak=\ \↪\ 

set nowrap


" +-----------------------------------------------+
" |                                               |
" |                AUTO COMPLETION                |
" |                                               |
" +-----------------------------------------------+


set completeopt=menuone,noselect
" hide commplete info under the statusline
set shortmess+=c

" Completion Timeout Handler
function! s:CT(timer)
    if !pumvisible() 
        call feedkeys("\<C-n>", "n") 
    endif
endfunction

function! s:OpenLSPCompletion()
    if v:char =~ '[A-Za-z_.:>]' && !pumvisible()
        if &omnifunc == ''
            call feedkeys("\<C-n>", "n")
            return
        endif
        call feedkeys("\<C-x>\<C-o>", "n")
        call timer_start(500, "s:CT")
    endif
endfunction

function! s:OpenNoLSPCompletion()
    if v:char =~ '[A-Za-z_]' && !pumvisible()
        call feedkeys("\<C-n>", "n")
    endif
endfunction

function! s:OpenFilePathCompletion()
    if v:char =~ '[/]' && !pumvisible()
        call feedkeys("\<C-x>\<C-f>", "n")
    endif
endfunction

function! s:AutoComplete()
    if has('nvim') && luaeval('#vim.lsp.get_clients({bufnr = 0})') != 0
        augroup openCompletion
            autocmd! * <buffer>
            autocmd InsertCharPre <buffer> silent! call s:OpenLSPCompletion()
        augroup END
    else
        augroup openCompletion
            autocmd! * <buffer>
            autocmd InsertCharPre <buffer> silent! call s:OpenNoLSPCompletion()
        augroup END
    endif
endfunction

if has('nvim')
    augroup initAutoComplete
        autocmd!
        autocmd BufEnter,LspAttach * call s:AutoComplete()
    augroup END
else
    augroup initAutoComplete
        autocmd!
        autocmd BufEnter * call s:AutoComplete()
    augroup END
endif

augroup openFilePathCompletion
    autocmd!
    autocmd InsertCharPre * silent! call s:OpenFilePathCompletion()
augroup END

" use tab for navigating the autocomplete menu
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" use up and down keys for navigating the autocomplete menu
inoremap <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <Up> pumvisible() ? "\<C-p>" : "\<Up>"


" +-----------------------------------------------+
" |                                               |
" |                 CODE FORMATER                 |
" |                                               |
" +-----------------------------------------------+


function! s:FormatCodes(formatCmd,formatArgs)
    if !executable(a:formatCmd)
        echo ">>  "a:formatCmd. " formater not found"
        return
    endif
    execute "%!".a:formatCmd." ".a:formatArgs
endfunction

augroup codeFormat
    autocmd!
    autocmd Filetype python command! -buffer Format silent! call s:FormatCodes('autopep8','-')
    ""autocmd Filetype c,cpp,objc,objcpp,cuda,proto command! -buffer Format silent! call FormatCodes('clang-format','-style="{IndentWidth: 4}"')
    autocmd Filetype c,cpp,objc,objcpp,cuda,proto,cs,java command! -buffer Format silent! call s:FormatCodes('astyle','--style=google 2>/dev/null')
    autocmd Filetype lua command! -buffer Format silent! execute s:FormatCodes('stylua','- --indent-type Spaces --indent-width 4')
    autocmd Filetype yaml command! -buffer Format execute s:FormatCodes('yamlfmt','--formatter indent=4')
augroup END


" +-----------------------------------------------+
" |                                               |
" |     REDIRECT CMD OUTPUT AND SELF-QUICKFIX     |
" |                                               |
" +-----------------------------------------------+

function! s:ConvertWindowsToUnix(rootDir)
  return substitute(a:rootDir, '\\', '/', 'g')
endfunction

function! s:RedirCdWithPathString(path)
    if !isdirectory(expand(a:path))
        echo ">> Error Path!"
        return
    endif
    if a:path=="."
        let t:rootDir=s:ConvertWindowsToUnix(expand("%:p:h"))
        exec "tc ".t:rootDir
    else
        let t:rootDir=s:ConvertWindowsToUnix(expand(a:path))
        exec "tc ".t:rootDir
    endif
    echo getcwd()
endfunction

function! s:RedirCdWithTreeFileExplorer()
    if bufname() !=# t:treeBufname
        echo ">> Not in tree file explorer window!"
        return
    endif
    let t:rootDir=s:ConvertWindowsToUnix(expand(s:GetFullPath(line('.'))))
    exec 'tc '.t:rootDir
    echo t:rootDir
endfunction

function! s:RedirCd(path)
    if empty(a:path)
        call s:RedirCdWithTreeFileExplorer()
        return
    endif
    call s:RedirCdWithPathString(a:path)
endfunction

function! s:ShowRootDir()
    echo t:rootDir
endfunction

function! s:OpenRedirWindow()
    if win_id2tabwin(t:redirWinid)[1] != 0
        call win_gotoid(t:redirWinid)
        return
    end
    let t:redirPreviewWinid = win_getid()
    bot 10new
    let t:redirWinid = win_getid()
endfunction

function! s:QuitRedirWindow()
    if win_id2tabwin(t:redirWinid)[1] != 0
        call win_execute(t:redirWinid, 'close')
        return
    end
    echo ">> No OpenRedirWindow!"
endfunction

function! s:JumpWhenPressEnter(locateTargetFunctionName)
    let t:redirLocateTarget=getline('.')
    if win_id2tabwin(t:redirPreviewWinid)[1] == 0
        top sp
        let t:redirPreviewWinid = win_getid()
    else
        call win_gotoid(t:redirPreviewWinid)
    endif
    call function(a:locateTargetFunctionName)()
endfunction

function! s:JumpWhenPressJOrK(direction,locateTargetFunctionName)
    if win_id2tabwin(t:redirWinid)[1] == 0
        return
    endif
    call win_execute(t:redirWinid, "exec 'normal! '.a:direction | call s:JumpWhenPressEnter(a:locateTargetFunctionName)")
endfunction

function! s:MapRedirPreview(locateTargetFunctionName)
    exec "nnoremap <buffer><silent><CR> :call <SID>JumpWhenPressEnter('".a:locateTargetFunctionName."')<CR>"
    exec "nnoremap <silent><C-Down> :call <SID>JumpWhenPressJOrK('+', '".a:locateTargetFunctionName."')<CR>"
    exec "nnoremap <silent><C-Up> :call <SID>JumpWhenPressJOrK('-', '".a:locateTargetFunctionName."')<CR>"   
    call s:UnmapRedirPreview()
endfunction

function! s:UnmapRedirPreview()
    augroup unmapRedirPreview
        autocmd!
        autocmd BufUnload <buffer> unmap <C-Down>
        autocmd BufUnload <buffer> unmap <C-Up>
    augroup END
endfunction

let s:SpacePrefixDict['q']='call s:QuitRedirWindow()'

command! Rpwd call s:ShowRootDir()
command! -nargs=? -complete=dir Rcd call s:RedirCd(<q-args>)

augroup redirWhenTabNew
    autocmd!
    autocmd VimEnter,TabNew * let t:rootDir=s:ConvertWindowsToUnix(getcwd()) | let t:redirWinid=0
augroup END

augroup redirBufWinLeave
    autocmd!
    autocmd BufWinLeave * silent! call clearmatches(t:redirPreviewWinid)
augroup END

augroup redirCursorLine
    autocmd!
    autocmd Filetype redirWindows setlocal cursorlineopt=line
augroup END

hi def link RedirFocusCurMatch DiffChange


" +-----------------------------------------------+
" |                                               |
" |             BUFFER LIST REDIRECT              |
" |                                               |
" +-----------------------------------------------+


" Go to the buffer on line
function! s:BufferListLocateTarget()
    let l:bufNum=split(t:redirLocateTarget,"\ ")[0]
    try
        exec "buffer".l:bufNum
    catch
        echo ">> Buffer Not Exist!"
    endtry
endfunction

function! s:BufferListDeleteBuf()
    let l:bufNum=split(getline('.'),"\ ")[0]
    let l:bufChanged = 0
    try
        exec "bdelete".l:bufNum
    catch
        let l:bufChanged = 1
        echo ">> Buffer Not Saved!"
    endtry
    if l:bufChanged == 0
        setlocal modifiable
        delete _
        setlocal nomodifiable
        if getline('.')==''
            vnew
            call s:QuitRedirWindow()
            return
        endif
        call s:JumpWhenPressJOrK('.', 's:BufferListLocateTarget')
    endif
endfunction

" redirect the command output to a buffer
function! s:BufferListRedir()
    call s:OpenRedirWindow()
    exec "edit BufferList".win_getid()
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=redirWindows
    setlocal modifiable
    silent! put = execute('buffers')
    exec "normal! gg"
    while getline('.') == ""
        exec "normal! dd"
    endwhile
    setlocal nomodifiable
    call s:MapRedirPreview('s:BufferListLocateTarget')
    nnoremap <buffer>dd :call <SID>BufferListDeleteBuf()<CR>
endfunction

let s:SpacePrefixDict['l']='call s:BufferListRedir()'


" +-----------------------------------------------+
" |                                               |
" |    FUZZY FILE SEARCH WITH RIPGREP REDIRECT    |
" |                                               |
" +-----------------------------------------------+


" Fuzzy Match filenames -----------------------------------------------------------------------------
function! s:FileSearchLocateTarget()
    if filereadable(t:redirLocateTarget)
        exec "edit ".t:redirLocateTarget
    else
        echo ">> File Not Exist!"
    endif
endfunction

" redirect the command output to a buffer
function! s:FileSearchRedir(cmd)
    call s:OpenRedirWindow()
    exec "edit FuzzyFilenameSearch".win_getid()."\ ->\ ".t:fileSubStr
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=redirWindows
    setlocal modifiable
    exec "tc ".t:rootDir
    exec "read ".a:cmd
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
    exec "%s/^/".escape(t:rootDir.'/','/')
    exec "normal! gg"
    setlocal nomodifiable
    call s:MapRedirPreview('s:FileSearchLocateTarget')
    echo t:rootDir
endfunction

" Show Files fuzzily searched with git
function! s:FileSearchWithGit(substr)
    let t:fileSubStr=a:substr
    exec "FileSearchRedir !rg --files --path-separator ".s:rgPathSeparator." \| rg --ignore-case ".a:substr
endfunction

" Show Files searched fuzzily without git
function! s:FileSearchWithoutGit(substr)
    let t:fileSubStr=a:substr
    exec "FileSearchRedir !rg --no-ignore --files --path-separator ".s:rgPathSeparator." \| rg --ignore-case ".a:substr
endfunction

command! -nargs=1 -complete=command FileSearchRedir silent! call s:FileSearchRedir(<q-args>)

" Fg means 'file git', search file names fuzzily with git
command! -nargs=1 -complete=command Fg call s:FileSearchWithGit(<q-args>)

" Fs means 'file search', search file names fuzzily
command! -nargs=1 -complete=command Fs call s:FileSearchWithoutGit(<q-args>)


" +-----------------------------------------------+
" |                                               |
" |    FUZZY WORD SEARCH WITH RIPGREP REDIRECT    |
" |                                               |
" +-----------------------------------------------+


function! s:LegalLocations()
    let l:location = split(t:redirLocateTarget, ":")
    if has('win32') || has('win64') || has('win32unix')
        " return path, row, column
        return [l:location[0].':'.l:location[1], l:location[2], l:location[3]]
    else
        return [l:location[0], l:location[1], l:location[2]]
    endif
endfunction

" Global Fuzzy Match Words -------------------------------------------------------------------------
function! s:WordSearchLocateTarget()
    try
        let l:location=s:LegalLocations()
        let l:path=l:location[0]
        let l:row=l:location[1]
        let l:column=l:location[2]
        if s:ConvertWindowsToUnix(expand("%:p"))!=#l:path
            exec "edit ".l:path
        endif
        cal cursor(l:row, l:column)
        normal! zz
        call matchadd('RedirFocusCurMatch', '\c\%#'.t:rgrepSubStr)
    catch
        echo ">> File Not Exist!"
    endtry
endfunction

" redirect the command output to a buffer
function! s:WordSearchRedir(cmd)
    call s:OpenRedirWindow()
    exec "edit RipgrepWordSearch".win_getid()."\ ->\ ".t:rgrepSubStr
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=redirWindows
    setlocal modifiable
    exec "tc ".t:rootDir
    exec "read "a:cmd
    exec "%s/\\r//g"
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
    setlocal nomodifiable
    call s:MapRedirPreview('s:WordSearchLocateTarget')
    echo t:rootDir
endfunction

" Show Words fuzzily searched with git
function! s:WordSearchWithGit(substr)
    let t:rgrepSubStr=a:substr
    let l:rgArgs="--ignore-case --vimgrep --no-heading --path-separator ".s:rgPathSeparator
    exec "WordSearchRedir !rg ".l:rgArgs." ".a:substr." ".t:rootDir
endfunction

" Show Files fuzzily searched without git
function! s:WordSearchWithoutGit(substr)
    let t:rgrepSubStr=a:substr
    let l:rgArgs="--ignore-case --vimgrep --no-heading -no-ignore --path-separator ".s:rgPathSeparator
    exec "WordSearchRedir !rg ".l:rgArgs." ".a:substr." ".t:rootDir
endfunction

command! -nargs=1 -complete=command WordSearchRedir silent! call s:WordSearchRedir(<q-args>)

" Wg means 'word git', search file fuzzily names with git
command! -nargs=1 -complete=command Wg call s:WordSearchWithGit(<q-args>)

" Ws means 'word search', search file fuzzily names without git
command! -nargs=1 -complete=command Ws call s:WordSearchWithoutGit(<q-args>)


" +-----------------------------------------------+
" |                                               |
" |  COMBINE QUICKFIX SHORTCUT WITH REDIRECT SYS  |
" |                                               |
" +-----------------------------------------------+


function! s:PrepareForQuickfix()
    let l:cur_win_id=win_getid()
    if win_id2tabwin(t:redirWinid)[1] != 0 && t:redirWinid != l:cur_win_id
        call win_execute(t:redirWinid, 'close')
    end
    let t:redirPreviewWinid=win_getid(winnr('#'),tabpagenr())
    let t:redirWinid = l:cur_win_id
    bo wincmd J
    resize 10
    setlocal bufhidden=wipe nobuflisted noswapfile nocursorline
endfunction

function! s:QuickfixFocusWord()
    call matchadd('RedirFocusCurMatch', '\c\%#'.expand('<cword>'))
    echo
endfunction

augroup quickFixPreparation
    autocmd!
    autocmd FileType qf call s:PrepareForQuickfix()
    autocmd FileType qf nnoremap <silent><buffer> <CR> <CR>zz:call <SID>QuickfixFocusWord()<CR>
    autocmd FileType qf nnoremap <silent><C-Down> :call win_gotoid(t:redirWinid)<CR>j<CR>zz:call <SID>QuickfixFocusWord()<CR>
    autocmd FileType qf nnoremap <silent><C-Up> :call win_gotoid(t:redirWinid)<CR>k<CR>zz:call <SID>QuickfixFocusWord()<CR>
    autocmd FileType qf call s:UnmapRedirPreview()
augroup END


" +-----------------------------------------------+
" |                                               |
" |      COPY OF ojroques/vim-oscyank GITHUB      |
" |                                               |
" +-----------------------------------------------+


" -------------------- VARIABLES ---------------------------
let s:yank_commands = {
    \ 'operator': {'block': '`[\<C-v>`]y', 'char': '`[v`]y', 'line': "'[V']y"},
    \ 'visual': {'': 'gvy', 'V': 'gvy', 'v': 'gvy'}}
let s:b64_table = [
    \ 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    \ 'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    \ 'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    \ 'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/']

" -------------------- OPTIONS ---------------------------
function s:options_max_length()
    return get(g:, 'oscyank_max_length', 0)
endfunction

function s:options_silent()
    return get(g:, 'oscyank_silent', 0)
endfunction

function s:options_trim()
    return get(g:, 'oscyank_trim', 0)
endfunction

function s:options_osc52()
    return get(g:, 'oscyank_osc52', "\x1b]52;c;%s\x07")
endfunction

" -------------------- UTILS -------------------------------
function s:echo(text, hl)
    echohl a:hl
    echo printf('[oscyank] %s', a:text)
    echohl None
endfunction

function s:encode_b64(str, size)
    let l:bytes = map(range(len(a:str)), 'char2nr(a:str[v:val])')
    let l:b64 = []

    for i in range(0, len(l:bytes) - 1, 3)
        let n = l:bytes[i] * 0x10000
                    \ + get(l:bytes, i + 1, 0) * 0x100
                    \ + get(l:bytes, i + 2, 0)
        call add(l:b64, s:b64_table[n / 0x40000])
        call add(l:b64, s:b64_table[n / 0x1000 % 0x40])
        call add(l:b64, s:b64_table[n / 0x40 % 0x40])
        call add(l:b64, s:b64_table[n % 0x40])
    endfor

    if len(l:bytes) % 3 == 1
        let l:b64[-1] = '='
        let l:b64[-2] = '='
    endif

    if len(l:bytes) % 3 == 2
        let l:b64[-1] = '='
    endif

    let l:b64 = join(l:b64, '')
    if a:size <= 0
        return l:b64
    endif

    let l:chunked = ''
    while strlen(l:b64) > 0
        let l:chunked .= strpart(l:b64, 0, a:size) . "\n"
        let l:b64 = strpart(l:b64, a:size)
    endwhile

    return l:chunked
endfunction

function s:get_text(mode, type)
    " Save user settings
    let l:clipboard = &clipboard
    let l:selection = &selection
    let l:register = getreg('"')
    let l:visual_marks = [getpos("'<"), getpos("'>")]

    " Retrieve text
    set clipboard=
    set selection=inclusive
    silent execute printf('keepjumps normal! %s', s:yank_commands[a:mode][a:type])
    let l:text = getreg('"')

    " Restore user settings
    let &clipboard = l:clipboard
    let &selection = l:selection
    call setreg('"', l:register)
    call setpos("'<", l:visual_marks[0])
    call setpos("'>", l:visual_marks[1])

    return l:text
endfunction

function s:trim_text(text)
    let l:text = a:text
    let l:indent = matchstrpos(l:text, '^\s\+')

    " Remove common indent from all lines
    if l:indent[1] >= 0
        let l:pattern = printf('\n%s', repeat('\s', l:indent[2] - l:indent[1]))
        let l:text = substitute(l:text, l:pattern, '\n', 'g')
    endif

    return trim(l:text)
endfunction

function s:write(osc52)
    if filewritable('/dev/fd/2') == 1
        let l:success = writefile([a:osc52], '/dev/fd/2', 'b') == 0
    elseif has('nvim')
        let l:success = chansend(v:stderr, a:osc52) > 0
    else
        exec("silent! !echo " . shellescape(a:osc52))
        redraw!
        let l:success = 1
    endif
    return l:success
endfunction

" -------------------- PUBLIC ------------------------------
function! s:OSCYank(text) abort
    let l:text = s:options_trim() ? s:trim_text(a:text) : a:text

    if s:options_max_length() > 0 && strlen(l:text) > s:options_max_length()
        call s:echo(printf('Selection is too big: length is %d, limit is %d', strlen(l:text), s:options_max_length()), 'WarningMsg')
        return
    endif

    let l:text_b64 = s:encode_b64(l:text, 0)
    let l:osc52 = printf(s:options_osc52(), l:text_b64)
    let l:success = s:write(l:osc52)

    if !l:success
        call s:echo('Failed to copy selection', 'ErrorMsg')
    elseif !s:options_silent()
        call s:echo(printf('%d characters copied', strlen(l:text)), 'Normal')
    endif

    return l:success
endfunction

function! s:OSCYankOperatorCallback(type) abort
    let l:text = s:get_text('operator', a:type)
    return s:OSCYank(l:text)
endfunction

function! s:OSCYankOperator() abort
    set operatorfunc=s:OSCYankOperatorCallback
    return 'g@'
endfunction

function! s:OSCYankVisual() abort
    let l:text = s:get_text('visual', visualmode())
    return s:OSCYank(l:text)
endfunction

function! s:OSCYankRegister(register) abort
    let l:text = getreg(a:register)
    return s:OSCYank(l:text)
endfunction

nnoremap <silent><expr> Y <SID>OSCYankOperator().'_'
vnoremap <silent>Y :<C-u>call <SID>OSCYankVisual()<CR>
command! -register OSCYankRegister call s:OSCYankRegister('<reg>')


" +-----------------------------------------------+
" |                                               |
" |       TREE EXPLORER FOR FILES AND DIRS        |
" |                                               |
" +-----------------------------------------------+

let s:openedDir = 1
let s:closedDir = -1
let s:fileTreeIndent = '  '
let s:minusKidCountOp = 0
let s:plusKidCountOp = 1
let s:dirSeparator = '/'

function! s:InitTreeVars4Tab()
    let t:topDirPath = getcwd()
    let t:topDirDepth = 0
    let t:treeWinid = -1
    let t:treeBufnr = -1
    let t:treePreWinid = -1
    let t:fullPaths = []
    let t:fullPathsCache = {}
    let t:nodesCache = {}
    let t:kidCountCache = {}
    let t:treeUnamedReg = ""
    let t:treeSearchReg = ""
    let t:treeBufname = "Tree Explorer -> Files & Dirs "
endfunction

function! s:TreeBufLoaded(bufnr)
    for l:bufnr in tabpagebuflist()
        if a:bufnr == l:bufnr
            return 1
        endif
    endfor
    return 0
endfunction

function! s:GetNodesAndFullPaths(path)
    let l:dirNodes = []
    let l:dirPaths = []
    let l:fileNodes = []
    let l:filePaths = []
    let l:items = readdir(a:path)
    let l:path = (a:path == '/') ? '' : a:path
    for l:item in l:items
        let l:fullPath = l:path . s:dirSeparator . l:item
        if isdirectory(l:fullPath)
            call add(l:dirNodes, l:item . s:dirSeparator)
            call add(l:dirPaths, l:fullPath)
        else
            call add(l:fileNodes, l:item)
            call add(l:filePaths, l:fullPath)
        endif
    endfor
    return [l:dirNodes + l:fileNodes, l:dirPaths + l:filePaths]
endfunction

function! s:GetFullPath(lineNum)
    return t:fullPaths[a:lineNum - 2]
endfunction

function! s:GetFullPathsCache(path)
    return t:fullPathsCache[a:path]
endfunction

function! s:IsInFullPathsCache(path)
    return has_key(t:fullPathsCache, a:path)
endfunction

function! s:GetDirDepth(path)
    let l:upperDir = fnamemodify(a:path, ':h')
    if l:upperDir == a:path
        return 1
    endif
    return s:GetDirDepth(l:upperDir) + 1
endfunction

function! s:GetNodesCache(path)
    return t:nodesCache[a:path]
endfunction

function! s:IsInNodesCache(path)
    return has_key(t:nodesCache, a:path)
endfunction

function! s:ClearAllCache()
    let t:nodesCache = {}
    let t:fullPathsCache = {}
    let t:kidCountCache = {}
endfunction

function! s:ClearCache(path)
    silent! call remove(t:nodesCache, a:path)
    silent! call remove(t:fullPathsCache, a:path)
    silent! call remove(t:kidCountCache, a:path)
endfunction

function! s:ChangeKidCountUpward(path, n, depth, operate)
    if a:depth < t:topDirDepth 
        return 
    endif
    if !has_key(t:kidCountCache, a:path)
        let t:kidCountCache[a:path] = 0
    endif
    if a:operate == s:minusKidCountOp
        let t:kidCountCache[a:path] -= a:n
    else
        let t:kidCountCache[a:path] += a:n
    endif
    let l:upperDir = fnamemodify(a:path, ':h')
    call s:ChangeKidCountUpward(l:upperDir, a:n, a:depth - 1, a:operate)
endfunction

function! s:ZeroKidCount(path)
    let t:kidCountCache[a:path] = 0
endfunction

function! s:GetKidCount(path)
    return t:kidCountCache[a:path]
endfunction

function! s:AddIndents(startLine, endLine, indents)
    silent exec a:startLine . ',' . a:endLine . 's/^/' . a:indents .'/'
endfunction

function! s:DeleteIndents(startLine, endLine, endCol)
    if a:endCol == 0
        return
    endif
    exec a:startLine . "normal! 0"
    exec "normal! \<C-V>"
    exec a:endLine . "normal! " . a:endCol . "|"
    silent exec "normal! d"
endfunction

function! s:WriteNodes(lines, startLine, indents)
    if empty(a:lines)
        return
    endif
    call append(a:startLine, a:lines)
    let l:startLine = a:startLine + 1
    let l:endLine = a:startLine + len(a:lines)
    call s:AddIndents(l:startLine, l:endLine, a:indents)
endfunction

function! s:WriteCachedNodes(block, startLine, lineLength, indents)
    let l:startLine = a:startLine + 1
    let l:endLine = a:startLine + a:lineLength
    put = a:block
    exec l:startLine . "normal! ^"
    call s:DeleteIndents(l:startLine, l:endLine, col('.') - 1)
    call s:AddIndents(l:startLine, l:endLine, a:indents)
endfunction

function! s:WriteFullPaths(fullPaths, startLine)
    if empty(a:fullPaths)
        return
    endif
    call extend(t:fullPaths, a:fullPaths, a:startLine)
endfunction

function! s:DeleteNodes(nodeId, startLine, endLine)
    silent exec a:startLine . "," . a:endLine . "delete"
    let t:nodesCache[a:nodeId] = @"
endfunction

function! s:DeleteFullPaths(nodeId, startLine, endLine)
    let t:fullPathsCache[a:nodeId] = remove(t:fullPaths, a:startLine, a:endLine)
endfunction

function! s:IsOpenedDir()
    let l:curLine = line('.')
    if l:curLine == line('$')
        return s:closedDir
    endif
    exec l:curLine . "normal! ^"
    let l:curInentCharNum = col('.')
    let l:nextLine = l:curLine + 1
    exec l:nextLine . "normal! ^"
    let l:nextInentCharNum = col('.')
    exec l:curLine . "normal! ^"
    if(l:curInentCharNum < l:nextInentCharNum)
        return s:openedDir
    endif
    return s:closedDir
endfunction

function! s:OpenDir()
    normal ^
    let l:curLine = line('.')
    let l:curCol = col('.')
    let l:indents = repeat(s:fileTreeIndent, l:curCol / len(s:fileTreeIndent) + 1)
    " nodeId is the full path of the node under the cursor
    let l:nodeId = s:GetFullPath(l:curLine)
    let l:dirDepth = s:GetDirDepth(l:nodeId)
    if s:IsInNodesCache(l:nodeId) || s:IsInFullPathsCache(l:nodeId)
        setlocal modifiable
        let l:nodes = s:GetNodesCache(l:nodeId)
        let l:fullPaths = s:GetFullPathsCache(l:nodeId)
        let l:kidCount = len(l:fullPaths)
        call s:ZeroKidCount(l:nodeId)
        call s:ChangeKidCountUpward(l:nodeId, l:kidCount, l:dirDepth, s:plusKidCountOp)
        call s:WriteCachedNodes(l:nodes, l:curLine, l:kidCount, l:indents)
        call s:WriteFullPaths(l:fullPaths, l:curLine - 1)
        exec l:curLine . "normal! ^"
        setlocal nomodifiable
        return
    endif
    let l:nodesAndFullPaths = s:GetNodesAndFullPaths(l:nodeId)
    let l:nodes = l:nodesAndFullPaths[0]
    let l:fullPaths = l:nodesAndFullPaths[1]
    if len(l:nodes) == 0 || len(l:fullPaths) == 0
        echo ">> Empty folder!"
        return
    endif
    setlocal modifiable
    let l:kidCount = len(l:nodes)
    call s:ChangeKidCountUpward(l:nodeId, l:kidCount, l:dirDepth, s:plusKidCountOp)
    call s:WriteNodes(l:nodes, l:curLine, l:indents)
    call s:WriteFullPaths(l:fullPaths, l:curLine - 1)
    exec l:curLine . "normal! ^"
    setlocal nomodifiable
endfunction

function! s:CloseDir()
    setlocal modifiable
    let l:curLine = line('.')
    " nodeId is the full path of the node under the cursor
    let l:nodeId = s:GetFullPath(l:curLine)
    let l:dirDepth = s:GetDirDepth(l:nodeId)
    let l:kidCount = s:GetKidCount(l:nodeId)
    let l:startLine = l:curLine + 1
    let l:endLine = l:curLine + l:kidCount
    call s:ChangeKidCountUpward(l:nodeId, l:kidCount, l:dirDepth, s:minusKidCountOp)
    call s:DeleteNodes(l:nodeId, l:startLine, l:endLine)
    call s:DeleteFullPaths(l:nodeId, l:startLine - 2, l:endLine - 2)
    exec l:curLine . "normal! ^"
    setlocal nomodifiable
endfunction

function! s:OpenFile(previewQuickly)
    let l:curLine = line('.')
    let l:nodeId = s:GetFullPath(l:curLine)
    if l:curLine == 1
        return
    endif
    if isdirectory(expand(l:nodeId))
        return
    endif
    if !filereadable(expand(l:nodeId))
        echo ">> File not exists!"
        return
    endif
    let l:curWinid = win_getid()
    let l:GoBack2TreeExplorer = {-> a:previewQuickly == 1 ? "call win_gotoid(l:curWinid)" : ""}
    if win_id2tabwin(t:treePreWinid)[1] == 0
        bot vs
        silent exec "edit ".l:nodeId
        echo l:nodeId
        exec l:GoBack2TreeExplorer()
        return
    endif
    call win_gotoid(t:treePreWinid)
    if expand(bufname()) ==# l:nodeId
        exec l:GoBack2TreeExplorer()
        return
    endif
    silent exec "edit ".l:nodeId
    echo l:nodeId
    exec l:GoBack2TreeExplorer()
endfunction

function! s:Upper()
    let l:curFullPath = getline(2)[:-2]
    let l:upperDir = fnamemodify(l:curFullPath, ':h')
    if l:curFullPath == l:upperDir
        return
    endif
    exec 2
    if s:IsOpenedDir() == s:closedDir
        call s:InitTree(l:upperDir)
        exec 2
        return
    endif
    call s:CloseDir()
    call s:InitTree(l:upperDir)
    silent exec '/ '.fnamemodify(l:curFullPath, ':t').'\'.s:dirSeparator
    let @/ = ''
    call s:OpenDir()
    exec 2
endfunction

function! s:CdCurDir()
    let l:curLine = line('.')
    let l:nodeId = t:fullPaths[l:curLine - 2]
    call s:ClearAllCache()
    call s:InitTree(l:nodeId)
endfunction

function! s:RefreshDir()
    let l:curLine = line('.')
    if l:curLine == 1
        call s:Upper()
        return
    endif
    let l:nodeId = t:fullPaths[l:curLine - 2]
    if !isdirectory(l:nodeId)
        echo ">> Can not refresh a file, but a dir!"
        return
    endif
    if s:IsOpenedDir() == s:openedDir
        call s:CloseDir()
    endif
    call s:ClearCache(l:nodeId)
    call s:OpenDir()
endfunction

function! s:HighlightTree()
    syntax clear
    syntax match Directory ".*\/$"
    exec 'syntax match Directory ".*\' . s:dirSeparator . '$"'
endfunction

function! s:MapTree()
    nnoremap <buffer><silent> <CR> :call <SID>ToggleNode()<CR>
    nnoremap <buffer><silent> r :call <SID>RefreshDir()<CR>
    nnoremap <buffer><silent> c :call <SID>CdCurDir()<CR>
    nnoremap <buffer> <S-Up> <Up>:call <SID>OpenFile(1)<CR>
    nnoremap <buffer> <S-Down> <Down>:call <SID>OpenFile(1)<CR>
endfunction

function! s:BeforeEnterTree()
    let t:treeSearchReg = @/
    let t:treeUnamedReg = @"
endfunction

function! s:AfterLeaveTree()
    let @/ = t:treeSearchReg
    let @" = t:treeUnamedReg
endfunction

function! s:SetTreeOptions()
    setlocal buftype=nofile nobuflisted noswapfile bufhidden=hide
    setlocal tabstop=2 shiftwidth=2 softtabstop=2 
    setlocal list listchars=multispace:\|\ 
    setlocal nonumber norelativenumber
    setlocal cursorline
    setlocal cursorlineopt=line
    setlocal autoread
    let l:winid = win_getid()
    let t:treeBufname = t:treeBufname.l:winid
    exec "file ".t:treeBufname
    augroup switchContext
        autocmd!
        autocmd BufEnter <buffer> call s:BeforeEnterTree()
        autocmd BufLeave <buffer> call s:AfterLeaveTree()
        autocmd BufHidden <buffer> let t:treeWinid = -1
    augroup END
endfunction

function! s:InitTree(path)
    setlocal modifiable
    let t:topDirPath = a:path
    let t:topDirDepth = s:GetDirDepth(a:path)
    let t:treeBufnr = bufnr()
    let t:treeWinid = win_getid()
    silent exec '%d'
    call s:HighlightTree()
    call setline(1, '..' . s:dirSeparator)
    if a:path == '/'
        call setline(2, a:path) 
    else
        call setline(2, a:path . s:dirSeparator) 
    endif
    let t:fullPaths = []
    call insert(t:fullPaths, a:path)
    exec 2
    call s:OpenDir()
    setlocal nomodifiable
endfunction

function! s:ToggleNode()
    echo
    let l:curLine = line('.')
    if l:curLine == 1
        call s:Upper()
        return
    endif
    let l:lineContent = getline(l:curLine)
    if l:lineContent[-1:] != s:dirSeparator
        call s:OpenFile(0)
        return
    endif
    if s:IsOpenedDir() == s:closedDir
        call s:OpenDir()
        return
    endif
    call s:CloseDir()
endfunction

function! s:ToggleTree(path)
    let t:treePreWinid = win_getid()
    if t:treeBufnr == -1
        to vnew
        call s:BeforeEnterTree()
        call s:InitTree(a:path)
        call s:MapTree()
        call s:SetTreeOptions()
        return
    endif
    if a:path ==# t:topDirPath && s:TreeBufLoaded(t:treeBufnr)
        call win_gotoid(t:treeWinid)
        let t:treeWinid = -1
        quit
        return
    endif
    if a:path ==# t:topDirPath
        to vs
        exec "buffer ".t:treeBufname
        let t:treeWinid = win_getid()
        return
    endif
    if t:treeWinid == win_getid()
        return
    endif
    if s:TreeBufLoaded(t:treeBufnr)
        call win_gotoid(t:treeWinid)
    else
        to vs
        exec "buffer ".t:treeBufname
        let t:treeWinid = win_getid()
    endif
    call s:ClearAllCache()
    call s:InitTree(a:path)
endfunction

augroup InitTreeVars4TabGroup
    autocmd!
    autocmd TabNew,VimEnter * call <SID>InitTreeVars4Tab()
augroup END

set splitright
let s:SpacePrefixDict['e']='call s:ToggleTree(t:topDirPath)'
command! OpenTreeByCurCwd call s:ToggleTree(expand(getcwd()))
command! OpenTreeByCurBuf call s:ToggleTree(expand("%:p:h"))
command! -nargs=1 OpenTreeByPath call s:ToggleTree(expand(<q-args>))
