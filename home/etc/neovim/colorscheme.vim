" Vim color file
" Custom theme based on the peachpuff colorscheme

" This color scheme uses a peachpuff background (what you've expected when it's
" called peachpuff?).

" First remove all existing highlighting.
set background=light
hi clear
if exists("syntax_on")
  syntax reset
endif

let colors_name = "zamlz"

hi Normal guibg=Black guifg=White

hi SpecialKey term=bold ctermfg=4 guifg=Blue
hi NonText term=bold cterm=bold ctermfg=4 gui=bold guifg=Blue
hi Directory term=bold ctermfg=4 guifg=Blue
hi ErrorMsg term=standout cterm=bold ctermfg=7 ctermbg=1 gui=bold guifg=White guibg=Red
hi IncSearch term=reverse cterm=reverse gui=reverse
hi Search term=reverse ctermbg=3 guibg=Gold2
hi MoreMsg term=bold ctermfg=2 gui=bold guifg=SeaGreen
hi ModeMsg term=bold cterm=bold gui=bold
hi LineNr term=underline ctermfg=3 guifg=Red3
hi Question term=standout ctermfg=2 gui=bold guifg=SeaGreen
hi StatusLine term=bold,reverse cterm=bold,reverse gui=bold guifg=White guibg=Black
hi StatusLineNC term=reverse cterm=reverse gui=bold guifg=PeachPuff guibg=Gray45
hi VertSplit term=reverse cterm=reverse gui=bold guifg=White guibg=Gray45
hi Title term=bold ctermfg=5 gui=bold guifg=DeepPink3
hi Visual term=reverse cterm=reverse gui=reverse guifg=Grey80 guibg=fg
hi WarningMsg term=standout ctermfg=1 gui=bold guifg=Red
hi WildMenu term=standout ctermfg=0 ctermbg=3 guifg=Black guibg=Yellow
hi Folded term=standout ctermfg=4 ctermbg=7 guifg=Black guibg=#e3c1a5
hi FoldColumn term=standout ctermfg=4 ctermbg=7 guifg=DarkBlue guibg=Gray80
hi DiffAdd term=bold ctermfg=green ctermbg=None
hi DiffChange term=bold ctermfg=green ctermbg=None
hi DiffDelete term=bold ctermfg=red ctermbg=None
hi DiffText term=bold ctermfg=green ctermbg=None
hi Cursor guifg=bg guibg=fg
hi lCursor guifg=bg guibg=fg

" Colors for syntax highlighting
hi Comment term=bold ctermfg=4 guifg=#406090
hi Constant term=underline ctermfg=1 guifg=#c00058
hi Special term=bold ctermfg=5 guifg=SlateBlue
hi Identifier term=underline ctermfg=6 guifg=DarkCyan
hi Statement term=bold ctermfg=3 gui=bold guifg=Brown
hi PreProc term=underline ctermfg=5 guifg=Magenta3
hi Type term=underline ctermfg=2 gui=bold guifg=SeaGreen
hi Ignore cterm=bold ctermfg=7 guifg=bg
hi Error term=reverse cterm=bold ctermfg=7 ctermbg=1 gui=bold guifg=White guibg=Red
hi Todo term=standout ctermfg=0 ctermbg=3 guifg=Blue guibg=Yellow

" Peachpuff Overrides
" -------------------

" Color of the Columns
highlight ColorColumn ctermbg=black
highlight CursorColumn ctermbg=black
highlight VertSplit ctermfg=black

" Change the default coloring of line numbers
highlight LineNr ctermfg=darkgrey

" Change colorscheme of Pmenus
highlight Pmenu ctermfg=darkgrey ctermbg=black

" Set background color of folded blocks
highlight Folded ctermbg=black

" Some syntax highlighting changes
highlight Function ctermfg=darkblue
highlight String ctermfg=darkgreen
highlight Comment ctermfg=darkgrey
highlight Exception ctermfg=darkred

" Fix colors on gitsign background
highlight SignColumn ctermbg=None

highlight Conceal ctermbg=None ctermfg=darkblue
