#!/usr/bin/env python3

import site
from pathlib import Path

from loguru import logger

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

from navi.logging import setup_main_logging
from navi.shell.fzf import Fzf
from navi.xorg.window import (
    XorgWindow,
    get_active_windows,
    focus_window,
    set_window_title
)


INFO_SCRIPT = Path(__file__).parent / "navi/tools/display_window_info.py"


@setup_main_logging
def main() -> None:
    set_window_title("FZF: Window Switcher")
    windows = get_active_windows()
    fzf = Fzf(
        prompt="Switch Window: ",
        preview=f"{INFO_SCRIPT} {{1}} 2>/dev/null",
        preview_window="down,7",
        preview_label="[Window Metadata]"
    )
    action = fzf.prompt(list(str(w) for w in windows.values()))[0]
    if action == '':
        logger.warning("No window selected. Aborting!")
        return
    window_id = int(action.split()[0], 0)
    focus_window(window_id)
    logger.info(f"Changed window focus to {window_id}")


if __name__ == "__main__":
    main()
