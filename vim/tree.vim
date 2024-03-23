" Constants {{{
function! s:define(name, value)
    let s:{a:name} = a:value
    lockvar s:{a:name}
endfunction

call s:define('EXCEPTION_NAME',   'ttree: ')
call s:define('BUFFER_NAME',      'ttree')
call s:define('FILE_NODE_MARKER', '-')
call s:define('CLOSE_DIR_MARKER', '+')
call s:define('OPEN_DIR_MARKER',  '-')
call s:define('UPPER',            '../')
call s:define('OFFSET',           0)
call s:define('EMPTY',            {})

call s:define('BOTTOM', '└─')
call s:define('MIDDLE', '├─')
call s:define('VERTICAL', '│ ')
call s:define('SPACE', ' ')

if has('win32') || has('win64') || has('win32unix')
    call s:define('DIR_SEPARATOR',    '\')
else
    call s:define('DIR_SEPARATOR',    '/')
endif

function! s:get_node_infos(path)
    let l:path=a:path
    if l:path[len(l:path)-1] != s:DIR_SEPARATOR
        let l:path=l:path.s:DIR_SEPARATOR
    endif
    
    let l:node_infos=[[],[],[],[]]

    let l:dir_hidden=0
    let l:dir_not_hidden=1
    let l:file_hidden=2
    let l:file_not_hidden=3
    
    let l:hiddens=glob('.*' ,0 ,1)
    let l:not_hiddens=glob('*', 0 ,1)
    
    for i in range(len(l:hiddens))
        let l:node=l:hiddens[i]
        let l:absolute_node=l:path.l:node
        if isdirectory(l:absolute_node)
            call add(l:node_infos[l:dir_hidden], l:node.s:DIR_SEPARATOR.' '.l:absolute_node)
        else
            call add(l:node_infos[l:file_hidden], l:node.' '.l:absolute_node)
        endif
    endfor
    
    for i in range(len(l:not_hiddens))
        let l:node=l:not_hiddens[i]
        let l:absolute_node=l:path.l:node
        if isdirectory(l:absolute_node)
            call add(l:node_infos[l:dir_hidden], l:node.s:DIR_SEPARATOR.' '.l:absolute_node)
        else
            call add(l:node_infos[l:file_hidden], l:node.' '.l:absolute_node)
        endif
    endfor

    return l:node_infos
endfunction

function! Write()
    let s:root_path=getcwd()
    let s:root_dir_name=split(s:root_path, s:DIR_SEPARATOR)[-1]
    
    let l:node_infos=s:get_node_infos(s:root_path)
    for n in l:node_infos
        call append(line('$'), n)
    endfor
    
    normal 2dd
    call append(1, s:root_dir_name.s:DIR_SEPARATOR.' '.s:root_path)
endfunction


"" 整个索引结构 s:dirIndexes
"" {
""      "top_dir":[
""          {
""              "displayed":9
""          },
""          {
""              "dir_1_1":[
""                  {    
""                      // 当前目录展示的总的节点个数，包括所有孩子目录展示的节点个数
""                      "displayed": 5
""                  },
""                  {   
""                      // 当前目录下已经被打开的子目录就会被加入到这个字典，注意这个字典可以为空
""                      // 因为有可能当前目录没有打开的子目录，但是有打开的子文件
""                      "dir_2_1":[
""                          {
""                              "displayed":4
""                          },
""                          {}
""                      ],
""                      ...
""                  }
""              ]
""          }
""      ]
""  }

"" s:absPathIndexes
"" 同时也要存储一个扁平的索引方便寻找每一行对应的绝对路径
"" [
""     abs_path_1,
""     abs_path_2,
""     ...
"" ]

"" 首先获取该目录下所有的文件和文件夹
"" 获取到的文件和文件夹是不分开的，所以要手动分开
"" 文件和文件夹统称为node
function! s:getNodesIn(dir)
    "" 使用 glob 函数获取隐藏的非隐藏节点
    "" hiddens , not_hiddens
    "" [[dirs],[files]]
    "" 使用 isdirectory 判断每个是否为目录，并加入到集合里面去 [[],[]]
    "" 由于 isdirectory 也需用绝对路径来判断，所以要先获取 absPath
    "" absPath=dir+'/'+node
    "" 同时将 absPath 加入到 list [] l:absPaths 里面
    return l:nodes,l:absPaths
endfunction

"" lineNr 是行数，nodes 是要写入的文件和目录名称，在 lineNr 这一行后面写入 nodes 
function! s:writeWith(lineNr,nodes)
    "" nodes 是一个 list 形式的文件节点列表
    "" 获取 lineNr 这一行的缩进 indent
    "" 先使用 append 将这些 nodes 插入到 lineNr 后面
    "" 然后推导出 indent+1 的样式
    "" 再把 indent+1 的样式通过 normal 命令和正则插入到 nodes 前面
    "" 避免使用 vimscript 拼接
endfunction

"" 打开目录
"" 传入目录所在的行数，知道了行数之后才方便后续插入
function! s:openDir(lineNr)
    let l:dir=s:absPaths[lineNr]
    let l:nodes=s:getNodesIn(a:dir)
    "" 统计 l:nodes 的行数
    "" 根据 s:dirIndexes 将行数一级一级地从上往下加到父目录里面，方便后续关闭目录
    "" 同时在 s:dirIndexes 里面加入这个目录
    "" 也在 s:absPaths 里面加入这个目录
    call s:writeWith(a:lineNr,l:nodes)
endfunction

"" 插入目录所在的行数
function! s:closeDir(lineNr)
    let l:dir=s:absPaths[lineNr]
    "" 获取当前的目录下面打开的节点总数，从 s:dirIndexes 里面获取
    "" 利用 normal 模式下的指令快速删除
    "" 删除 s:dirIndexes 和 s:absPaths 里面关于这个这个目录的索引
endfunction

function! s:openFile(lineNr)
endfunction

"" 打开上层目录
function! s:goUpper(lineNr)
    "" 改变工作目录
    "" 先把原来的目录索引和绝对路径索引，以及原来的这个全文存起来
    "" 构建上层的目录索引和绝对路径索引，深度为一
    "" 把原来的目录索引加到新的索引里面
    "" 使用 vimscript 的全文匹配函数定位到原来目录的位置
    "" 将原来的全文加到定位之后的位置
    "" 同时在新的上面追加原来的全文
endfunction
