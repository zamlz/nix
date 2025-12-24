{
  ...
}:
let
  colorScheme = (import ../../lib/colorschemes.nix).defaultColorScheme;
in
{
  programs.nixvim = {
    enable = false;
    enableMan = true;
    defaultEditor = false;
    colorscheme = "zamlz";

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    opts = {
      # set window title
      title = true;
      # fringe line numbers
      number = true;
      relativenumber = true;
      # cursor crosshair and soft-thresholds
      ruler = true;
      cursorline = false;
      cursorcolumn = false;
      #colorcolumn  = [ 80 128 ];
      # text display
      wrap = false;
      # put and end to this tab vs. spaces war
      tabstop = 4; # visual spaces per tab character
      expandtab = true; # expand <TAB> key to spaces in insert mode
      softtabstop = 4; # number of spaces to insert for a tab
      shiftwidth = 4; # number of spaces used for each autoindent step
      # code concealing
      conceallevel = 0;
      #concealcursor = 'nc';
      # code folding
      foldenable = false;
      foldmethod = "expr";
      foldexpr = "nvim_treesitter#foldexpr()";
      foldlevelstart = 10;
      foldnestmax = 10;
      # dynamic configuration via source files
      modeline = true;
      # let's use the mouse scrolling cause we can
      mouse = "a";
      # rice out neovim
      syntax = "on";
      lazyredraw = true;
      showmode = false;
    };

    plugins = {
      # ui plugins
      gitsigns.enable = true;
      lightline.enable = true;

      # software development plugins
      lsp = {
        enable = true;
        servers = {
          marksman.enable = true;
          pyright.enable = true;
        };
      };
      nix.enable = true;
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = false;
        };
      };

      # notetaking plugins
      telekasten = {
        enable = true;
        settings = {
          # directories
          home = {
            __raw = "vim.fn.expand(\"~/usr/notes\")";
          };
          dailies = {
            __raw = "vim.fn.expand(\"~/usr/notes/journal/day\")";
          };
          weeklies = {
            __raw = "vim.fn.expand(\"~/usr/notes/journal/week\")";
          };
          templates = {
            __raw = "vim.fn.expand(\"~/usr/notes/templates\")";
          };
          image_subdir = {
            __raw = "vim.fn.expand(\"~/usr/notes/data\")";
          };
          # templates
          template_new_note = {
            __raw = "vim.fn.expand(\"~/usr/notes/templates/default.md\")";
          };
          template_new_daily = {
            __raw = "vim.fn.expand(\"~/usr/notes/templates/daily.md\")";
          };
          template_new_weekly = {
            __raw = "vim.fn.expand(\"~/usr/notes/templates/weekly.md\")";
          };
          # auto creation
          follow_creates_nonexisting = true;
          dailies_creates_nonexisting = true;
          weeklies_creates_nonexisting = true;
          journal_auto_open = true;
          # misc
          image_link_style = "markdown";
          sort = "filename";
          install_syntax = true;
          tag_notation = "yaml-bare";
          subdirs_in_links = true;
          command_palette_theme = "dropdown";
          show_tags_theme = "dropdown";
        };
      };
      telescope.enable = true;
      web-devicons.enable = true;
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

    " UI and Interface Highlights
    highlight Normal        guibg=${background} guifg=${foreground}
    highlight Cursor        guifg=${background} guibg=${foreground}
    highlight StatusLine    guifg=${foreground} guibg=${background} gui=bold
    highlight StatusLineNC  guibg=${blackAlt} gui=bold
    highlight DiffAdd       guifg=${green}
    highlight DiffChange    guifg=${greenAlt}
    highlight DiffDelete    guifg=${red}
    highlight DiffText      guifg=${green}
    highlight Directory     guifg=${blue}
    highlight ErrorMsg      guifg=${white} guibg=${red} gui=bold
    highlight FoldColumn    guifg=${blueAlt} guibg=${white}
    highlight Folded        guifg=${black} guibg=${white}
    highlight lCursor       guifg=${background} guibg=${foreground}
    highlight LineNr        guifg=${yellow}
    highlight LineNrAbove   guifg=#282828
    highlight LineNrBelow   guifg=#282828
    highlight CursorLineNr  guifg=${yellow}
    highlight ModeMsg       gui=bold
    highlight MoreMsg       guifg=${green}
    highlight NonText       guifg=${blue} gui=bold
    highlight Question      guifg=${green}
    highlight SpecialKey    guifg=${blue}
    highlight Title         guifg=${magenta} gui=bold
    highlight VertSplit     guifg=${black} guibg=${background} gui=bold
    highlight Visual        gui=reverse
    highlight WildMenu      guifg=${black} guibg=${yellow}

    " Error and Warning Highlights
    highlight ErrorMsg      guifg=${foreground} guibg=${red}
    highlight WarningMsg    guifg=${red} gui=bold
    highlight InfoMsg       guifg=${blue} gui=bold
    highlight MoreMsg       guifg=${cyan}
    highlight Search        gui=reverse
    highlight IncSearch     gui=reverse

    " Colors for syntax highlighting
    highlight Comment       guifg=${blackAlt}
    highlight Constant      guifg=${redAlt}
    highlight Error         guifg=${white} guibg=${red}
    highlight Exception     guifg=${redAlt}
    highlight Function      guifg=${blue}
    highlight Identifier    guifg=${cyan}
    highlight Ignore        guifg=${background} guibg=${foreground}
    highlight PreProc       guifg=${magenta}
    highlight Special       guifg=${cyan}
    highlight Statement     guifg=${yellow}
    highlight String        guifg=${green}
    highlight Todo          guifg=${white} guibg=${red}
    highlight Type          guifg=${green}
  '';
}
