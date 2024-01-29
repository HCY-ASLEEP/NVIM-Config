function! FormatCodes(formatCmd,formatArgs)
    if !executable(a:formatCmd) 
        echo ">>  "a:formatCmd. " formater not found"
        return
    endif
    execute "%!".a:formatCmd." ".a:formatArgs
endfunction

augroup codeFormat
    autocmd!
    autocmd Filetype python command! -buffer Format silent! call FormatCodes('autopep8','-')
    ""autocmd Filetype c,cpp,objc,objcpp,cuda,proto command! -buffer Format silent! call FormatCodes('clang-format','-style="{IndentWidth: 4}"')
    autocmd Filetype c,cpp,objc,objcpp,cuda,proto,cs,java command! -buffer Format silent! call FormatCodes('astyle','--style=google 2>/dev/null')
    autocmd Filetype lua command! -buffer Format silent! execute FormatCodes('stylua','- --indent-type Spaces --indent-width 4')
    autocmd Filetype yaml command! -buffer Format execute FormatCodes('yamlfmt','--formatter indent=4')
augroup END
