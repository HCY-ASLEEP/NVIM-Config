" Go to the buffer on line
function! BufferListJump(bufInfo)
    exec "cd ".g:rootDir
    let l:bufNum=split(a:bufInfo,"\ ")[0]
    exec t:redirPreviewWinnr."wincmd w"
    try
        exec "buffer".l:bufNum
    catch
        echo ">> Buffer Not Exist!"
    endtry
endfunction

" autocmd to jump to buffer with CR only in BufferList buffer
function! BufferListJumpMap()
    augroup BufferListJumpMap
        autocmd!
        autocmd FileType BufferList nnoremap <buffer><silent><CR> <cmd>call BufferListJump(getline('.'))<CR>
    augroup END
    nnoremap <silent><S-down> <cmd>call BufferListNext()<CR>
    nnoremap <silent><S-up> <cmd>call BufferListPre()<CR>
endfunction

" redirect the command output to a buffer
function! BufferListRedir()
    call BufferListJumpMap()
    call OpenRedirWindow()
    exec "edit BufferList".tabpagenr()
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=BufferList
    put = execute('buffers')
    exec "normal! gg"
    let l:empty=2
    while empty > 0
        if getline('.') == ""
            exec "normal! dd"
        endif
        let l:empty-=1
    endwhile
endfunction

nnoremap <silent><space>l <cmd>call BufferListRedir()<CR>

" To show the buffer selected, underlying of BufferListNext, imitate 'cNext' command
function! BufferListShow(direction)
    let l:bufferListWinNum=bufwinnr(bufnr('^BufferList'.tabpagenr()))
    if l:bufferListWinNum==-1
        echo ">> No BufferList Buffer!"
    else
        if l:bufferListWinNum != t:redirPreviewWinnr
            let l:bufferListWinId=win_getid(l:bufferListWinNum)
            call win_execute(l:bufferListWinId, "normal! ".a:direction)
            call win_execute(l:bufferListWinId, "let t:bufferListPreviewInfo=getline('.')")
            call BufferListJump(t:bufferListPreviewInfo)
        else
            call BufferListJump(getline('.'))
        endif
    endif
endfunction

" imitate 'cNext'
function! BufferListNext()
    call BufferListShow("+")
endfunction

" imitate 'cprevious'
function! BufferListPre()
    call BufferListShow("-")
endfunction

