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

let t:redirPreviewWinnr = 1

function! OpenRedirWindow()
    if t:isRedirWinAlive 
        exec t:redirWinnr."wincmd w"
        return
    endif
    let t:isRedirWinAlive=1
    let t:redirPreviewWinnr = winnr()
    botright 10new
    let t:redirWinnr = winnr()
endfunction

function! QuitRedirWindow()
    if !t:isRedirWinAlive
        echo ">> No OpenRedirWindow!"
        return
    endif
    let t:isRedirWinAlive=0
    exec t:redirWinnr."close"
endfunction

nnoremap <silent><space>q <cmd>call QuitRedirWindow()<CR>

command! -nargs=1 -complete=command C call ChangeDir(<f-args>)

augroup redirWhenTabNew
    autocmd!
    autocmd TabNew * let t:rootDir=getcwd()
    autocmd TabNew * let t:isRedirWinAlive=0
augroup END

exec "source ".g:config_path."/vim/redir/buffer-list.vim"
exec "source ".g:config_path."/vim/redir/file-search.vim"
exec "source ".g:config_path."/vim/redir/word-search.vim"

