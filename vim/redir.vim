" set ripgrep root dir
let t:rootDir=getcwd()

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
    let l:findWinNum=bufwinnr(bufnr('^FuzzyFilenameSearch'.tabpagenr()))
    let l:rgWinNum=bufwinnr(bufnr('^RipgrepWordSearch'.tabpagenr()))
    let l:bufferListWinNum=bufwinnr(bufnr('^BufferList'.tabpagenr()))
    if l:findWinNum != -1
        exec l:findWinNum."wincmd w"
        enew
    elseif l:rgWinNum != -1
        exec l:rgWinNum."wincmd w"
        enew
    elseif l:bufferListWinNum !=-1
        exec l:bufferListWinNum."wincmd w"
        enew
    else
        let t:redirPreviewWinnr = winnr()
        botright 10new
    endif
endfunction

function! QuitRedirWindow()
    let l:findWinNum=bufwinnr(bufnr('^FuzzyFilenameSearch'.tabpagenr()))
    let l:rgWinNum=bufwinnr(bufnr('^RipgrepWordSearch'.tabpagenr()))
    let l:bufferListWinNum=bufwinnr(bufnr('^BufferList'.tabpagenr()))
    if l:findWinNum != -1
        exec l:findWinNum."close"
    elseif l:rgWinNum != -1
        exec l:rgWinNum."close"
    elseif l:bufferListWinNum !=-1
        exec l:bufferListWinNum."close"
    else
        echo ">> No OpenRedirWindow!"
    endif
endfunction

nnoremap <silent><space>q <cmd>call QuitRedirWindow()<CR>

command! -nargs=1 -complete=command C call ChangeDir(<f-args>)

augroup getRootDirWhenTabNew
    autocmd!
    autocmd TabNew * let t:rootDir=getcwd()
augroup END

exec "source ".g:config_path."/vim/redir/buffer-list.vim"
exec "source ".g:config_path."/vim/redir/file-search.vim"
exec "source ".g:config_path."/vim/redir/word-search.vim"

