function! LegalLocationsInUnix()
    let l:location = split(t:rgLocateTarget, ":")
    " return path, row, column
    return [l:location[0], l:location[1], l:location[2]]
endfunction

function! LegalLocationsInWindows()
    let l:location = split(t:rgLocateTarget, ":")
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
function! RgLocateTarget()
    try
        let l:location=s:LegalLocations()
        let l:path=l:location[0]
        let l:row=l:location[1]
        let l:column=l:location[2]
        exec "edit ".l:path
        cal cursor(l:row, l:column)
        call matchadd('RgFocusCurMatch', '\c\%#'.t:rgrepSubStr)
        normal! zz
    catch
        echo ">> File Not Exist!"
    endtry
endfunction

" Go to the file on line
function! RgJump(location)
    exec "cd ".t:rootDir
    let l:redirPreviewWinnr = win_id2tabwin(t:redirPreviewWinid)[1]
    if l:redirPreviewWinnr <= 0
        new
        let t:redirPreviewWinid = win_getid()
    else
        exec l:redirPreviewWinnr."wincmd w"
    endif
    let t:rgLocateTarget=a:location
    call RgLocateTarget()
endfunction

" redirect the command output to a buffer
function! RgRedir(cmd)
    call OpenRedirWindow()
    exec "edit RipgrepWordSearch".tabpagenr()."\ ->\ ".t:rgrepSubStr
    exec "read "a:cmd
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=redirWindows
    call RgJumpMap()
endfunction

" Show Words fuzzily searched with git
function! RgWithGit(substr)
    let t:rgrepSubStr=a:substr
    let l:rgArgs="--ignore-case --vimgrep --no-heading"
    exec "cd ".t:rootDir
    exec "RgRedir !rg ".l:rgArgs." ".a:substr." ".t:rootDir
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" Show Files fuzzily searched without git
function! RgWithoutGit(substr)
    let t:rgrepSubStr=a:substr
    let l:rgArgs="--ignore-case --vimgrep --no-heading --no-ignore"
    exec "cd ".t:rootDir
    exec "RgRedir !rg ".l:rgArgs." ".a:substr." ".t:rootDir
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" To show file preview, underlying of RgNext, imitate 'cNext' command
function! RgShow(direction)
    exec "cd ".t:rootDir
    exec "normal! ".a:direction
    let t:rgLocateTarget=getline('.')
    let l:redirPreviewWinnr = win_id2tabwin(t:redirPreviewWinid)[1]
    if l:redirPreviewWinnr <= 0
        top new
        let t:redirPreviewWinid = win_getid()
        wincmd p
    endif
    call win_execute(t:redirPreviewWinid, "call RgLocateTarget()")
endfunction

" imitate 'cNext'
function! RgNext()
    call RgShow("+")
endfunction

" imitate 'cprevious'
function! RgPre()
    call RgShow("-")
endfunction

function! RgFocusCurMatchWhenTabEnter()
    if bufwinnr(bufnr('^RipgrepWordSearch'.tabpagenr()))==-1
        hi clear RgFocusCurMatch
    else
        hi RgFocusCurMatch ctermfg=lightgreen ctermbg=darkgray cterm=bold
    endif
endfunction

" autocmd to jump to file with CR only in RipgrepWordSearch buffer
function! RgJumpMap()
    nnoremap <buffer><silent><CR> <cmd>call RgJump(getline('.'))<CR>
    nnoremap <buffer><silent>j <cmd>call RgNext()<CR>
    nnoremap <buffer><silent>k <cmd>call RgPre()<CR>
endfunction

augroup ripgrepWordSearch
    autocmd!
    autocmd BufWinLeave RipgrepWordSearch* silent! hi clear RgFocusCurMatch 
    autocmd BufEnter RipgrepWordSearch* silent! hi RgFocusCurMatch ctermfg=lightgreen ctermbg=darkgray cterm=bold
    autocmd TabEnter * call RgFocusCurMatchWhenTabEnter()
augroup END

command! -nargs=1 -complete=command RgRedir silent! call RgRedir(<q-args>)

" Wg means 'word git', search file fuzzily names with git
command! -nargs=1 -complete=command Wg silent! call RgWithGit(<q-args>)

" Ws means 'word search', search file fuzzily names without git
command! -nargs=1 -complete=command Ws silent! call RgWithoutGit(<q-args>)

