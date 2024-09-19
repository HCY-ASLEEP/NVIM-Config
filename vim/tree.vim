let s:fullPaths = []
let s:fileTreeIndent = '    '
let s:closed = -1
let s:nodesCache = {}
let s:fullPathsCache = {}
let s:dirSeparator = '/'
let s:treeLoaded = 0

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

function! GetNextPeerLineNum()
    normal ^
    let l:curLine = line('.')
    let l:curCol = col('.')
    exec '/' . '\%' . l:curCol . 'v\S'
    let l:peerLine = line('.')
    exec l:curLine
    return l:peerLine
endfunction

function! GetNextEmptyCharLineNum()
    normal ^
    let l:curLine = line('.')
    let l:curCol = col('.')
    silent! exec '/' . '\%' . l:curCol . 'v$'
    let l:emptyCharLine = line('.')
    exec l:curLine
    return l:emptyCharLine
endfunction

function! AddIndents(startLine, endLine, indents)
    exec a:startLine . ',' . a:endLine . 's/^/' . a:indents .'/'
endfunction

function! RemoveIndents(startLine, endLine, endCol)
    if a:endCol == 0
        return
    endif
    exec a:startLine . "normal! 0"
    exec "normal! \<C-V>"
    exec a:endLine . "normal! " . a:endCol . "|"
    exec "normal! d"
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
    exec "normal p"
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
    exec a:startLine . "," . a:endLine . "delete"
    let s:nodesCache[a:nodeId] = @"
endfunction

function! DeleteFullPaths(nodeId, startLine, endLine)
    let s:fullPathsCache[a:nodeId] = remove(s:fullPaths, a:startLine, a:endLine)
endfunction

function! IsOpened()
    let l:curLine = line('.')
    let l:curCol = col('.')
    let l:nextPeerLine = GetNextPeerLineNum()
    let l:endLine = line('$')
    if l:curLine == l:endLine
        return s:closed
    endif
    if l:curLine + 1 == l:nextPeerLine
        return s:closed
    endif
    if l:nextPeerLine == 1
        return l:endLine + 1
    endif
    let l:emptyCharLine = GetNextEmptyCharLineNum()
    if l:emptyCharLine <= l:curLine
        return l:nextPeerLine
    endif
    if l:emptyCharLine < l:nextPeerLine
        let l:nextPeerLine = l:emptyCharLine
    endif
    if l:curLine + 1 == l:nextPeerLine 
        return s:closed
    endif
    return l:nextPeerLine
endfunction

function! OpenDir()
    normal ^
    let l:curLine = line('.')
    let l:curCol = col('.')
    let l:indents = repeat(s:fileTreeIndent, l:curCol / len(s:fileTreeIndent) + 1)
    " nodeId is the full path of the node under the cursor
    let l:nodeId = s:fullPaths[l:curLine - 2]
    if has_key(s:nodesCache, l:nodeId) || has_key(s:fullPathsCache, l:nodeId)
        let l:nodes = s:nodesCache[l:nodeId]
        let l:fullPaths = s:fullPathsCache[l:nodeId]
        let l:lineLength = len(l:fullPaths)
        call WriteCachedNodes(l:nodes, l:curLine, l:lineLength, l:indents)
        call WriteFullPaths(l:fullPaths, l:curLine - 1)
        exec l:curLine
        return
    endif
    let l:nodesAndFullPaths = GetNodesAndFullPaths(l:nodeId)
    let l:nodes = l:nodesAndFullPaths[0]
    let l:fullPaths = l:nodesAndFullPaths[1]
    if len(l:nodes) == 0 || len(l:fullPaths) == 0
        echo ">> Empty folder!"
    endif
    call WriteNodes(l:nodes, l:curLine, l:indents)
    call WriteFullPaths(l:fullPaths, l:curLine - 1)
    exec l:curLine
endfunction

function! CloseDir(nextPeerLine)
    let l:curLine = line('.')
    " nodeId is the full path of the node under the cursor
    let l:nodeId = s:fullPaths[l:curLine - 2]
    call DeleteNodes(l:nodeId, l:curLine + 1, a:nextPeerLine - 1)
    call DeleteFullPaths(l:nodeId, l:curLine - 1, a:nextPeerLine - 3)
    exec l:curLine
endfunction

function! Upper()
    let l:curFullPath = getline(2)[:-2]
    let l:upperDir = fnamemodify(l:curFullPath, ':h')
    exec 2
    let l:status = IsOpened()
    if l:status != s:closed
        call CloseDir(l:status)
    endif
    call InitTree(l:upperDir)
    exec '/ '.fnamemodify(l:curFullPath, ':t').'\'.s:dirSeparator
    let @/ = ''
    call OpenDir()
    exec 2
endfunction

function! ClearCache()
    let s:nodesCache = {}
    let s:fullPathsCache = {}
endfunction

function! HighlightTree()
    syntax clear
    syntax match Directory ".*\/$"
    execute 'syntax match Directory ".*\' . s:dirSeparator . '$"'
endfunction

function! MapTree()
    nnoremap <buffer> <CR> :silent! call ToggleNode()<CR>
endfunction

function! InitTree(path)
    exec '%d'
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
