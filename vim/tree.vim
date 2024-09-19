let s:fullPaths = []
let s:fileTreeIndent = '    '
let s:closed = -1

function! GetNodesAndFullPaths(path)
    let l:dirNodes = []
    let l:dirPaths = []
    let l:fileNodes = []
    let l:filePaths = []

    " 获取目录下的所有文件和文件夹
    let l:items = readdir(a:path)

    " 遍历每个项目，分类为文件或文件夹
    for l:item in l:items
        let l:fullPath = a:path . '/' . l:item
        if isdirectory(l:fullPath)
            call add(l:dirNodes, l:item.'/')
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
    " 获取当前列号
    let l:curCol = col('.')
    " 执行搜索
    exec '/' . '\%' . l:curCol . 'v\S'
    let l:peerLine = line('.')
    exec l:curLine
    return l:peerLine
endfunction

function! WriteNodes(lines, startLine, indents)
    if empty(a:lines)
        return
    endif
    call append(a:startLine, a:lines)
    let l:startLine = a:startLine + 1
    let l:endLine = a:startLine + len(a:lines)
    exec l:startLine . ',' . l:endLine . 's/^/' . a:indents .'/'
endfunction

function! WriteFullPaths(fullPaths, startLine)
    if empty(a:fullPaths)
        return
    endif
    call extend(s:fullPaths, a:fullPaths, a:startLine)
endfunction

function! DeleteNodes(startLine, endLine)
    exec a:startLine . "," . a:endLine . "delete"
endfunction

function! DeleteFullPaths(startLine, endLine)
    call remove(s:fullPaths, a:startLine, a:endLine)
endfunction

function! IsOpened()
    let l:curLine = line('.')
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
    return l:nextPeerLine
endfunction

function! OpenDir()
    normal ^
    let l:curLine = line('.')
    let l:curCol = col('.')
    let l:nodesAndFullPaths = GetNodesAndFullPaths(s:fullPaths[l:curLine - 2])
    let l:nodes = l:nodesAndFullPaths[0]
    let l:fullPaths = l:nodesAndFullPaths[1]
""    if len(l:nodes) == 0 || len(l:fullPaths) == 0
""        return
""    endif
    let l:indents = repeat(s:fileTreeIndent, l:curCol / len(s:fileTreeIndent) + 1)
    call WriteNodes(l:nodes, l:curLine, l:indents)
    call WriteFullPaths(l:fullPaths, l:curLine - 1)
    exec l:curLine
endfunction

function! CloseDir(nextPeerLine)
    let l:curLine = line('.')
    call DeleteNodes(l:curLine + 1, a:nextPeerLine - 1)
    call DeleteFullPaths(l:curLine - 1, a:nextPeerLine - 3)
    exec l:curLine
endfunction

function! Upper()
endfunction

function! InitTree(path)
    call setline(1, '../')
    call setline(2, a:path) 
    call insert(s:fullPaths, a:path)
endfunction

function! ToggleTree()
    if line('.') == 1
        call Upper()
    endif
    let l:status = IsOpened()
    if(l:status == s:closed)
        call OpenDir()
        return
    endif
    call CloseDir(l:status)
endfunction
    
function! ShowFullPaths()
    return s:fullPaths
endfunction
