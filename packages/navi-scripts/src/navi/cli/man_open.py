#!/usr/bin/env python3

import navi.system
from navi.data import get_data_script_path
from navi.logging import setup_main_logging
from navi.shell.fzf import Fzf
from navi.window_manager import set_window_title


@setup_main_logging
def main() -> None:
    set_window_title("FZF: Open ManPages")
    man_pages = navi.system.get_man_pages()

    man_preview_script = get_data_script_path("man_preview.sh")
    fzf = Fzf(
        prompt="Open man:",
        preview=f"{man_preview_script} {{}}",
        multi=True
    )
    selections = fzf.prompt(man_pages)
    for man_page in selections:
        navi.system.open_man_page(man_page)


if __name__ == "__main__":
    main()
