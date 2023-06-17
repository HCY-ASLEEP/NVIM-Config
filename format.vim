augroup codeFormat
    autocmd!
    autocmd Filetype python command! -buffer Format silent! execute "w | !black % | w"
    autocmd Filetype c,cpp,objc,objcpp,cuda,proto command! -buffer Format silent! execute "w | lua vim.lsp.buf.format()" | w
    autocmd Filetype lua command! -buffer Format silent! execute "w | !stylua % | w"
augroup END
