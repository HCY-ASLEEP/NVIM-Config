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
function! WordLocateTarget()
    try
        let l:location=s:LegalLocations()
        let l:path=l:location[0]
        let l:row=l:location[1]
        let l:column=l:location[2]
        exec "edit ".l:path
        cal cursor(l:row, l:column)
        call matchadd('WordFocusCurMatch', '\c\%#'.t:rgrepSubStr)
        normal! zz
    catch
        echo ">> File Not Exist!"
    endtry
endfunction

" redirect the command output to a buffer
function! WordRedir(cmd)
    call OpenRedirWindow()
    exec "edit RipgrepWordSearch".tabpagenr()."\ ->\ ".t:rgrepSubStr
    exec "read "a:cmd
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=redirWindows
    call WordJumpMap()
endfunction

" Show Words fuzzily searched with git
function! WordWithGit(substr)
    let t:rgrepSubStr=a:substr
    let l:rgArgs="--ignore-case --vimgrep --no-heading"
    exec "cd ".t:rootDir
    exec "WordRedir !rg ".l:rgArgs." ".a:substr." ".t:rootDir
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

" Show Files fuzzily searched without git
function! WordWithoutGit(substr)
    let t:rgrepSubStr=a:substr
    let l:rgArgs="--ignore-case --vimgrep --no-heading --no-ignore"
    exec "cd ".t:rootDir
    exec "WordRedir !rg ".l:rgArgs." ".a:substr." ".t:rootDir
    exec "normal! gg"
    if getline('.') == ""
        exec "normal! dd"
    endif
endfunction

function! WordFocusCurMatchWhenTabEnter()
    if bufwinnr(bufnr('^RipgrepWordSearch'.tabpagenr()))==-1
        hi clear WordFocusCurMatch
    else
        hi WordFocusCurMatch ctermfg=lightgreen ctermbg=darkgray cterm=bold
    endif
endfunction

" autocmd to jump to file with CR only in RipgrepWordSearch buffer
function! WordJumpMap()
    nnoremap <buffer><silent><CR> <cmd>call JumpWhenPressEnter(function('WordLocateTarget'))<CR>
    nnoremap <buffer><silent>j <cmd>call JumpWhenPressJOrK('+', 'WordLocateTarget')<CR>
    nnoremap <buffer><silent>k <cmd>call JumpWhenPressJOrK('-', 'WordLocateTarget')<CR>
endfunction

augroup ripgrepWordSearch
    autocmd!
    autocmd BufWinLeave RipgrepWordSearch* silent! hi clear WordFocusCurMatch 
    autocmd BufEnter RipgrepWordSearch* silent! hi WordFocusCurMatch ctermfg=lightgreen ctermbg=darkgray cterm=bold
    autocmd TabEnter * call WordFocusCurMatchWhenTabEnter()
augroup END

command! -nargs=1 -complete=command WordRedir silent! call WordRedir(<q-args>)

" Wg means 'word git', search file fuzzily names with git
command! -nargs=1 -complete=command Wg silent! call WordWithGit(<q-args>)

" Ws means 'word search', search file fuzzily names without git
command! -nargs=1 -complete=command Ws silent! call WordWithoutGit(<q-args>)
