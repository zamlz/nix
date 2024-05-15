#!/usr/bin/env python3

import site
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import xorg
from fzf import Fzf


RG_COMMAND="rg --line-number --no-heading --color=always --smart-case"


def main() -> None:
    xorg.set_window_title("FZF: Interactive RipGrep in ${PWD}")
    fzf = Fzf(
        prompt="Ripgrep: ",
        delimiter=':',
        binds=[
            f"start:reload:{RG_COMMAND} \"\"",
            f"change:reload:{RG_COMMAND} {{q}} || true"
        ],
        preview=(
            "bat --color=always --style=numbers --theme=ansi "
            "{1} --highlight-line {2}"
        ),
        preview_window="down,60%,border-top,+{2}+3/3,~3"
    )
    print(fzf.prompt())


if __name__ == "__main__":
    main()
