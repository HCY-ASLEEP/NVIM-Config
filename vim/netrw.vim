" netrw settings -----------------------------------------------------------------------------------
" not show the help banner on top 
let g:netrw_banner = 0

" make explorer show files like a tree
let g:netrw_liststyle = 3

" see help doc to know more about this global var
let g:netrw_browse_split = 4

" explorer vertical split max win width
let g:max_explore_win_width=25

" skip the netrw win when the netrw hidden
function! SkipNetrwWin()
    augroup skipNetrwWin
        autocmd!
        autocmd BufEnter NetrwTreeListing wincmd w
    augroup END
endfunction

" open explorer by specific size
function! OpenExplorerOnSize(size)
    let t:win_width=a:size
    exec "Vexplore!"
    exec "vertical resize ".a:size
    setlocal winfixwidth
    return winnr()
endfunction

function! ToggleExplorer()
    let l:expl_win_num = bufwinnr(bufnr('NetrwTreeListing'))
    " handling the case where explorer takes up the entire window
    if l:expl_win_num == 1
        enew
        let l:expl_win_num = -1
    endif
    if l:expl_win_num==-1
        let t:cur_work_win_num = winnr()
        call OpenExplorerOnSize(g:max_explore_win_width)
        if exists('#skipNetrwWin#BufEnter')
            autocmd! skipNetrwWin
        endif
        return
    endif
    " if expl_win_num exists
    " if cursor is not in explorer
    if l:expl_win_num != winnr()
        let t:cur_work_win_num = winnr()
    endif
    " if explorer is not hidden
    if winwidth(l:expl_win_num)!=0
        let t:win_width=0
        exec t:cur_work_win_num."wincmd w"
        call SkipNetrwWin()
    else
        let t:win_width=g:max_explore_win_width
        " disable skip netrw win
        if exists('#skipNetrwWin#BufEnter')
            autocmd! skipNetrwWin
        endif
        exec l:expl_win_num."wincmd w"
    endif
    exec "vertical ".l:expl_win_num."resize ".t:win_width
endfunction

function! ExploreWhenEnter()
    if exists('#skipNetrwWin#BufEnter')
        autocmd! skipNetrwWin
    endif
    let l:expl_win_num = bufwinnr(bufnr('NetrwTreeListing'))
    " if expl_win_num not exists
    if l:expl_win_num == -1 || l:expl_win_num == 1
        " handling the case where explorer takes up the entire window
        if l:expl_win_num == 1
            enew
        endif
        " record the win num of workspace except explorer where cursor in
        let t:cur_work_win_num = winnr()
        let l:expl_win_num=OpenExplorerOnSize(g:max_explore_win_width)
        " handling the case where explorer not takes up the entire window
        exec t:cur_work_win_num."wincmd w"
        " hide the explorer
        exec "vertical ".l:expl_win_num."resize 0"
        call SkipNetrwWin()
        return
    endif
    if winwidth(l:expl_win_num)==0
        call SkipNetrwWin()
        return
    endif
    if exists('#skipNetrwWin#BufEnter')
        autocmd! skipNetrwWin
        return
    endif
endfunction

augroup initExplore
    autocmd!
    autocmd TabEnter,VimEnter * call ExploreWhenEnter()
augroup END

nnoremap <silent><SPACE>e <cmd>call ToggleExplorer()<CR>
