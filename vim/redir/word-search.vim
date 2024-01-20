function! LegalLocationsInUnix()
    let l:location = split(t:redirLocateTarget, ":")
    " return path, row, column
    return [l:location[0], l:location[1], l:location[2]]
endfunction

function! LegalLocationsInWindows()
    let l:location = split(t:redirLocateTarget, ":")
    " return path, row, column
    let l:path = substitute(l:location[0].":".l:location[1], '\\\\', '/', 'g')
    let l:path = substitute(l:path, '\\', '/', 'g')
    return [l:path, l:location[2], l:location[3]]
endfunction

if has('win32') || has('win64') || has('win32unix')
    let s:LegalLocations=function('LegalLocationsInWindows')
else
    let s:LegalLocations=function('LegalLocationsInUnix')
endif

" Global Fuzzy Match words -------------------------------------------------------------------------
function! WordSearchLocateTarget()
    try
        let l:location=s:LegalLocations()
        let l:path=l:location[0]
        let l:row=l:location[1]
        let l:column=l:location[2]
        if expand("%:p")!=#l:path
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
function! WordSearchRedir(cmd)
    call OpenRedirWindow()
    exec "edit RipgrepWordSearch".tabpagenr()."\ ->\ ".t:rgrepSubStr
    exec "read "a:cmd
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=redirWindows
    call WordSearchJumpMap()
endfunction

" Show Words fuzzily searched with git
function! WordSearchWithGit(substr)
    let t:rgrepSubStr=a:substr
    let l:rgArgs="--ignore-case --vimgrep --no-heading"
    exec "cd ".t:rootDir
    exec "WordSearchRedir !rg ".l:rgArgs." ".a:substr." ".t:rootDir
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" Show Files fuzzily searched without git
function! WordSearchWithoutGit(substr)
    let t:rgrepSubStr=a:substr
    let l:rgArgs="--ignore-case --vimgrep --no-heading --no-ignore"
    exec "cd ".t:rootDir
    exec "WordSearchRedir !rg ".l:rgArgs." ".a:substr." ".t:rootDir
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" autocmd to jump to file with CR only in RipgrepWordSearch buffer
function! WordSearchJumpMap()
    nnoremap <buffer><silent><CR> <cmd>call JumpWhenPressEnter('WordSearchLocateTarget')<CR>
    nnoremap <buffer><silent>j <cmd>call JumpWhenPressJOrK('+', 'WordSearchLocateTarget')<CR>
    nnoremap <buffer><silent>k <cmd>call JumpWhenPressJOrK('-', 'WordSearchLocateTarget')<CR>
endfunction

command! -nargs=1 -complete=command WordSearchRedir silent! call WordSearchRedir(<q-args>)

" Wg means 'word git', search file fuzzily names with git
command! -nargs=1 -complete=command Wg silent! call WordSearchWithGit(<q-args>)

" Ws means 'word search', search file fuzzily names without git
command! -nargs=1 -complete=command Ws silent! call WordSearchWithoutGit(<q-args>)
