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

" highlight search
nnoremap <silent><space><space> :set hlsearch! hlsearch?<CR>

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

" jump to the last position when reopening a file
" ! You must mkdir viewdir first !
set viewdir=~/.vimviews/
augroup keepBufView
    autocmd!
    autocmd BufWinLeave *.* mkview
    autocmd BufWinEnter *.* silent! loadview 
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
        call feedkeys("\<CR>\<ESC>\O", 'n')
    else
        call feedkeys("\<CR>", 'n')
    endif
endfunction
inoremap <expr> <CR> InsertCRBrace()


" map ;; to esc -----------------------------------------------------------------------------------
function! ESC_IMAP()
    " If the char in front the cursor is ";"
    if getline('.')[col('.') - 2]== ";" 
        call feedkeys("\<BS>\<BS>\<ESC>", 'n')
    else
        call feedkeys("\<BS>\;", 'n')
    endif
endfunction
inoremap <expr> ; ESC_IMAP()

vnoremap ;; <ESC>
snoremap ;; <ESC>
xnoremap ;; <ESC>
cnoremap ;; <ESC>
onoremap ;; <ESC>

" exit windows
tnoremap ;; <C-\><C-n>

" internal terminal settings
augroup internal_terminal
    autocmd!
    autocmd TermOpen * set nonumber norelativenumber
augroup END

" switch windows -----------------------------------------------------------------------------------
nnoremap <silent><TAB> :wincmd w<CR>


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


" netrw settings -----------------------------------------------------------------------------------
" not show the help banner on top 
let g:netrw_banner = 0

" make explorer show files like a tree
let g:netrw_liststyle = 3

" see help doc to know more about this global var
let g:netrw_browse_split = 4

" skip the netrw win when the netrw hidden
function! SkipNetrwWin()
    augroup skipNetrwWin
        autocmd!
        autocmd BufEnter NetrwTreeListing :wincmd w
    augroup END
endfunction

" open explorer by specific size
function! OpenExplorerOnSize(size)
    let t:win_width=a:size
    exec "botright "t:win_width."vsplit"
    exec "Explore"
endfunction

function! ToggleExplorer()
    let l:expl_win_num = bufwinnr(bufnr('NetrwTreeListing'))

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
            let t:win_width=t:max_win_width

            " disable skip netrw win
            autocmd! skipNetrwWin
            exec l:expl_win_num."wincmd w"
        endif
        exec "vertical ".l:expl_win_num."resize ".t:win_width
    else
        call OpenExplorerOnSize(t:max_win_width)
        if l:enewFlag == 1
            wincmd w
        endif
    endif
endfunction

nnoremap <silent><SPACE>e :call ToggleExplorer()<CR>

function! ExploreWhenEnter()
    
    let l:expl_win_num = bufwinnr(bufnr('NetrwTreeListing'))
    
    " if expl_win_num not exists
    if l:expl_win_num == -1
    
        " explorer vertical split max win width
        let t:max_win_width=25
        
        " record the win num of workspace except explorer where cursor in
        let t:cur_work_win_num = winnr()
        call OpenExplorerOnSize(t:max_win_width)
        wincmd w
        
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
hi CursorLine ctermfg=black ctermbg=blue cterm=bold
hi CursorLineNr ctermfg=darkyellow ctermbg=NONE cterm=NONE
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


" python special focus -----------------------------------------------------------------------------
augroup pythonSpecialFocus
    autocmd!
    autocmd Filetype python 
        \  setlocal list
        \| setlocal listchars=space:\ 
        \| setlocal listchars+=multispace:\ \ \ ┊
augroup END


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
    
        let l:s .= '%' . l:tab . 'T'
        let l:s .= (l:tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
        let l:s .= ' ' . l:tab .' '
        let l:s .= (l:bufname != '' ? '['. fnamemodify(l:bufname, ':t') . '] ' : '[No Name] ')
    
        if l:bufmodified
            let l:s .= '[+] '
        endif
    endfor
    
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
hi TabLineSel ctermfg=black ctermbg=white cterm=bold

nnoremap <silent><S-TAB> :tabnext<CR>


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
    let l:findWinNum=bufwinnr(bufnr('FuzzyFilenameSearch'))
    let l:rgWinNum=bufwinnr(bufnr('RipgrepWordSearch'))
    let l:bufferListWinNum=bufwinnr(bufnr('BufferList'))
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
    let l:findWinNum=bufwinnr(bufnr('FuzzyFilenameSearch'))
    let l:rgWinNum=bufwinnr(bufnr('RipgrepWordSearch'))
    let l:bufferListWinNum=bufwinnr(bufnr('BufferList'))
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

nnoremap <silent><space>q :call QuitRedirWindow()<CR>

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
function! FindJumpWithCR()
    augroup findJumpWithCR
        autocmd!
        autocmd FileType FuzzyFilenameSearch nnoremap <buffer><silent><CR> :call FindJump(getline('.'))<CR>
    augroup END
endfunction

" redirect the command output to a buffer
function! FindRedir(cmd)
    call FindJumpWithCR()
    call OpenRedirWindow()
    edit FuzzyFilenameSearch
    exec "read ".a:cmd
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=FuzzyFilenameSearch
endfunction

command! -nargs=1 -complete=command FindRedir silent call FindRedir(<q-args>)

" Show Files fuzzily searched with git
function! FindWithGit(substr)
    exec "FindRedir !rg --files \| rg --ignore-case ".a:substr
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
    call feedkeys("/".a:substr."\\c\<CR>" ,'n')
endfunction

" Show Files searched fuzzily without git
function! FindWithoutGit(substr)
    exec "FindRedir !rg --no-ignore --files \| rg --ignore-case ".a:substr
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
    call feedkeys("/".a:substr."\\c\<CR>" ,'n')
endfunction

" Fg means 'file git', search file names fuzzily with git
command! -nargs=1 -complete=command Fg silent call FindWithGit(<q-args>)

" Fs means 'file search', search file names fuzzily
command! -nargs=1 -complete=command Fs silent call FindWithoutGit(<q-args>)

" To show file preview, underlying of FindNext, imitate 'cNext' command
function! FindShow(direction)
    let l:findWinNum=bufwinnr(bufnr('FuzzyFilenameSearch'))
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

nnoremap <silent><C-down> :call FindNext()<CR>
nnoremap <silent><C-up> :call FindPre()<CR>


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
function! RgJumpWithCR()
    augroup rgJumpWithCR
        autocmd!
        autocmd FileType RipgrepWordSearch nnoremap <buffer><silent><CR> :call RgJump(getline('.'))<CR>
    augroup END
endfunction

" redirect the command output to a buffer
function! RgRedir(cmd)
    call RgJumpWithCR()
    call OpenRedirWindow()
    edit RipgrepWordSearch
    exec "read "a:cmd
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=RipgrepWordSearch
endfunction

command! -nargs=1 -complete=command RgRedir silent call RgRedir(<q-args>)

" Show Words fuzzily searched with git
function! RgWithGit(substr)
    exec "RgRedir !rg '".a:substr."' ".getcwd()." --ignore-case --vimgrep --no-heading"
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
    call feedkeys("/".a:substr."\\c\<CR>" ,'n')
endfunction

" Show Files fuzzily searched without git
function! RgWithoutGit(substr)
    exec "RgRedir !rg '".a:substr."' ".getcwd()." --ignore-case --vimgrep --no-heading --no-ignore"
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
    call feedkeys("/".a:substr."\\c\<CR>" ,'n')
endfunction

" Wg means 'word git', search file fuzzily names with git
command! -nargs=1 -complete=command Wg silent call RgWithGit(<q-args>)

" Ws means 'word search', search file fuzzily names without git
command! -nargs=1 -complete=command Ws silent! call RgWithoutGit(<q-args>)

" To show file preview, underlying of RgNext, imitate 'cNext' command
function! RgShow(direction)
    let l:rgWinNum=bufwinnr(bufnr('RipgrepWordSearch'))
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

nnoremap <silent><S-down> :call RgNext()<CR>
nnoremap <silent><S-up> :call RgPre()<CR>


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
function! BufferListJumpWithCR()
    augroup findJumpWithCR
        autocmd!
        autocmd FileType BufferList nnoremap <buffer><silent><CR> :call BufferListJump(getline('.'))<CR>
    augroup END
endfunction

" redirect the command output to a buffer
function! BufferListRedir()
    call BufferListJumpWithCR()
    call OpenRedirWindow()
    edit BufferList
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

command! B call BufferListRedir()

" To show the buffer selected, underlying of BufferListNext, imitate 'cNext' command
function! BufferListShow(direction)
    let l:bufferListWinNum=bufwinnr(bufnr('BufferList'))
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

nnoremap <silent><M-down> :call BufferListNext()<CR>
nnoremap <silent><M-up> :call BufferListPre()<CR>
nnoremap <silent><space>l :B<CR>


set completeopt=menuone,noselect

" use tab for navigating the autocomplete menu
inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

function! OpenNoLSPCompletion()
    if v:char =~ '[A-Za-z0-9_]' && !pumvisible() 
        call feedkeys("\<C-n>", "n")
    endif
endfunction

function! AutoComplete()
    augroup openNoLSPCompletion
        autocmd!
        autocmd InsertCharPre * silent! call OpenNoLSPCompletion()
    augroup END
endfunction

augroup initAutoComplete
    autocmd!
    autocmd TabEnter,VimEnter * call AutoComplete()
augroup END


" vim-plug(4) ---------------------------------------------------------------------------------------
call plug#begin($HOME.'/.local/share/nvim/site/autoload')
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
call plug#end()


augroup MarkdownPreview
    autocmd!
    auto Filetype markdown source $HOME/.config/nvim/markdown.vim
augroup END


