let s:fullPaths = []
let s:fileTreeIndent = '    '
let s:closedDir = -1
let s:openedDir = 1
let s:nodesCache = {}
let s:fullPathsCache = {}
let s:kidCountCache = {}
let s:minusKidCountOp = 0
let s:plusKidCountOp = 1
let s:topDirDepth = 0
let s:dirSeparator = '/'
let s:treeWinid = -1
let s:treeBufnr = -1
let s:treePreWinid = -1
let s:treeBufname = "Tree explorer for files and dirs"
let s:treeUnamedReg = ""
let s:treeSearchReg = ""

function! s:GetNodesAndFullPaths(path)
    let l:dirNodes = []
    let l:dirPaths = []
    let l:fileNodes = []
    let l:filePaths = []
    let l:items = readdir(a:path)
    let l:path = (a:path == '/') ? '' : a:path
    for l:item in l:items
        let l:fullPath = l:path . s:dirSeparator . l:item
        if isdirectory(l:fullPath)
            call add(l:dirNodes, l:item . s:dirSeparator)
            call add(l:dirPaths, l:fullPath)
        else
            call add(l:fileNodes, l:item)
            call add(l:filePaths, l:fullPath)
        endif
    endfor
    return [l:dirNodes + l:fileNodes, l:dirPaths + l:filePaths]
endfunction

function! s:GetFullPath(lineNum)
    return s:fullPaths[a:lineNum - 2]
endfunction

function! s:GetFullPathsCache(path)
    return s:fullPathsCache[a:path]
endfunction

function! s:IsInFullPathsCache(path)
    return has_key(s:fullPathsCache, a:path)
endfunction

function! s:GetDirDepth(path)
    let l:upperDir = fnamemodify(a:path, ':h')
    if l:upperDir == a:path
        return 1
    endif
    return s:GetDirDepth(l:upperDir) + 1
endfunction

function! s:GetNodesCache(path)
    return s:nodesCache[a:path]
endfunction

function! s:IsInNodesCache(path)
    return has_key(s:nodesCache, a:path)
endfunction

function! s:ClearCache(path)
    call remove(s:nodesCache, a:path)
    call remove(s:fullPathsCache, a:path)
    call remove(s:kidCountCache, a:path)
endfunction

function! s:ChangeKidCount(path, n, depth, operate)
    if a:depth < s:topDirDepth 
        return 
    endif
    if !has_key(s:kidCountCache, a:path)
        let s:kidCountCache[a:path] = 0
    endif
    if a:operate == s:minusKidCountOp
        let s:kidCountCache[a:path] -= a:n
    else
        let s:kidCountCache[a:path] += a:n
    endif
    let l:upperDir = fnamemodify(a:path, ':h')
    call s:ChangeKidCount(l:upperDir, a:n, a:depth - 1, a:operate)
endfunction

function! s:ZeroKidCount(path)
    let s:kidCountCache[a:path] = 0
endfunction

function! s:GetKidCount(path)
    return s:kidCountCache[a:path]
endfunction

function! s:AddIndents(startLine, endLine, indents)
    silent exec a:startLine . ',' . a:endLine . 's/^/' . a:indents .'/'
endfunction

function! s:RemoveIndents(startLine, endLine, endCol)
    if a:endCol == 0
        return
    endif
    exec a:startLine . "normal! 0"
    exec "normal! \<C-V>"
    exec a:endLine . "normal! " . a:endCol . "|"
    silent exec "normal! d"
endfunction

function! s:WriteNodes(lines, startLine, indents)
    if empty(a:lines)
        return
    endif
    call append(a:startLine, a:lines)
    let l:startLine = a:startLine + 1
    let l:endLine = a:startLine + len(a:lines)
    call s:AddIndents(l:startLine, l:endLine, a:indents)
endfunction

function! s:WriteCachedNodes(block, startLine, lineLength, indents)
    let l:startLine = a:startLine + 1
    let l:endLine = a:startLine + a:lineLength
    let @" = a:block
    silent exec "normal p"
    exec l:startLine . "normal! ^"
    call s:RemoveIndents(l:startLine, l:endLine, col('.') - 1)
    call s:AddIndents(l:startLine, l:endLine, a:indents)
endfunction

function! s:WriteFullPaths(fullPaths, startLine)
    if empty(a:fullPaths)
        return
    endif
    call extend(s:fullPaths, a:fullPaths, a:startLine)
endfunction

function! s:DeleteNodes(nodeId, startLine, endLine)
    silent exec a:startLine . "," . a:endLine . "delete"
    let s:nodesCache[a:nodeId] = @"
endfunction

function! s:DeleteFullPaths(nodeId, startLine, endLine)
    let s:fullPathsCache[a:nodeId] = remove(s:fullPaths, a:startLine, a:endLine)
endfunction

function! s:IsOpenedDir()
    let l:curLine = line('.')
    if l:curLine == line('$')
        return s:closedDir
    endif
    exec l:curLine . "normal! ^"
    let l:curInentCharNum = col('.')
    let l:nextLine = l:curLine + 1
    exec l:nextLine . "normal! ^"
    let l:nextInentCharNum = col('.')
    exec l:curLine . "normal! ^"
    if(l:curInentCharNum < l:nextInentCharNum)
        return s:openedDir
    endif
    return s:closedDir
endfunction

function! s:OpenDir()
    normal ^
    let l:curLine = line('.')
    let l:curCol = col('.')
    let l:indents = repeat(s:fileTreeIndent, l:curCol / len(s:fileTreeIndent) + 1)
    " nodeId is the full path of the node under the cursor
    let l:nodeId = s:GetFullPath(l:curLine)
    let l:dirDepth = s:GetDirDepth(l:nodeId)
    if s:IsInNodesCache(l:nodeId) || s:IsInFullPathsCache(l:nodeId)
        setlocal modifiable
        let l:nodes = s:GetNodesCache(l:nodeId)
        let l:fullPaths = s:GetFullPathsCache(l:nodeId)
        let l:kidCount = len(l:fullPaths)
        call s:ZeroKidCount(l:nodeId)
        call s:ChangeKidCount(l:nodeId, l:kidCount, l:dirDepth, s:plusKidCountOp)
        call s:WriteCachedNodes(l:nodes, l:curLine, l:kidCount, l:indents)
        call s:WriteFullPaths(l:fullPaths, l:curLine - 1)
        exec l:curLine . "normal! ^"
        setlocal nomodifiable
        return
    endif
    let l:nodesAndFullPaths = s:GetNodesAndFullPaths(l:nodeId)
    let l:nodes = l:nodesAndFullPaths[0]
    let l:fullPaths = l:nodesAndFullPaths[1]
    if len(l:nodes) == 0 || len(l:fullPaths) == 0
        echo ">> Empty folder!"
        return
    endif
    setlocal modifiable
    let l:kidCount = len(l:nodes)
    call s:ChangeKidCount(l:nodeId, l:kidCount, l:dirDepth, s:plusKidCountOp)
    call s:WriteNodes(l:nodes, l:curLine, l:indents)
    call s:WriteFullPaths(l:fullPaths, l:curLine - 1)
    exec l:curLine . "normal! ^"
    setlocal nomodifiable
endfunction

function! s:CloseDir()
    setlocal modifiable
    let l:curLine = line('.')
    " nodeId is the full path of the node under the cursor
    let l:nodeId = s:GetFullPath(l:curLine)
    let l:dirDepth = s:GetDirDepth(l:nodeId)
    let l:kidCount = s:GetKidCount(l:nodeId)
    let l:startLine = l:curLine + 1
    let l:endLine = l:curLine + l:kidCount
    call s:ChangeKidCount(l:nodeId, l:kidCount, l:dirDepth, s:minusKidCountOp)
    call s:DeleteNodes(l:nodeId, l:startLine, l:endLine)
    call s:DeleteFullPaths(l:nodeId, l:startLine - 2, l:endLine - 2)
    exec l:curLine . "normal! ^"
    setlocal nomodifiable
endfunction

function! s:OpenFile()
    let l:curLine = line('.')
    let l:nodeId = s:GetFullPath(l:curLine)
    if !filereadable(expand(l:nodeId))
        echo ">> File not exists!"
        return
    endif
    let l:curWinid = win_getid()
    if win_id2tabwin(s:treePreWinid)[1] == 0
        vnew 
        exec "edit ".l:nodeId
        echo l:nodeId
        return
    endif
    call win_gotoid(s:treePreWinid)
    if expand(bufname()) ==# l:nodeId
        return
    endif
    exec "edit ".l:nodeId
    echo l:nodeId
endfunction

function! s:Upper()
    let l:curFullPath = getline(2)[:-2]
    let l:upperDir = fnamemodify(l:curFullPath, ':h')
    if l:curFullPath == l:upperDir
        return
    endif
    exec 2
    if s:IsOpenedDir() == s:closedDir
        call s:InitTree(l:upperDir)
        exec 2
        return
    endif
    call s:CloseDir()
    call s:InitTree(l:upperDir)
    silent exec '/ '.fnamemodify(l:curFullPath, ':t').'\'.s:dirSeparator
    let @/ = ''
    call s:OpenDir()
    exec 2
endfunction

function! s:RefreshDir()
    let l:curLine = line('.')
    if l:curLine == 1
        call s:Upper()
    endif
    let l:nodeId = s:fullPaths[l:curLine - 2]
    if !isdirectory(l:nodeId)
        echo ">> Can not refresh a file, but a dir!"
        return
    endif
    if s:IsOpenedDir() == s:openedDir
        call s:CloseDir()
    endif
    call s:ClearCache(l:nodeId)
    call s:OpenDir()
endfunction

function! s:ClearAllCache()
    let s:nodesCache = {}
    let s:fullPathsCache = {}
    let s:kidCountCache = {}
endfunction

function! s:HighlightTree()
    syntax clear
    syntax match Directory ".*\/$"
    exec 'syntax match Directory ".*\' . s:dirSeparator . '$"'
endfunction

function! s:MapTree()
    nnoremap <buffer><silent> <CR> :call <SID>ToggleNode()<CR>
    nnoremap <buffer><silent> r :call <SID>RefreshDir()<CR>
endfunction

function! s:BeforeEnterTree()
    let s:treeSearchReg = @/
    let s:treeUnamedReg = @"
endfunction

function! s:AfterLeaveTree()
    let @/ = s:treeSearchReg
    let @" = s:treeUnamedReg
endfunction

function! s:SetTreeOptions()
    setlocal buftype=nofile bufhidden=hide nobuflisted noswapfile
    setlocal autoread
    exec "file ".s:treeBufname
    augroup switchContext
        autocmd!
        autocmd BufEnter <buffer> call s:BeforeEnterTree()
        autocmd BufLeave <buffer> call s:AfterLeaveTree()
    augroup END
endfunction

function! s:InitTree(path)
    setlocal modifiable
    let s:topDirDepth = s:GetDirDepth(a:path)
    silent exec '%d'
    call s:HighlightTree()
    call setline(1, '..' . s:dirSeparator)
    if a:path == '/'
        call setline(2, a:path) 
    else
        call setline(2, a:path . s:dirSeparator) 
    endif
    let s:fullPaths = []
    call insert(s:fullPaths, a:path)
    exec 2
    call s:OpenDir()
    setlocal nomodifiable
endfunction

function! s:ToggleNode()
    let l:curLine = line('.')
    if l:curLine == 1
        call s:Upper()
        return
    endif
    let l:lineContent = getline(l:curLine)
    if l:lineContent[-1:] != s:dirSeparator
        call s:OpenFile()
        return
    endif
    if s:IsOpenedDir() == s:closedDir
        call s:OpenDir()
        return
    endif
    call s:CloseDir()
endfunction

function! s:ToggleTree()
    let s:treePreWinid = win_getid()
    if s:treeBufnr == -1
        vnew
        call s:BeforeEnterTree()
        call s:InitTree(getcwd())
        call s:MapTree()
        call s:SetTreeOptions()
        let s:treeBufnr = bufnr()
        let s:treeWinid = win_getid()
        return
    endif
    if s:treeWinid == -1
        vnew
        exec "buffer ".s:treeBufname
        let s:treeWinid = win_getid()
        return
    endif
    call win_gotoid(s:treeWinid)
    close
    let s:treeWinid = -1
endfunction

set splitright
nnoremap <silent> <Space>e :call <SID>ToggleTree()<CR>
