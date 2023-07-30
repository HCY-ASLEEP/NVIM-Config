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

command! -nargs=1 -complete=command FindRedir silent! call FindRedir(<q-args>)

" Fg means 'file git', search file names fuzzily with git
command! -nargs=1 -complete=command Fg silent! call FindWithGit(<q-args>)

" Fs means 'file search', search file names fuzzily
command! -nargs=1 -complete=command Fs silent! call FindWithoutGit(<q-args>)


