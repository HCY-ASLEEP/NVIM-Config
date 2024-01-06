" Fuzzy Match filenames -----------------------------------------------------------------------------
function! FileLocateTarget()
    if filereadable(expand(t:redirLocateTarget))
        exec "edit ".t:redirLocateTarget
    else
        echo ">> File Not Exist!"
    endif
endfunction

" redirect the command output to a buffer
function! FileRedir(cmd)
    call OpenRedirWindow()
    exec "edit FuzzyFilenameSearch".tabpagenr()."\ ->\ ".t:fileSubStr
    exec "read ".a:cmd
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=redirWindows
    call FileJumpMap()
endfunction

" Show Files fuzzily searched with git
function! FileWithGit(substr)
    let t:fileSubStr=a:substr
    exec "cd ".t:rootDir
    exec "FileRedir !rg --files \| rg --ignore-case ".a:substr
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" Show Files searched fuzzily without git
function! FileWithoutGit(substr)
    let t:fileSubStr=a:substr
    exec "cd ".t:rootDir
    exec "FileRedir !rg --no-ignore --files \| rg --ignore-case ".a:substr
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" autocmd to jump to file with CR only in FuzzyFilenameSearch buffer
function! FileJumpMap()
    nnoremap <buffer><silent><CR> <cmd>call JumpWhenPressEnter(function('FileLocateTarget'))<CR>
    nnoremap <buffer><silent>j <cmd>call JumpWhenPressJOrK('+', 'FileLocateTarget')<CR>
    nnoremap <buffer><silent>k <cmd>call JumpWhenPressJOrK('-', 'FileLocateTarget')<CR>
endfunction

command! -nargs=1 -complete=command FileRedir silent! call FileRedir(<q-args>)

" Fg means 'file git', search file names fuzzily with git
command! -nargs=1 -complete=command Fg silent! call FileWithGit(<q-args>)

" Fs means 'file search', search file names fuzzily
command! -nargs=1 -complete=command Fs silent! call FileWithoutGit(<q-args>)

