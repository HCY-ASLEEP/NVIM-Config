" Global Fuzzy Match words -------------------------------------------------------------------------
let t:rgFocusCurMatchId=-1

hi RgFocusCurMatch ctermfg=lightgreen ctermbg=darkgray cterm=bold

" Go to the file on line
function! RgJump(location)
    exec "cd ".g:rootDir
    let l:location = split(a:location, ":")
    exec t:redirPreviewWinnr."wincmd w"
    try
        exec "edit ".l:location[0]
        cal cursor(l:location[1], l:location[2])
        let t:rgFocusCurMatchId=matchadd('RgFocusCurMatch', '\c\%#'.t:rgrepSubStr)
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

augroup ripgrepWordSearch
    autocmd!
    autocmd BufWinLeave RipgrepWordSearch* silent! call matchdelete(t:rgFocusCurMatchId)
augroup END

command! -nargs=1 -complete=command RgRedir silent! call RgRedir(<q-args>)

" Wg means 'word git', search file fuzzily names with git
command! -nargs=1 -complete=command Wg silent! call RgWithGit(<q-args>)

" Ws means 'word search', search file fuzzily names without git
command! -nargs=1 -complete=command Ws silent! call RgWithoutGit(<q-args>)

