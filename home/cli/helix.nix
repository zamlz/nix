{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.helix = {
    enable = true;
    defaultEditor = false;
    extraPackages = with pkgs; [
      marksman
      python311Packages.python-lsp-server
    ];
    settings = {
      theme = "navi";
      editor = {
        scrolloff = 5;
        mouse = true;
        middle-click-paste = true;
        scroll-lines = 3;
        line-number = "relative";
        cursorline = false;
        cursorcolumn = false;
        auto-completion = true;
        auto-format = false;
        auto-save = true;
        idle-timeout = 250;
        completion-timeout = 250;
        preview-completion-insert = true;
        completion-trigger-len = 2;
        completion-replace = false;
        auto-info = true;
        true-color = false;
        undercurl = false;
        rulers = [
          80
          128
        ];
        bufferline = "multiple";
        color-modes = true;
        text-width = 80;
        workspace-lsp-roots = [ ];
        default-line-ending = "native";
        insert-final-newline = true;
        popup-border = "all";
        indent-heuristic = "hybrid";
        jump-label-alphabet = "fjdkslatyrueiwoqpvbcnxmz";
        cursor-shape = {
          insert = "block";
          normal = "block";
          select = "block";
        };
        statusline = {
          left = [
            "mode"
            "spinner"
            "file-absolute-path"
            "read-only-indicator"
            "file-modification-indicator"
            "version-control"
          ];
          center = [ ];
          right = [
            "diagnostics"
            "selections"
            "register"
            "position"
            "file-encoding"
          ];
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };
      };
      editor.gutters = {
        layout = [
          "diff"
          "line-numbers"
          "diagnostics"
        ];
        line-numbers.min-width = 1;
      };
    };
    themes = {
      navi = {
        "ui.background" = { };
        "ui.background.separator" = {
          fg = "red";
        };
        "ui.bufferline" = { };
        "ui.bufferline.active" = {
          fg = "white";
        };
        "ui.bufferline.background" = {
          fg = "gray";
        };
        "ui.cursor" = {
          fg = "light-gray";
          modifiers = [
            "reversed"
            "slow_blink"
          ];
        };
        "ui.cursor.normal" = {
          fg = "light-gray";
          modifiers = [ "reversed" ];
        };
        "ui.cursor.insert" = {
          fg = "light-gray";
          modifiers = [ "reversed" ];
        };
        "ui.cursor.select" = {
          fg = "light-gray";
          modifiers = [ "reversed" ];
        };
        "ui.cursor.match" = {
          fg = "magenta";
          modifiers = [ "reversed" ];
        };
        "ui.cursor.primary" = {
          fg = "light-gray";
          modifiers = [ "reversed" ];
        };
        "ui.cursor.primary.normal" = {
          fg = "blue";
          modifiers = [
            "reversed"
            "rapid_blink"
          ];
        };
        "ui.cursor.primary.insert" = {
          fg = "red";
          modifiers = [
            "reversed"
            "rapid_blink"
          ];
        };
        "ui.cursor.primary.select" = {
          fg = "green";
          modifiers = [
            "reversed"
            "rapid_blink"
          ];
        };
        "ui.cursor.secondary" = {
          fg = "gray";
          modifiers = [ "reversed" ];
        };
        "ui.cursorline.primary" = {
          bg = "black";
        };
        "ui.cursorline.secondary" = {
          bg = "black";
        };
        "ui.cursorcolumn.primary" = {
          bg = "black";
        };
        "ui.cursorcolumn.secondary" = {
          bg = "black";
        };
        "ui.debug.active" = { };
        "ui.debug.breakpoint" = { };
        "ui.gutter" = { };
        "ui.gutter.selected" = { };
        "ui.help" = {
          fg = "gray";
          modifiers = [ "italic" ];
        };
        "ui.highlight" = { };
        "ui.highlight.frameline" = { };
        "ui.linenr" = {
          fg = "gray";
        };
        "ui.linenr.selected" = {
          fg = "yellow";
          modifiers = [ "bold" ];
        };
        "ui.menu" = {
          fg = "gray";
          modifiers = [ "italic" ];
        };
        "ui.menu.selected" = {
          modifiers = [ "reversed" ];
        };
        "ui.menu.scroll" = {
          fg = "light-blue";
        };
        "ui.popup" = {
          fg = "gray";
          modifiers = [ "italic" ];
        };
        "ui.popup.info" = {
          fg = "gray";
          modifiers = [ "italic" ];
        };
        "ui.selection" = {
          bg = "#282828";
        };
        "ui.statusline" = { };
        "ui.statusline.inactive" = {
          fg = "gray";
        };
        "ui.statusline.normal" = {
          fg = "blue";
        };
        "ui.statusline.insert" = {
          fg = "red";
        };
        "ui.statusline.select" = {
          fg = "green";
        };
        "ui.statusline.separator" = {
          fg = "black";
        };
        "ui.text" = { };
        "ui.text.focus" = { };
        "ui.text.inactive" = { };
        "ui.text.info" = { };
        "ui.virtual" = {
          bg = "black";
        };
        "ui.virtual.indent-guide" = {
          fg = "gray";
        };
        "ui.virtual.jump-label" = {
          fg = "magenta";
        };
        "ui.virtual.ruler" = {
          bg = "black";
          modifiers = [ "dim" ];
        };
        "ui.virtual.whitespace" = { };
        "ui.virtual.wrap" = {
          fg = "gray";
        };
        "ui.virtual.inlay-hint" = {
          fg = "light-gray";
          modifiers = [
            "dim"
            "italic"
          ];
        };
        "ui.virtual.inlay-hint.parameter" = {
          fg = "yellow";
          modifiers = [
            "dim"
            "italic"
          ];
        };
        "ui.virtual.inlay-hint.type" = {
          fg = "blue";
          modifiers = [
            "dim"
            "italic"
          ];
        };
        "ui.window" = {
          fg = "gray";
          modifiers = [ "dim" ];
        };

        "comment" = {
          fg = "light-gray";
          modifiers = [
            "italic"
            "dim"
          ];
        };

        "attribute" = "light-yellow";
        "constant" = {
          fg = "light-red";
          modifiers = [
            "bold"
            "dim"
          ];
        };
        "constant.numeric" = "light-yellow";
        "constant.character.escape" = "light-cyan";
        "constructor" = "light-blue";
        "function" = "light-blue";
        "function.macro" = "light-red";
        "function.builtin" = {
          fg = "light-blue";
          modifiers = [ "bold" ];
        };
        "tag" = {
          fg = "light-magenta";
          modifiers = [ "dim" ];
        };
        "type" = "blue";
        "type.builtin" = {
          fg = "blue";
          modifiers = [ "bold" ];
        };
        "type.enum.variant" = {
          fg = "light-magenta";
          modifiers = [ "dim" ];
        };
        "string" = "light-green";
        "special" = "light-red";
        "variable" = "white";
        "variable.parameter" = {
          fg = "light-yellow";
          modifiers = [ "italic" ];
        };
        "variable.other.member" = "cyan";
        "keyword" = "light-magenta";
        "keyword.control.exception" = "light-red";
        "keyword.directive" = {
          fg = "light-yellow";
          modifiers = [ "bold" ];
        };
        "keyword.operator" = {
          fg = "light-blue";
          modifiers = [ "bold" ];
        };
        "label" = "light-green";
        "namespace" = {
          fg = "blue";
          modifiers = [ "dim" ];
        };

        "markup.heading.1" = {
          fg = "red";
          modifiers = [
            "bold"
            "underlined"
          ];
        };
        "markup.heading.2" = {
          fg = "blue";
          modifiers = [
            "bold"
            "underlined"
          ];
        };
        "markup.heading.3" = {
          fg = "green";
          modifiers = [
            "bold"
            "underlined"
          ];
        };
        "markup.heading.4" = {
          fg = "magenta";
          modifiers = [
            "bold"
            "underlined"
          ];
        };
        "markup.heading.5" = {
          fg = "cyan";
          modifiers = [
            "bold"
            "underlined"
          ];
        };
        "markup.heading.6" = {
          fg = "yellow";
          modifiers = [
            "bold"
            "underlined"
          ];
        };
        "markup.list" = "red";
        "markup.bold" = {
          fg = "light-cyan";
          modifiers = [ "bold" ];
        };
        "markup.italic" = {
          fg = "light-blue";
          modifiers = [ "italic" ];
        };
        "markup.strikethrough" = {
          modifiers = [ "crossed_out" ];
        };
        "markup.link.url" = {
          fg = "magenta";
          modifiers = [ "dim" ];
        };
        "markup.link.text" = "light-magenta";
        "markup.quote" = "light-cyan";
        "markup.raw" = "light-green";

        "diff.plus" = "light-green";
        "diff.delta" = "light-yellow";
        "diff.minus" = "light-red";

        "diagnostic.hint" = {
          underline = {
            color = "gray";
            style = "curl";
          };
        };
        "diagnostic.info" = {
          underline = {
            color = "light-cyan";
            style = "curl";
          };
        };
        "diagnostic.warning" = {
          underline = {
            color = "light-yellow";
            style = "curl";
          };
        };
        "diagnostic.error" = {
          underline = {
            color = "light-red";
            style = "curl";
          };
        };

        "info" = "light-cyan";
        "hint" = {
          fg = "light-gray";
          modifiers = [ "dim" ];
        };
        "debug" = "white";
        "warning" = "yellow";
        "error" = "red";
      };
    };
  };
}
