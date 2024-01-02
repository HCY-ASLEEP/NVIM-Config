set completeopt=menuone,noselect
" hide commplete info under the statusline
set shortmess+=c

function! OpenFilePathCompletion()
    if v:char =~ '[/]' && !pumvisible()
        call feedkeys("\<C-x>\<C-f>", "n")
    endif
endfunction

function! OpenNoLSPCompletion()
    if v:char =~ '[A-Za-z_]' && !pumvisible() 
        call feedkeys("\<C-n>", "n")
    endif
endfunction

augroup openFilePathCompletion
    autocmd!
    autocmd InsertCharPre * silent! call OpenFilePathCompletion()
augroup END

augroup openNoLSPCompletion
    autocmd!
    autocmd InsertCharPre * silent! call OpenNoLSPCompletion()
augroup END

inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

" use up and down keys for navigating the autocomplete menu
inoremap <expr> <down> pumvisible() ? "\<C-n>" : "\<down>"
inoremap <expr> <up> pumvisible() ? "\<C-p>" : "\<up>"
