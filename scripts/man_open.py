#!/usr/bin/env python3

import argparse
import site
import sys
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import navi.system
from navi.logging import setup_main_logging
from navi.shell.fzf import Fzf
from navi.xorg.window import set_window_title


@setup_main_logging
def main() -> None:
    set_window_title(f"FZF: Open ManPages")
    man_pages = navi.system.get_man_pages()

    fzf = Fzf(
        prompt=f"Open man:",
        preview=f"{Path(__file__).parent / 'man_preview.sh'} {{}}",
        multi=True
    )
    selections = fzf.prompt(man_pages)
    for man_page in selections:
        navi.system.open_man_page(man_page)


if __name__ == "__main__":
    main()
