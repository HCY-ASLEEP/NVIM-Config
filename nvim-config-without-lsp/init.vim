" vim-plug(4) ---------------------------------------------------------------------------------------
call plug#begin($HOME.'/.local/share/nvim/site/autoload')
call plug#end()

let g:config_path=expand("<sfile>:p:h")

exec "source ".g:config_path."/vim/autocomplete.vim"
exec "source ".g:config_path."/vim/format.vim"
exec "source ".g:config_path."/vim/netrw.vim"
exec "source ".g:config_path."/vim/redir.vim"
exec "source ".g:config_path."/vim/search-folding.vim"
exec "source ".g:config_path."/vim/sets-maps.vim"
exec "source ".g:config_path."/vim/ui.vim"

augroup MarkdownPreview
    auto Filetype markdown exec "source ".g:config_path."/vim/markdown.vim"
    autocmd!
augroup END
