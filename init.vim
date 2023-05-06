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
cnoremap <expr> <left> wildmenumode() ? "\<SPACE>\<BS>" : "\<left>"
cnoremap <expr> <right> wildmenumode() ? "\<SPACE>\<BS>" : "\<right>"


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

    let l:enewFlag = 0
    if l:expl_win_num == 1
        enew
        let l:expl_win_num = -1
        let l:enewFlag = 1
    endif

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
        if l:enewFlag == 1
            wincmd w
        endif
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

nnoremap <silent><S-TAB> :tabnext<CR>


" Find key words in all files -----------------------------------------------------------------------
function! GlobalWordsSearchWithGit(substr)
    " :lvimgrep /substr/gj `git ls-files`
    noautocmd exec "lvimgrep /".a:substr."\\c/gj `git ls-files`" | lw 
endfunction

function! GlobalWordsSearchWithoutGit(substr)
    " :lvimgrep /substr/gj **/*
    noautocmd exec "lvimgrep /".a:substr."\\c/gj **/*" | lw 
endfunction

" Wg means 'word git', search words according .gitignore
command! -nargs=1 -complete=command Wg silent call GlobalWordsSearchWithGit(<q-args>)

" Ws means 'word search', search words without .gitignore
command! -nargs=1 -complete=command Ws silent call GlobalWordsSearchWithoutGit(<q-args>)

nnoremap <silent>J :lnext<CR>
nnoremap <silent>K :lprev<CR>

" After hit enter, let cursor stay in quickfix window
augroup StayInQF
    autocmd!
    autocmd FileType qf nnoremap <buffer> <CR> <CR><C-W>p
augroup END


" Fuzzy Match filenames -----------------------------------------------------------------------------
" Go to the file on line
function! JumpToFile()
    let l:path=getline('.')
    if filereadable(l:path)
        echo "SpecificFile exists"
        exec "edit ".l:path
    elseif isdirectory(l:path)
        call feedkeys(":Redir !ls -ad ".l:path."/*\<CR>" ,'n')
        call feedkeys("\<down>\<down>" ,'n')
    else
        echo "File loaded error, can not call JumpToFile"
    endif
endfunction

" autocmd to jump to file with CR
function! JumpToFileWithCR()
    augroup jumpToFileWithCR
        autocmd!
        autocmd BufEnter FuzzyFilenameSearch silent! nnoremap <CR> :call JumpToFile()<CR>
        autocmd BufLeave FuzzyFilenameSearch silent! unmap <CR>
        autocmd BufEnter FuzzyFilenameSearch silent! set cursorline
        autocmd BufLeave FuzzyFilenameSearch silent! set nocursorline
        autocmd BufLeave FuzzyFilenameSearch silent! call feedkeys(":nohlsearch\<CR>",'n')
    augroup END
endfunction

" redirect the command output to a buffer
function! Redir(cmd)
    call JumpToFileWithCR()
    edit FuzzyFilenameSearch
    let t:redirOutput = ""
    redir => t:redirOutput
    execute a:cmd
    redir END
    let t:redirOutput = split(t:redirOutput, "\n")
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
    call setline(1, t:redirOutput)
endfunction

function! CdCurBufDir()
    exec "cd ".expand("%:p:h")    
    echo expand("%:p:h")
endfunction

command! -nargs=1 -complete=command Redir silent call Redir(<q-args>)

" Show Files searched fuzzily with git
function! FuzzyFilenameSearchWithGit(substr)
    " :Redir !find $(git ls-files) -iname '*substr*'
    call feedkeys(":Redir !find $(git ls-files) -iname '*".a:substr."*'\<CR>" ,'n')
    call feedkeys("/".a:substr."\\c\<CR>" ,'n')
    call feedkeys("\<down>\<down>" ,'n')
endfunction

" Show Files searched fuzzily without git
function! FuzzyFilenameSearchWithoutGit(substr)
    " :Redir !find searchRootPath -iname '*substr*'
    call feedkeys(":Redir !find ".getcwd()." -iname '*".a:substr."*'\<CR>" ,'n')
    call feedkeys("/".a:substr."\\c\<CR>" ,'n')
    call feedkeys("\<down>\<down>", 'n')
endfunction

" Fg means 'file git', search file names fuzzily with git
command! -nargs=1 -complete=command Fg silent call FuzzyFilenameSearchWithGit(<q-args>)

" Fs means 'file search', search file names fuzzily
command! -nargs=1 -complete=command Fs silent call FuzzyFilenameSearchWithoutGit(<q-args>)

" Cc means 'cd cur', cd cur buf dir
command! -nargs=1 -complete=command Cc silent call CdCurBufDir()


" vim-plug(4) ---------------------------------------------------------------------------------------
call plug#begin($HOME.'/.local/share/nvim/site/autoload')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-fugitive'
" It needs ripgrep to exec ':Leaderf rg'
" Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
call plug#end()


augroup MarkdownPreview
    autocmd!
    auto Filetype markdown source $HOME/.config/nvim/markdown.vim
augroup END


" " LeaderF settings ---------------------------------------------------------------------------------
" " let g:Lf_WindowPosition = 'popup'
" let g:Lf_ShowDevIcons = 0
" let g:Lf_PreviewResult = {'Function': 1, 'BufTag': 1, 'Rg': 1, 'File': 1, 'Mru': 1, 'Colorscheme': 1 }


" coc settings -------------------------------------------------------------------------------------
inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#next(1) :"\<Tab>" 
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

nmap gd <Plug>(coc-definition)
nmap gt <Plug>(coc-type-definition)
nmap gi <Plug>(coc-implementation)
nmap gr <Plug>(coc-references)

" Use K to show documentation in preview window.
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction
nnoremap <silent> K :call ShowDocumentation()<CR>

" Highlight the symbol and its references when holding the cursor.
autocmd! CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nnoremap <silent><space>r :call CocActionAsync('rename')<CR>

" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>

" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>

" Find symbol of current document.
nnoremap <silent><nowait> co  :call ToggleCocOutline()<cr>

function! ToggleCocOutline()
    let l:winid = coc#window#find('cocViewId', 'OUTLINE')
    if l:winid == -1
        exec "CocOutline"
    else
        call coc#window#close(l:winid)
        call HideExplorer()
    endif
endfunction

" setting CocInlayHint color
hi CocInlayHint ctermfg=darkblue ctermbg=NONE cterm=italic


