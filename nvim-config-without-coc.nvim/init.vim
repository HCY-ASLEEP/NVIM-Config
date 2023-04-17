" hovel settings -----------------------------------------------------------------------------------
" show line number
set number

" only support command mode, no click
set mouse=c

" tab settings
set tabstop=4
set shiftwidth=4
set softtabstop=4

" let tap become four spaces
set expandtab

" autoindent
set autoindent

" highlight search
set hlsearch

" foldmethod
set foldmethod=syntax
set nofoldenable

" auto sync 
set autoread


" disable error bells
set noerrorbells 
set novisualbell

" set double key separation time
set timeoutlen=200

" jump to the last position when reopening a file
" ! You must mkdir viewdir first !
set viewdir=~/.vimviews/
augroup keepBufView
    autocmd!
    autocmd BufWinLeave *.* mkview
    autocmd BufWinEnter *.* silent! loadview 
augroup END

" visual block short-cut
nnoremap vv <C-v>

" paste in command mod
cnoremap <C-v> <C-r>"

" show current buffer path
cnoreabbrev fd echo expand("%:p:h")

cnoreabbrev vt vs \| term
cnoreabbrev st sp \| term

" buffer vertical split
cnoreabbrev vb vertical<SPACE>sb


" auto pair ---------------------------------------------------------------------------------------
inoremap { {}<LEFT>
inoremap ( ()<LEFT>
inoremap [ []<LEFT>
inoremap ' ''<LEFT>
inoremap " ""<LEFT>
inoremap ` ``<LEFT>

" {} and ()completion when press enter in the middle of them
function! InsertCRBrace()
    call feedkeys("\<BS>",'n')
    let l:frontChar = getline('.')[col('.') - 2]
    if l:frontChar == "{" || l:frontChar == "("
        call feedkeys("\<CR>\<ESC>\O", 'n')
    else
        call feedkeys("\<CR>", 'n')
    endif
endfunction
inoremap <expr> <CR> InsertCRBrace()


" map ;; to esc -----------------------------------------------------------------------------------
function! ESC_IMAP()
    " If the char in front the cursor is ";"
    if getline('.')[col('.') - 2]== ";" 
        call feedkeys("\<BS>\<BS>\<ESC>", 'n')
    else
        call feedkeys("\<BS>\;", 'n')
    endif
endfunction
inoremap <expr> ; ESC_IMAP()

vnoremap ;; <ESC>
snoremap ;; <ESC>
xnoremap ;; <ESC>
cnoremap ;; <ESC>
onoremap ;; <ESC>

" exit windows
tnoremap ;; <C-\><C-n>

" internal terminal settings
augroup internal_terminal
    autocmd!
    autocmd TermOpen * set nonumber norelativenumber
augroup END

" switch windows -----------------------------------------------------------------------------------
nnoremap <silent><TAB> :wincmd w<CR>


" wild* settings -----------------------------------------------------------------------------------
set wildcharm=<TAB>
cnoremap <expr> <up> wildmenumode() ? "\<left>" : "\<up>"
cnoremap <expr> <down> wildmenumode() ? "\<right>" : "\<down>"


" netrw settings -----------------------------------------------------------------------------------
" not show the help banner on top 
let g:netrw_banner = 0

" make explorer show files like a tree
let g:netrw_liststyle = 3

" see help doc to know more about this global var
let g:netrw_browse_split = 4

" skip the netrw win when the netrw hidden
function! SkipNetrwWin()
    augroup skipNetrwWin
        autocmd!
        autocmd BufEnter NetrwTreeListing :wincmd w
    augroup END
endfunction

" open explorer by specific size
function! OpenExplorerOnSize(size)
    let t:win_width=a:size
    exec "botright "t:win_width."vsplit"
    exec "Explore"
endfunction

function! ToggleExplorer()
    let l:expl_win_num = bufwinnr(bufnr('NetrwTreeListing'))
    
    " if expl_win_num exists
    if l:expl_win_num != -1
        
        " if cursor is not in explorer
        if l:expl_win_num != winnr()
           let t:cur_work_win_num = winnr() 
        endif
        
        " if explorer is not hidden
        if winwidth(l:expl_win_num)!=0
            let t:win_width=0
            exec t:cur_work_win_num."wincmd w"
            call SkipNetrwWin()
        else
            let t:win_width=t:max_win_width
            
            " disable skip netrw win
            autocmd! skipNetrwWin
            exec l:expl_win_num."wincmd w"
        endif
        exec "vertical ".l:expl_win_num."resize ".t:win_width
    else 
        call OpenExplorerOnSize(t:max_win_width)            
    endif
endfunction

function! HideExplorer()
    let l:expl_win_num = bufwinnr(bufnr('NetrwTreeListing'))
    
    " if expl_win_num exists
    if l:expl_win_num != -1
        
        " if cursor is not in explorer
        if l:expl_win_num != winnr()
           let t:cur_work_win_num = winnr() 
        endif
        call SkipNetrwWin()
        exec "vertical ".l:expl_win_num."resize ".0
    endif
endfunction

nnoremap <silent>e :call ToggleExplorer()<CR>

function! ExploreWhenEnter()
    
    let l:expl_win_num = bufwinnr(bufnr('NetrwTreeListing'))
    
    " if expl_win_num not exists
    if l:expl_win_num == -1
    
        " explorer vertical split max win width
        let t:max_win_width=25
        
        " record the win num of workspace except explorer where cursor in
        let t:cur_work_win_num = winnr()
        call OpenExplorerOnSize(t:max_win_width)
        wincmd w
        
    endif
endfunction

augroup initExplore
    autocmd!
    autocmd TabEnter,VimEnter * call ExploreWhenEnter()
augroup END


" colorscheme settings ------------------------------------------------------------------------------
hi Normal ctermfg=white ctermbg=NONE cterm=NONE
hi Error ctermfg=darkyellow ctermbg=NONE cterm=NONE
hi Folded ctermfg=yellow ctermbg=darkgray cterm=NONE
hi LineNr ctermfg=darkgray ctermbg=NONE cterm=NONE
hi Comment ctermfg=darkgray ctermbg=NONE cterm=italic
hi Visual ctermfg=lightred ctermbg=darkgray cterm=NONE
hi VertSplit ctermfg=darkgray ctermbg=NONE cterm=NONE
set fillchars+=eob:\ 


" bottem statusline settings -----------------------------------------------------------------------
set statusline=%*\ %.50F\ %m\               " show filename and filepath
set statusline+=%=%l/%L:%c\ \ %*            " show the column and raw num where cursor in
set statusline+=%3p%%\ \                    " show proportion of the text in front of the cursor to the total text
set statusline+=%{&ff}\[%{&fenc}]\ %*       " show encoding type of file
set statusline+=\ %{strftime('%H:%M')}\ \   " show current time
set statusline+=[%{winnr()}]                " show winNum of current
hi Statusline ctermfg=lightyellow ctermbg=darkgray cterm=bold
hi StatuslineNC ctermfg=lightmagenta ctermbg=darkgray cterm=bold


" python special focus -----------------------------------------------------------------------------
augroup pythonSpecialFocus
    autocmd!
    autocmd Filetype python 
        \  set list
        \| set listchars=space:\ 
        \| set listchars+=multispace:···+
        \| hi SpecialKey ctermfg=darkblue ctermbg=NONE cterm=NONE
augroup END


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
    
        let l:s .= '%' . l:tab . 'T'
        let l:s .= (l:tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
        let l:s .= ' ' . l:tab .' '
        let l:s .= (l:bufname != '' ? '['. fnamemodify(l:bufname, ':t') . '] ' : '[No Name] ')
    
        if l:bufmodified
            let l:s .= '[+] '
        endif
    endfor
    
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
hi TabLineSel ctermfg=black ctermbg=white cterm=bold

nnoremap <silent><SPACE><TAB> :tabnext<CR>


" Simple tab completion -----------------------------------------------------------------------------
" A simple tab completion, if you use the coc.nvim, you should remove this simple completion
inoremap <expr> <Tab> getline('.')[col('.')-2] !~ '^\s\?$' \|\| pumvisible()
      \ ? '<C-N>' : '<Tab>'
inoremap <expr> <S-Tab> pumvisible() \|\| getline('.')[col('.')-2] !~ '^\s\?$'
      \ ? '<C-P>' : '<Tab>'

augroup SimpleComplete
    autocmd CmdwinEnter * inoremap <expr> <buffer> <Tab>
          \ getline('.')[col('.')-2] !~ '^\s\?$' \|\| pumvisible()
          \ ? '<C-X><C-V>' : '<Tab>'
augroup END

" When you use konsole, you may need this
hi Pmenu ctermfg=yellow
hi PmenuSel ctermbg=darkgray ctermfg=white


" vim-plug(4) ---------------------------------------------------------------------------------------
call plug#begin($HOME.'/.local/share/nvim/site/autoload')
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
call plug#end()


augroup MarkdownPreview
    autocmd!
    auto Filetype markdown source $HOME/.config/nvim/markdown.vim
augroup END


" Find key words in all files -----------------------------------------------------------------------
function! GlobalWordsSearchWithGit(substr)
    " :lvimgrep /substr/gj `git ls-files`
    noautocmd exec "lvimgrep /".a:substr."/gj `git ls-files`" | lw 
endfunction

" Gs means 'git search', search according .gitignore
command! -nargs=1 -complete=command Gs silent call GlobalWordsSearchWithGit(<q-args>)

function! GlobalWordsSearchWithoutGit(substr)
    " :lvimgrep /substr/gj **/*
    noautocmd exec "lvimgrep /".a:substr."/gj **/*" | lw 
endfunction

" Ws means 'word search', search without .gitignore
command! -nargs=1 -complete=command Ws silent call GlobalWordsSearchWithoutGit(<q-args>)

nnoremap <C-down> :lnext<CR>
nnoremap <C-up> :lprev<CR>


" Fuzzy Match filenames -----------------------------------------------------------------------------
" redirect the command output to a buffer
function! Redir(cmd)
	redir => output
	execute a:cmd
	redir END
	let output = split(output, "\n")
	enew
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
    file FuzzyFilenameSearchBuf
	call setline(1, output)
    exec "set cursorline"
endfunction

command! -nargs=1 -complete=command Redir silent call Redir(<q-args>)

" Show Files searched fuzzily
function! FuzzyFilenameSearch(substr)
    " :Redir !find searchRootPath -iname '*substr*'
    call feedkeys(":Redir !find ".getcwd()." -iname '*".a:substr."*'\<CR>" ,'n')
    call feedkeys("/".a:substr."\\c\<CR>")
endfunction

" Go to the file on line
function! JumpToFile()
    let l:path=getline('.')
    if filereadable(l:path)
        echo "SpecificFile exists"
        exec "edit ".l:path
    else
        echo "File loaded error, can not call JumpToFile"
    endif
endfunction

nnoremap <C-Space> :call JumpToFile()<CR>:set nocursorline<CR>:noh<CR>

" Fs means 'file search', search file names fuzzily
command! -nargs=1 -complete=command Fs silent call FuzzyFilenameSearch(<q-args>)

function! CdCurBufDir()
    exec "cd ".expand("%:p:h")    
    echo expand("%:p:h")
endfunction

" Cc means 'cd cur', cd cur buf dir
command! -nargs=1 -complete=command Cc silent call CdCurBufDir()