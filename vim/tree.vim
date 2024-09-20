let s:fullPaths = []
let s:fileTreeIndent = '    '
let s:closed = -1
let s:nodesCache = {}
let s:fullPathsCache = {}
let s:kidCountCache = {}
let s:minusKidCountOp = 0
let s:plusKidCountOp = 1
let s:topDirDepth = 0
let s:dirSeparator = '/'
let s:treeWinid = -1
let s:treeBufnr = -1

function! GetNodesAndFullPaths(path)
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

function! GetDirDepth(path)
    let l:upperDir = fnamemodify(a:path, ':h')
    if l:upperDir == a:path
        return 1
    endif
    return GetDirDepth(l:upperDir) + 1
endfunction

function! ChangeKidCount(path, n, depth, operate)
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
    call ChangeKidCount(l:upperDir, a:n, a:depth - 1, a:operate)
endfunction

function! AddIndents(startLine, endLine, indents)
    silent exec a:startLine . ',' . a:endLine . 's/^/' . a:indents .'/'
endfunction

function! RemoveIndents(startLine, endLine, endCol)
    if a:endCol == 0
        return
    endif
    exec a:startLine . "normal! 0"
    exec "normal! \<C-V>"
    exec a:endLine . "normal! " . a:endCol . "|"
    silent exec "normal! d"
endfunction

function! WriteNodes(lines, startLine, indents)
    if empty(a:lines)
        return
    endif
    call append(a:startLine, a:lines)
    let l:startLine = a:startLine + 1
    let l:endLine = a:startLine + len(a:lines)
    call AddIndents(l:startLine, l:endLine, a:indents)
endfunction

function! WriteCachedNodes(block, startLine, lineLength, indents)
    let l:startLine = a:startLine + 1
    let l:endLine = a:startLine + a:lineLength
    let @" = a:block
    silent exec "normal p"
    exec l:startLine . "normal! ^"
    call RemoveIndents(l:startLine, l:endLine, col('.') - 1)
    call AddIndents(l:startLine, l:endLine, a:indents)
endfunction

function! WriteFullPaths(fullPaths, startLine)
    if empty(a:fullPaths)
        return
    endif
    call extend(s:fullPaths, a:fullPaths, a:startLine)
endfunction

function! DeleteNodes(nodeId, startLine, endLine)
    silent exec a:startLine . "," . a:endLine . "delete"
    let s:nodesCache[a:nodeId] = @"
endfunction

function! DeleteFullPaths(nodeId, startLine, endLine)
    let s:fullPathsCache[a:nodeId] = remove(s:fullPaths, a:startLine, a:endLine)
endfunction

function! IsOpened()
    let l:curLine = line('.')
    let l:nodeId = s:fullPaths[l:curLine - 2]
    if !has_key(s:kidCountCache, l:nodeId)
        return s:closed
    endif
    let l:kidCount = s:kidCountCache[l:nodeId]
    if l:kidCount == 0
        return s:closed
    endif
    return  l:curLine + l:kidCount + 1
endfunction

function! OpenDir()
    normal ^
    let l:curLine = line('.')
    let l:curCol = col('.')
    let l:indents = repeat(s:fileTreeIndent, l:curCol / len(s:fileTreeIndent) + 1)
    " nodeId is the full path of the node under the cursor
    let l:nodeId = s:fullPaths[l:curLine - 2]
    let l:dirDepth = GetDirDepth(l:nodeId)
    if has_key(s:nodesCache, l:nodeId) || has_key(s:fullPathsCache, l:nodeId)
        let l:nodes = s:nodesCache[l:nodeId]
        let l:fullPaths = s:fullPathsCache[l:nodeId]
        let l:lineLength = len(l:fullPaths)
        call ChangeKidCount(l:nodeId, l:lineLength, l:dirDepth, s:plusKidCountOp)
        call WriteCachedNodes(l:nodes, l:curLine, l:lineLength, l:indents)
        call WriteFullPaths(l:fullPaths, l:curLine - 1)
        exec l:curLine . "normal! ^"
        return
    endif
    let l:nodesAndFullPaths = GetNodesAndFullPaths(l:nodeId)
    let l:nodes = l:nodesAndFullPaths[0]
    let l:fullPaths = l:nodesAndFullPaths[1]
    if len(l:nodes) == 0 || len(l:fullPaths) == 0
        echom ">> Empty folder!"
    endif
    let l:lineLength = len(l:nodes)
    call ChangeKidCount(l:nodeId, l:lineLength, l:dirDepth, s:plusKidCountOp)
    call WriteNodes(l:nodes, l:curLine, l:indents)
    call WriteFullPaths(l:fullPaths, l:curLine - 1)
    exec l:curLine . "normal! ^"
endfunction

function! CloseDir(nextPeerLine)
    let l:curLine = line('.')
    " nodeId is the full path of the node under the cursor
    let l:nodeId = s:fullPaths[l:curLine - 2]
    let l:dirDepth = GetDirDepth(l:nodeId)
    let l:kidCount = s:kidCountCache[l:nodeId]
    call ChangeKidCount(l:nodeId, l:kidCount, l:dirDepth, s:minusKidCountOp)
    call DeleteNodes(l:nodeId, l:curLine + 1, a:nextPeerLine - 1)
    call DeleteFullPaths(l:nodeId, l:curLine - 1, a:nextPeerLine - 3)
    exec l:curLine . "normal! ^"
endfunction

function! Upper()
    let l:curFullPath = getline(2)[:-2]
    let l:upperDir = fnamemodify(l:curFullPath, ':h')
    exec 2
    let l:status = IsOpened()
    if l:status == s:closed
        call InitTree(l:upperDir)
        exec 2
        return
    endif
    call CloseDir(l:status)
    call InitTree(l:upperDir)
    silent exec '/ '.fnamemodify(l:curFullPath, ':t').'\'.s:dirSeparator
    let @/ = ''
    call OpenDir()
    exec 2
endfunction

function! ClearAllCache()
    let s:nodesCache = {}
    let s:fullPathsCache = {}
    let s:kidCountCache = {}
endfunction

function! HighlightTree()
    syntax clear
    syntax match Directory ".*\/$"
    exec 'syntax match Directory ".*\' . s:dirSeparator . '$"'
endfunction

function! MapTree()
    nnoremap <buffer><silent> <CR> :call ToggleNode()<CR>
endfunction

function! InitTree(path)
    let s:topDirDepth = GetDirDepth(a:path)
    silent exec '%d'
    call HighlightTree()
    call setline(1, '..' . s:dirSeparator)
    if a:path == '/'
        call setline(2, a:path) 
    else
        call setline(2, a:path . s:dirSeparator) 
    endif
    let s:fullPaths = []
    call insert(s:fullPaths, a:path)
    exec 2
    call OpenDir()
endfunction

function! ToggleNode()
    let l:curLine = line('.')
    if l:curLine == 1
        call Upper()
        return
    endif
    let l:lineContent = getline(l:curLine)
    if l:lineContent[-1:] != s:dirSeparator
        echo "File, not dir!"
        return
    endif
    let l:status = IsOpened()
    if l:status == s:closed
        call OpenDir()
        return
    endif
    call CloseDir(l:status)
endfunction

function! ToggleTree()
    if s:treeBufnr == -1
        vnew
        call InitTree(getcwd())
        call MapTree()
        let s:treeBufnr = bufnr()
        let s:treeWinid = win_getid()
        return
    endif
    if s:treeWinid == -1
        vnew
        exec "buffer" . s:treeBufnr
        let s:treeWinid = win_getid()
        return
    endif
    call win_gotoid(s:treeWinid)
    if winnr() == 1
        vnew
    endif
    call win_gotoid(s:treeWinid)
    close
    let s:treeWinid = -1
endfunction

set splitright
