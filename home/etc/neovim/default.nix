{ inputs, lib, config, pkgs, ... }: let 
  colorScheme = (import ../../lib/colorscheme).defaultColorScheme;
in {
  programs.nixvim = {
    enable = true;
    enableMan = true;
    defaultEditor = true;
    colorscheme = "zamlz";

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    opts = {
      # set window title
      title = true;
      # fringe line numbers
      number         = true;
      relativenumber = true;
      # cursor crosshair and soft-thresholds
      ruler        = true;
      cursorline   = false;
      cursorcolumn = false;
      #colorcolumn  = [ 80 128 ];
      # text display
      wrap = false;
      # put and end to this tab vs. spaces war
      tabstop     = 4;    # visual spaces per tab character
      expandtab   = true; # expand <TAB> key to spaces in insert mode
      softtabstop = 4;    # number of spaces to insert for a tab
      shiftwidth  = 4;    # number of spaces used for each autoindent step
      # code concealing
      conceallevel = 2;
      #concealcursor = 'nc';
      # code folding
      foldenable     = false;
      foldmethod     = "expr";
      foldexpr       = "nvim_treesitter#foldexpr()";
      foldlevelstart = 10;
      foldnestmax    = 10;
      # dynamic configuration via source files
      modeline = true;
      # let's use the mouse scrolling cause we can
      mouse = "a";
      # rice out neovim
      syntax     = "on";
      lazyredraw = true;
      showmode   = false;
    };

    plugins = {
      gitsigns.enable = true;
      lightline.enable = true;
    };
  };

  xdg.configFile."nvim/colors/zamlz.vim".text = with colorScheme; ''
    " First remove all existing highlighting.
    set background=dark
    hi clear
    if exists("syntax_on")
      syntax reset
    endif

    let colors_name = "zamlz"

    hi Normal guibg=${background} guifg=${foreground}

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
  '';
}
