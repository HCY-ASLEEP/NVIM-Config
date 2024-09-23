let s:fullPaths = []
let s:fileTreeIndent = '    '
let s:dirClosed = -1
let s:dirOpened = 1
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

function! GetFullPath(lineNum)
    return s:fullPaths[a:lineNum - 2]
endfunction

function! GetFullPathsCache(path)
    return s:fullPathsCache[a:path]
endfunction

function! IsInFullPathsCache(path)
    return has_key(s:fullPathsCache, a:path)
endfunction

function! GetDirDepth(path)
    let l:upperDir = fnamemodify(a:path, ':h')
    if l:upperDir == a:path
        return 1
    endif
    return GetDirDepth(l:upperDir) + 1
endfunction

function! GetNodesCache(path)
    return s:nodesCache[a:path]
endfunction

function! IsInNodesCache(path)
    return has_key(s:nodesCache, a:path)
endfunction

function! ClearCache(path)
    call remove(s:nodesCache, a:path)
    call remove(s:fullPathsCache, a:path)
    call remove(s:kidCountCache, a:path)
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

function! ZeroKidCount(path)
    let s:kidCountCache[a:path] = 0
endfunction

function! GetKidCount(path)
    return s:kidCountCache[a:path]
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
    if l:curLine == line('$')
        return s:dirClosed
    endif
    exec l:curLine . "normal! ^"
    let l:curInentCharNum = col('.')
    let l:nextLine = l:curLine + 1
    exec l:nextLine . "normal! ^"
    let l:nextInentCharNum = col('.')
    exec l:curLine . "normal! ^"
    if(l:curInentCharNum < l:nextInentCharNum)
        return s:dirOpened
    endif
    return s:dirClosed
endfunction

function! OpenDir()
    normal ^
    let l:curLine = line('.')
    let l:curCol = col('.')
    let l:indents = repeat(s:fileTreeIndent, l:curCol / len(s:fileTreeIndent) + 1)
    " nodeId is the full path of the node under the cursor
    let l:nodeId = GetFullPath(l:curLine)
    let l:dirDepth = GetDirDepth(l:nodeId)
    if IsInNodesCache(l:nodeId) || IsInFullPathsCache(l:nodeId)
        let l:nodes = GetNodesCache(l:nodeId)
        let l:fullPaths = GetFullPathsCache(l:nodeId)
        let l:kidCount = len(l:fullPaths)
        call ZeroKidCount(l:nodeId)
        call ChangeKidCount(l:nodeId, l:kidCount, l:dirDepth, s:plusKidCountOp)
        call WriteCachedNodes(l:nodes, l:curLine, l:kidCount, l:indents)
        call WriteFullPaths(l:fullPaths, l:curLine - 1)
        exec l:curLine . "normal! ^"
        return
    endif
    let l:nodesAndFullPaths = GetNodesAndFullPaths(l:nodeId)
    let l:nodes = l:nodesAndFullPaths[0]
    let l:fullPaths = l:nodesAndFullPaths[1]
    if len(l:nodes) == 0 || len(l:fullPaths) == 0
        echo ">> Empty folder!"
        return
    endif
    let l:kidCount = len(l:nodes)
    call ChangeKidCount(l:nodeId, l:kidCount, l:dirDepth, s:plusKidCountOp)
    call WriteNodes(l:nodes, l:curLine, l:indents)
    call WriteFullPaths(l:fullPaths, l:curLine - 1)
    exec l:curLine . "normal! ^"
endfunction

function! CloseDir()
    let l:curLine = line('.')
    " nodeId is the full path of the node under the cursor
    let l:nodeId = GetFullPath(l:curLine)
    let l:dirDepth = GetDirDepth(l:nodeId)
    let l:kidCount = GetKidCount(l:nodeId)
    let l:startLine = l:curLine + 1
    let l:endLine = l:curLine + l:kidCount
    call ChangeKidCount(l:nodeId, l:kidCount, l:dirDepth, s:minusKidCountOp)
    call DeleteNodes(l:nodeId, l:startLine, l:endLine)
    call DeleteFullPaths(l:nodeId, l:startLine - 2, l:endLine - 2)
    exec l:curLine . "normal! ^"
endfunction

function! Upper()
    let l:curFullPath = getline(2)[:-2]
    let l:upperDir = fnamemodify(l:curFullPath, ':h')
    if l:curFullPath == l:upperDir
        return
    endif
    exec 2
    let l:status = IsOpened()
    if l:status == s:dirClosed
        call InitTree(l:upperDir)
        exec 2
        return
    endif
    call CloseDir()
    call InitTree(l:upperDir)
    silent exec '/ '.fnamemodify(l:curFullPath, ':t').'\'.s:dirSeparator
    let @/ = ''
    call OpenDir()
    exec 2
endfunction

function! RefreshDir()
    let l:curLine = line('.')
    if l:curLine == 1
        call Upper()
    endif
    let l:nodeId = s:fullPaths[l:curLine - 2]
    if !isdirectory(l:nodeId)
        echo ">> Can not refresh a file, but a dir!"
        return
    endif
    if IsOpened() == s:dirOpened
        call CloseDir()
    endif
    call ClearCache(l:nodeId)
    call OpenDir()
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
    if l:status == s:dirClosed
        call OpenDir()
        return
    endif
    call CloseDir()
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
