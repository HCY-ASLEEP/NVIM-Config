" Go to the buffer on line
function! BufferListLocateTarget()
    let l:bufNum=split(t:redirLocateTarget,"\ ")[0]
    try
        exec "buffer".l:bufNum
    catch
        echo ">> Buffer Not Exist!"
    endtry
   
endfunction

" redirect the command output to a buffer
function! BufferListRedir()
    call OpenRedirWindow()
    exec "edit BufferList".tabpagenr()
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile cursorline filetype=redirWindows
    silent! put = execute('buffers')
    exec "normal! gg"
    while getline('.') == ""
        exec "normal! dd"
    endwhile
    call BufferListJumpMap()
endfunction

" autocmd to jump to buffer with CR only in BufferList buffer
function! BufferListJumpMap()
    nnoremap <buffer><silent><CR> <cmd>call JumpWhenPressEnter('BufferListLocateTarget')<CR>
    nnoremap <buffer><silent>j <cmd>call JumpWhenPressJOrK('+', 'BufferListLocateTarget')<CR>
    nnoremap <buffer><silent>k <cmd>call JumpWhenPressJOrK('-', 'BufferListLocateTarget')<CR>
endfunction

nnoremap <silent><space>l <cmd>call BufferListRedir()<CR>

