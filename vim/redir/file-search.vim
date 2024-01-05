" Fuzzy Match filenames -----------------------------------------------------------------------------
function! FindLocateTarget()
    if filereadable(expand(t:findLocateTarget))
        exec "edit ".t:findLocateTarget
    else
        echo ">> File Not Exist!"
    endif
endfunction

" Go to the file on line
function! FindJump(path)
    exec "cd ".t:rootDir
    let l:redirPreviewWinnr = win_id2tabwin(t:redirPreviewWinid)[1]
    if l:redirPreviewWinnr <= 0
        new
        let t:redirPreviewWinid = win_getid()
    else
        exec l:redirPreviewWinnr."wincmd w"
    endif
    let t:findLocateTarget=a:path
    call FindLocateTarget()
endfunction

" redirect the command output to a buffer
function! FindRedir(cmd)
    call OpenRedirWindow()
    exec "edit FuzzyFilenameSearch".tabpagenr()."\ ->\ ".t:findSubStr
    exec "read ".a:cmd
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=redirWindows
    call FindJumpMap()
endfunction

" Show Files fuzzily searched with git
function! FindWithGit(substr)
    let t:findSubStr=a:substr
    exec "cd ".t:rootDir
    exec "FindRedir !rg --files \| rg --ignore-case ".a:substr
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" Show Files searched fuzzily without git
function! FindWithoutGit(substr)
    let t:findSubStr=a:substr
    exec "cd ".t:rootDir
    exec "FindRedir !rg --no-ignore --files \| rg --ignore-case ".a:substr
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" To show file preview, underlying of FindNext, imitate 'cNext' command
function! FindShow(direction)
    exec "cd ".t:rootDir
    exec "normal!".a:direction
    let t:findLocateTarget=getline('.')
    let l:redirPreviewWinnr = win_id2tabwin(t:redirPreviewWinid)[1]
    if l:redirPreviewWinnr <= 0
        top new
        let t:redirPreviewWinid = win_getid()
        wincmd p
    endif
    call win_execute(t:redirPreviewWinid,"call FindLocateTarget()")
endfunction

" imitate 'cNext'
function! FindNext()
    call FindShow("+")
endfunction

" imitate 'cprevious'
function! FindPre()
    call FindShow("-")
endfunction

" autocmd to jump to file with CR only in FuzzyFilenameSearch buffer
function! FindJumpMap()
    nnoremap <buffer><silent><CR> <cmd>call FindJump(getline('.'))<CR>
    nnoremap <buffer><silent>j <cmd>call FindNext()<CR>
    nnoremap <buffer><silent>k <cmd>call FindPre()<CR>
endfunction

command! -nargs=1 -complete=command FindRedir silent! call FindRedir(<q-args>)

" Fg means 'file git', search file names fuzzily with git
command! -nargs=1 -complete=command Fg silent! call FindWithGit(<q-args>)

" Fs means 'file search', search file names fuzzily
command! -nargs=1 -complete=command Fs silent! call FindWithoutGit(<q-args>)


