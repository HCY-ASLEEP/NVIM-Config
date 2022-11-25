set background=dark
hi clear

"" Copy of colorsheme koehler

hi Normal ctermfg=231 ctermbg=16 cterm=NONE
hi ColorColumn ctermfg=NONE ctermbg=88 cterm=NONE
hi CursorColumn ctermfg=NONE ctermbg=240 cterm=NONE
hi CursorLine ctermfg=NONE ctermbg=240 cterm=NONE
hi CursorLineNr ctermfg=226 ctermbg=NONE cterm=bold
hi Folded ctermfg=44 ctermbg=59 cterm=NONE
hi QuickFixLine ctermfg=16 ctermbg=226 cterm=NONE
hi Conceal ctermfg=254 ctermbg=145 cterm=NONE
hi Cursor ctermfg=16 ctermbg=46 cterm=NONE
hi Directory ctermfg=172 ctermbg=NONE cterm=NONE
hi ErrorMsg ctermfg=160 ctermbg=231 cterm=reverse
hi FoldColumn ctermfg=44 ctermbg=NONE cterm=NONE
hi MatchParen ctermfg=NONE ctermbg=21 cterm=NONE
hi MoreMsg ctermfg=29 ctermbg=NONE cterm=bold
hi NonText ctermfg=160 ctermbg=NONE cterm=bold
hi Pmenu ctermfg=231 ctermbg=238 cterm=NONE                                                                                                                   
hi PmenuSbar ctermfg=NONE ctermbg=NONE cterm=NONE                                                                                           
hi PmenuSel ctermfg=16 ctermbg=44 cterm=NONE
hi PmenuThumb ctermfg=NONE ctermbg=231 cterm=NONE
hi Question ctermfg=63 ctermbg=NONE cterm=bold
hi SignColumn ctermfg=51 ctermbg=NONE cterm=NONE
hi SpecialKey ctermfg=160 ctermbg=NONE cterm=NONE
hi SpellBad ctermfg=196 ctermbg=NONE cterm=underline
hi SpellCap ctermfg=83 ctermbg=NONE cterm=underline
hi SpellLocal ctermfg=51 ctermbg=NONE cterm=underline
hi SpellRare ctermfg=201 ctermbg=NONE cterm=underline
hi StatusLine ctermfg=21 ctermbg=231 cterm=bold
hi StatusLineNC ctermfg=21 ctermbg=254 cterm=NONE
hi TabLine ctermfg=21 ctermbg=231 cterm=bold
hi TabLineFill ctermfg=21 ctermbg=231 cterm=bold
hi TabLineSel ctermfg=231 ctermbg=21 cterm=bold
hi Title ctermfg=201 ctermbg=NONE cterm=bold
hi VertSplit ctermfg=21 ctermbg=254 cterm=NONE
hi Visual ctermfg=NONE ctermbg=59 cterm=reverse
hi VisualNOS ctermfg=NONE ctermbg=16 cterm=underline
hi WarningMsg ctermfg=196 ctermbg=NONE cterm=NONE
hi WildMenu ctermfg=16 ctermbg=226 cterm=NONE
hi Comment ctermfg=111 ctermbg=NONE cterm=NONE
hi Constant ctermfg=217 ctermbg=NONE cterm=NONE
hi Identifier ctermfg=87 ctermbg=NONE cterm=NONE
hi Ignore ctermfg=16 ctermbg=16 cterm=NONE
hi PreProc ctermfg=213 ctermbg=NONE cterm=NONE
hi Special ctermfg=214 ctermbg=NONE cterm=NONE
hi Statement ctermfg=227 ctermbg=NONE cterm=bold
hi Todo ctermfg=21 ctermbg=226 cterm=NONE
hi Type ctermfg=83 ctermbg=NONE cterm=bold
hi Underlined ctermfg=153 ctermbg=NONE cterm=underline
hi CursorIM ctermfg=NONE ctermbg=fg cterm=NONE
hi ToolbarLine ctermfg=NONE ctermbg=NONE cterm=NONE
hi ToolbarButton ctermfg=16 ctermbg=254 cterm=bold
hi DiffAdd ctermfg=231 ctermbg=65 cterm=NONE
hi DiffChange ctermfg=231 ctermbg=67 cterm=NONE
hi DiffText ctermfg=16 ctermbg=251 cterm=NONE
hi DiffDelete ctermfg=231 ctermbg=133 cterm=NONE


""supplements of koehler colorsheme
hi ModeMsg ctermfg=darkyellow ctermbg=NONE cterm=NONE
hi Error ctermfg=darkyellow ctermbg=NONE cterm=NONE
hi LineNr ctermfg=darkgray ctermbg=NONE cterm=NONE
hi EndOfBuffer ctermfg=darkyellow
hi Search ctermbg=darkgray


" common settings for colorscheme
hi VertSplit ctermfg=NONE ctermbg=NONE cterm=NONE
hi Statusline ctermfg=NONE ctermbg=NONE cterm=bold 
hi StatuslineNC ctermfg=NONE ctermbg=NONE cterm=NONE

" let fillchars become space
set fillchars=vert:\ 

" bottem statusline settings
set statusline=%*\ %.50F\               " show filename and filepath
set statusline+=%=%l/%L:%c\ %*          " show the column and raw num where cursor in
set statusline+=%3p%%\ \                " show proportion of the text in front of the cursor to the total text
set statusline+=%y%m%r%h%w\ \ %*        " show filetype and filestatus
set statusline+=%{&ff}\[%{&fenc}]\ %*   " show encoding type of file
set statusline+=\ %{strftime('%H:%M')}  " show current time
set statusline+=\ \ [%{winnr()}]        " show winNum of current


