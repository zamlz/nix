#!/usr/bin/env python3

import site
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

from navi.tools.fzf import Fzf
from navi.xorg.xwindow import XorgWindow, set_window_title


def main() -> None:
    set_window_title("FZF: Window Switcher")
    windows = XorgWindow.get_active_windows()
    fzf = Fzf(
        prompt="Switch Window: ",
        preview=str(Path(__file__).parent / "display_window_info.py") + " {1}",
        preview_window="down,7",
    )
    action = fzf.prompt(list(str(w) for w in windows.values()))[0]
    if action == '':
        return
    window_id = int(action.split()[0], 0)
    if window_id not in windows.keys():
        return
    windows.get(window_id).focus()


if __name__ == "__main__":
    main()
