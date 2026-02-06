#!/usr/bin/env python3

from loguru import logger

from navi.logging import setup_main_logging
from navi.shell.fzf import Fzf
from navi.xorg.window import (
    get_active_windows,
    focus_window,
    set_window_title
)


@setup_main_logging
def main() -> None:
    set_window_title("FZF: Window Switcher")
    windows = get_active_windows()
    fzf = Fzf(
        prompt="Switch Window: ",
        preview="navi-display-window-info {1} 2>/dev/null",
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
