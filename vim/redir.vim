function! ChangeDir(path)
    if !isdirectory(expand(a:path))
        echo ">> Error Path!"
        return
    endif
    if a:path=="."
        let t:rootDir=expand("%:p:h")
        exec "cd ".t:rootDir
    else
        let t:rootDir=a:path
        exec "cd ".t:rootDir
    endif
    echo getcwd()
endfunction

function! GetBufNameBy(winid)
    let l:bufnr = winbufnr(a:winid)
    return bufname(l:bufnr)
endfunction

function! GetFiletypeBy(winid)
    let l:bufnr = winbufnr(a:winid)
    return getbufvar(l:bufnr, '&filetype')
endfunction

let t:redirPreviewWinid = win_getid()

function! OpenRedirWindow()
    let l:tabWinidList = gettabinfo(tabpagenr())[0]['windows']
    for l:winid in l:tabWinidList
        let l:winFileType=GetFiletypeBy(l:winid)
        if l:winFileType == 'redirWindows' || l:winFileType == 'qf'
            exec win_id2tabwin(l:winid)[1]."wincmd w"
            return
        endif
    endfor
    let t:redirPreviewWinid = win_getid()
    bot 10new
endfunction

function! QuitRedirWindow()
    let l:tabWinidList = gettabinfo(tabpagenr())[0]['windows']
    for l:winid in l:tabWinidList
        let l:winFileType=GetFiletypeBy(l:winid)
        if l:winFileType == 'redirWindows' || l:winFileType == 'qf'
            exec win_id2tabwin(l:winid)[1]."close"
            return
        endif
    endfor
    echo ">> No OpenRedirWindow!"
endfunction

function! JumpWhenPressEnter(locateTargetFunctionName)
    exec "cd ".t:rootDir
    let t:redirLocateTarget=getline('.')
    let l:redirPreviewWinnr = win_id2tabwin(t:redirPreviewWinid)[1]
    if l:redirPreviewWinnr <= 0
        new
        let t:redirPreviewWinid = win_getid()
    else
        exec l:redirPreviewWinnr."wincmd w"
    endif
    call function(a:locateTargetFunctionName)()
endfunction

function! JumpWhenPressJOrK(direction,locateTargetFunctionName)
    exec "cd ".t:rootDir
    exec "normal! ".a:direction
    let t:redirLocateTarget=getline('.')
    let l:redirPreviewWinnr = win_id2tabwin(t:redirPreviewWinid)[1]
    if l:redirPreviewWinnr <= 0
        top new
        let t:redirPreviewWinid = win_getid()
        wincmd p
    endif
    call win_execute(t:redirPreviewWinid, "call ".a:locateTargetFunctionName."()")
endfunction

nnoremap <silent><space>q <cmd>call QuitRedirWindow()<CR>

command! -nargs=1 -complete=command C call ChangeDir(<f-args>)

augroup redirWhenTabNew
    autocmd!
    autocmd VimEnter,TabNew * let t:rootDir=getcwd()
augroup END

exec "source ".g:config_path."/vim/redir/buffer-list.vim"
exec "source ".g:config_path."/vim/redir/file-search.vim"
exec "source ".g:config_path."/vim/redir/word-search.vim"

