" Fuzzy Match filenames -----------------------------------------------------------------------------
function! FileSearchLocateTarget()
    if filereadable(expand(t:redirLocateTarget))
        exec "edit ".t:redirLocateTarget
    else
        echo ">> File Not Exist!"
    endif
endfunction

" redirect the command output to a buffer
function! FileSearchRedir(cmd)
    call OpenRedirWindow()
    exec "edit FuzzyFilenameSearch".tabpagenr()."\ ->\ ".t:fileSubStr
    exec "read ".a:cmd
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=redirWindows
    call FileSearchJumpMap()
endfunction

" Show Files fuzzily searched with git
function! FileSearchWithGit(substr)
    let t:fileSubStr=a:substr
    exec "cd ".t:rootDir
    exec "FileSearchRedir !rg --files \| rg --ignore-case ".a:substr
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" Show Files searched fuzzily without git
function! FileSearchWithoutGit(substr)
    let t:fileSubStr=a:substr
    exec "cd ".t:rootDir
    exec "FileSearchRedir !rg --no-ignore --files \| rg --ignore-case ".a:substr
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" autocmd to jump to file with CR only in FuzzyFilenameSearch buffer
function! FileSearchJumpMap()
    nnoremap <buffer><silent><CR> <cmd>call JumpWhenPressEnter('FileSearchLocateTarget')<CR>
    nnoremap <buffer><silent>j <cmd>call JumpWhenPressJOrK('+', 'FileSearchLocateTarget')<CR>
    nnoremap <buffer><silent>k <cmd>call JumpWhenPressJOrK('-', 'FileSearchLocateTarget')<CR>
endfunction

command! -nargs=1 -complete=command FileSearchRedir silent! call FileSearchRedir(<q-args>)

" Fg means 'file git', search file names fuzzily with git
command! -nargs=1 -complete=command Fg silent! call FileSearchWithGit(<q-args>)

" Fs means 'file search', search file names fuzzily
command! -nargs=1 -complete=command Fs silent! call FileSearchWithoutGit(<q-args>)

