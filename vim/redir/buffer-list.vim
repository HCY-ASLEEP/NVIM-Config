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
    exec t:redirPreviewWinnr."wincmd w"
    let t:bufferListLocateTarget=a:bufInfo
    call BufferListLocateTarget()
endfunction

" redirect the command output to a buffer
function! BufferListRedir()
    call BufferListJumpMap()
    call OpenRedirWindow()
    exec "edit BufferList".tabpagenr()
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=BufferList
    silent! put = execute('buffers')
    exec "normal! gg"
    let l:empty=2
    while empty > 0
        if getline('.') == ""
            exec "normal! dd"
        endif
        let l:empty-=1
    endwhile
endfunction

" To show the buffer selected, underlying of BufferListNext, imitate 'cNext' command
function! BufferListShow(direction)
    exec "cd ".t:rootDir
    exec "normal! ".a:direction
    let l:redirPreviewWinId=win_getid(t:redirPreviewWinnr)
    let t:bufferListLocateTarget=getline('.')
    call win_execute(l:redirPreviewWinId,"call BufferListLocateTarget()")
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
    augroup BufferListJumpMap
        autocmd!
        autocmd FileType BufferList nnoremap <buffer><silent><CR> <cmd>call BufferListJump(getline('.'))<CR>
        autocmd FileType BufferList nnoremap <buffer><silent>j <cmd>call BufferListNext()<CR>
        autocmd FileType BufferList nnoremap <buffer><silent>k <cmd>call BufferListPre()<CR>
    augroup END
endfunction

nnoremap <silent><space>l <cmd>call BufferListRedir()<CR>

