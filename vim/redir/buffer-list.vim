" Go to the buffer on line
function! BufferListLocateTarget()
    let l:bufNum=split(t:bufferListLocateTarget,"\ ")[0]
    try
        exec "buffer".l:bufNum
    catch
        echo ">> Buffer Not Exist!"
    endtry
   
endfunction

function! BufferListJump(bufInfo)
    exec "cd ".t:rootDir
    let l:redirPreviewWinnr = win_id2tabwin(t:redirPreviewWinid)[1]
    if l:redirPreviewWinnr <= 0
        top new
        let t:redirPreviewWinid = win_getid()
    else
        exec l:redirPreviewWinnr."wincmd w"
    endif
    let t:bufferListLocateTarget=a:bufInfo
    call BufferListLocateTarget()
endfunction

" redirect the command output to a buffer
function! BufferListRedir()
    call OpenRedirWindow()
    exec "edit BufferList".tabpagenr()
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=redirWindows
    silent! put = execute('buffers')
    exec "normal! gg"
    let l:empty=2
    while empty > 0
        if getline('.') == ""
            exec "normal! dd"
        endif
        let l:empty-=1
    endwhile
    call BufferListJumpMap()
endfunction

" To show the buffer selected, underlying of BufferListNext, imitate 'cNext' command
function! BufferListShow(direction)
    exec "cd ".t:rootDir
    exec "normal! ".a:direction
    let t:bufferListLocateTarget=getline('.')
    let l:redirPreviewWinnr = win_id2tabwin(t:redirPreviewWinid)[1]
    if l:redirPreviewWinnr <= 0
        top new
        let t:redirPreviewWinid = win_getid()
        wincmd p
    endif
    call win_execute(t:redirPreviewWinid,"call BufferListLocateTarget()")
endfunction

" imitate 'cNext'
function! BufferListNext()
    call BufferListShow("+")
endfunction

" imitate 'cprevious'
function! BufferListPre()
    call BufferListShow("-")
endfunction

" autocmd to jump to buffer with CR only in BufferList buffer
function! BufferListJumpMap()
    nnoremap <buffer><silent><CR> <cmd>call BufferListJump(getline('.'))<CR>
    nnoremap <buffer><silent>j <cmd>call BufferListNext()<CR>
    nnoremap <buffer><silent>k <cmd>call BufferListPre()<CR>
endfunction

nnoremap <silent><space>l <cmd>call BufferListRedir()<CR>

