function! HasFolds()
    let l:numLines = line('$')
    for l:lineNum in range(1, l:numLines)
        if foldclosed(l:lineNum) != -1
            return 1
        endif
    endfor
    return 0
endfunction

function! SearchFoldEpxr()
    if getline(v:lnum) =~ @/
        return 0
    elseif getline(v:lnum-1) =~ @/ || getline(v:lnum+1) =~ @/
        return 1
    else
        return 2
    endif
endfunction

" Folding according to search result
function! ToggleSearchFolding()
    if HasFolds()
        setlocal foldmethod=syntax foldcolumn=0
        exec "normal! zR"
    else
        setlocal foldexpr=SearchFoldEpxr() foldmethod=expr foldlevel=0 foldcolumn=2
        exec "normal! zM"
    endif
endfunction

nnoremap <silent><SPACE>z <cmd>call ToggleSearchFolding()<CR>

