" Global Fuzzy Match words -------------------------------------------------------------------------
function! RgLocateTarget()
    let l:location = split(t:rgLocateTarget, ":")
    try
        exec "edit ".l:location[0]
        cal cursor(l:location[1], l:location[2])
        call matchadd('RgFocusCurMatch', '\c\%#'.t:rgrepSubStr)
        normal! zz
    catch
        echo ">> File Not Exist!"
    endtry
endfunction

" Go to the file on line
function! RgJump(location)
    exec "cd ".t:rootDir
    exec t:redirPreviewWinnr."wincmd w"
    let t:rgLocateTarget=a:location
    call RgLocateTarget()
endfunction

" redirect the command output to a buffer
function! RgRedir(cmd)
    call RgJumpMap()
    call OpenRedirWindow()
    exec "edit RipgrepWordSearch".tabpagenr()."\ ->\ ".t:rgrepSubStr
    exec "read "a:cmd
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=RipgrepWordSearch
endfunction

" Show Words fuzzily searched with git
function! RgWithGit(substr)
    let t:rgrepSubStr=a:substr
    exec "cd ".t:rootDir
    exec "RgRedir !rg '".a:substr."' ".getcwd()." --ignore-case --vimgrep --no-heading"
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" Show Files fuzzily searched without git
function! RgWithoutGit(substr)
    let t:rgrepSubStr=a:substr
    exec "cd ".t:rootDir
    exec "RgRedir !rg '".a:substr."' ".getcwd()." --ignore-case --vimgrep --no-heading --no-ignore"
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" To show file preview, underlying of RgNext, imitate 'cNext' command
function! RgShow(direction)
    let l:rgWinNum=bufwinnr(bufnr('^RipgrepWordSearch'.tabpagenr()))
    if l:rgWinNum == -1
        echo ">> No RipgrepWordSearch Buffer!"
        return
    endif
    exec l:rgWinNum."wincmd w"
    exec "cd ".t:rootDir
    exec "normal! ".a:direction
    let l:redirPreviewWinId=win_getid(t:redirPreviewWinnr)
    let t:rgLocateTarget=getline('.')
    call win_execute(l:redirPreviewWinId, "call RgLocateTarget()")
endfunction

" imitate 'cNext'
function! RgNext()
    call RgShow("+")
endfunction

" imitate 'cprevious'
function! RgPre()
    call RgShow("-")
endfunction

function! RgClearFocusCurMatchWhenTabEnter()
    if bufwinnr(bufnr('^RipgrepWordSearch'.tabpagenr()))==-1
        hi clear RgFocusCurMatch
    else
        hi RgFocusCurMatch ctermfg=lightgreen ctermbg=darkgray cterm=bold
    endif
endfunction

" autocmd to jump to file with CR only in RipgrepWordSearch buffer
function! RgJumpMap()
    augroup rgJumpMap
        autocmd!
        autocmd FileType RipgrepWordSearch nnoremap <buffer><silent><CR> <cmd>call RgJump(getline('.'))<CR>
        autocmd FileType RipgrepWordSearch nnoremap <buffer><silent>j <cmd>call RgNext()<CR>
        autocmd FileType RipgrepWordSearch nnoremap <buffer><silent>k <cmd>call RgPre()<CR>
    augroup END
endfunction

augroup ripgrepWordSearch
    autocmd!
    autocmd BufWinLeave RipgrepWordSearch* silent! hi clear RgFocusCurMatch 
    autocmd BufEnter RipgrepWordSearch* silent! hi RgFocusCurMatch ctermfg=lightgreen ctermbg=darkgray cterm=bold
    autocmd TabEnter * call RgClearFocusCurMatchWhenTabEnter()
augroup END

command! -nargs=1 -complete=command RgRedir silent! call RgRedir(<q-args>)

" Wg means 'word git', search file fuzzily names with git
command! -nargs=1 -complete=command Wg silent! call RgWithGit(<q-args>)

" Ws means 'word search', search file fuzzily names without git
command! -nargs=1 -complete=command Ws silent! call RgWithoutGit(<q-args>)

