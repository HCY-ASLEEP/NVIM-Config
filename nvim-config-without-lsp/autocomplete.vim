set completeopt=menuone,noselect
" hide commplete info under the statusline
set shortmess+=c

function! OpenNoLSPCompletion()
    if v:char =~ '[A-Za-z_]' && !pumvisible() 
        call feedkeys("\<C-n>", "n")
    endif
endfunction

function! AutoComplete()
    augroup openNoLSPCompletion
        autocmd!
        autocmd InsertCharPre * silent! call OpenNoLSPCompletion()
    augroup END
endfunction

augroup initAutoComplete
    autocmd!
    autocmd BufWinEnter * call AutoComplete()
augroup END

" use tab for navigating the autocomplete menu
inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

" use up and down keys for navigating the autocomplete menu
inoremap <expr> <down> pumvisible() ? "\<C-n>" : "\<down>"
inoremap <expr> <up> pumvisible() ? "\<C-p>" : "\<up>"
