augroup codeFormat
    autocmd!
    autocmd Filetype python command! -buffer Format silent! execute "w | !black % | w"
    autocmd Filetype c,cpp,objc,objcpp,cuda,proto command! -buffer Format silent! execute "w | % !clang-format -style=\"{IndentWidth: 4}\"" | w
    autocmd Filetype lua command! -buffer Format silent! execute "w | !stylua --indent-width=4 % | w"
augroup END
