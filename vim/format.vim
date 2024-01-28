function! FormatCodes(formatCmd,formatArgs, position)
    if !executable(a:formatCmd) 
        echo ">>  "a:formatCmd. " formater not found"
        return
    endif
    write
    if a:position==0
        execute "% !".a:formatCmd." ".a:formatArgs
    else
        execute "!".a:formatCmd." ".a:formatArgs." %"   
    endif
    write
endfunction

augroup codeFormat
    autocmd!
    autocmd Filetype python command! -buffer Format silent! call FormatCodes('black','',1)
    autocmd Filetype c,cpp,objc,objcpp,cuda,proto command! -buffer Format silent! call FormatCodes('clang-format','-style="{IndentWidth: 4}"',0)
    autocmd Filetype lua command! -buffer Format silent! execute FormatCodes('stylua','--indent-width=4',1)
augroup END
