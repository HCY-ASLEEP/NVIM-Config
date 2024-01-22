" colorscheme settings ------------------------------------------------------------------------------
hi Error ctermfg=darkyellow ctermbg=NONE cterm=NONE
hi LineNr ctermfg=darkgray ctermbg=NONE cterm=NONE
hi Comment ctermfg=darkgray ctermbg=NONE cterm=italic
hi Visual ctermfg=lightred ctermbg=darkgray cterm=NONE
hi VertSplit ctermfg=darkgray ctermbg=NONE cterm=NONE
hi CursorLine cterm=NONE
hi CursorLineNr ctermfg=black ctermbg=lightcyan cterm=bold
hi PmenuSel ctermfg=black ctermbg=lightred cterm=NONE
hi Pmenu ctermfg=black ctermbg=gray cterm=NONE
set fillchars+=eob:\ 
set fillchars+=vert:\│


" bottem statusline settings -----------------------------------------------------------------------
set statusline=%*\ %.50F\ %m\                " show filename and filepath
set statusline+=%=%l/%L\ \ %c\ \             " show the column and raw num where cursor in
set statusline+=%p%%\ \                      " show proportion of the text in front of the cursor to the total text
set statusline+=%{&ff}[%{&fenc}]\ \          " show encoding type of file
set statusline+=%{strftime('%H:%M')}\ \      " show current time
set statusline+=%{winnr()}\                   " show winNum of current
hi Statusline ctermfg=lightyellow ctermbg=darkgray cterm=bold
hi StatuslineNC ctermfg=lightmagenta ctermbg=darkgray cterm=bold


set list
set listchars=tab:┊\ ,eol:\ 
set listchars+=trail:\ 
set listchars+=leadmultispace:┊\ \ \ 


" tabline settings ---------------------------------------------------------------------------------
" tabline contents 
function! Tabline()
    let l:s = ''
    for i in range(tabpagenr('$'))
        let l:tab = i + 1
        let l:winnr = tabpagewinnr(l:tab)
        let l:buflist = tabpagebuflist(l:tab)
        let l:bufnr = l:buflist[l:winnr - 1]
        let l:bufname = bufname(l:bufnr)
        let l:bufmodified = getbufvar(l:bufnr, "&mod")
        " tabpage title settings
        let l:s .= '%' . l:tab . 'T'
        let l:s .= (l:tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
        let l:s .= ' ' . l:tab .' '
        let l:s .= (l:bufname != '' ? '['. fnamemodify(l:bufname, ':t') . '] ' : '[No Name] ')
        " modified flag
        if l:bufmodified
            let l:s .= '[+] '
        endif
    endfor
    " remove the close button
    let l:s .= '%#TabLineFill#'
    if (exists("g:tablineclosebutton"))
        let l:s .= '%=%999XX'
    endif
    return l:s
endfunction
set tabline=%!Tabline()

" tabline colorscheme
hi TabLine ctermfg=lightmagenta ctermbg=darkgray cterm=bold
hi TabLineFill ctermfg=NONE ctermbg=darkgray cterm=bold
hi TabLineSel ctermfg=lightyellow ctermbg=darkgray cterm=bold

hi FocusReturn ctermfg=lightblue ctermbg=NONE cterm=italic,bold
augroup focusReturn
    autocmd!
    autocmd BufEnter * call matchadd("FocusReturn",'\<return\>')
augroup END
