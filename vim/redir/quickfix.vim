function! PrepareForQuickfix()
    let l:cur_win_id=win_getid()
    if win_id2tabwin(t:redirWinid)[1] != 0 && t:redirWinid != l:cur_win_id
        call win_execute(t:redirWinid, 'close')
    end
    let t:redirPreviewWinid=win_getid(winnr('#'),tabpagenr())
    let t:redirWinid = l:cur_win_id
    resize 10
    setlocal bufhidden=wipe nobuflisted noswapfile nocursorline
endfunction

augroup quickFixPreparation
    autocmd!
    autocmd FileType qf call PrepareForQuickfix()
    autocmd FileType qf nnoremap <buffer> j j<CR>zz<C-w>p
    autocmd FileType qf nnoremap <buffer> k k<CR>zz<C-w>p
augroup END

