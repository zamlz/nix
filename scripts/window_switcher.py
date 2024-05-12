#!/usr/bin/env python3

import site
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import xorg
from fzf import Fzf

def main() -> None:
    xorg.set_window_title("FZF: Window Switcher")
    windows = xorg.get_active_windows()
    fzf = Fzf(
        prompt="Switch Window: ",
        preview=str(Path.home() / ".config/sxhkd/get-window-info.sh") + " {1}",
        preview_window="down,7",
    )
    action = fzf.prompt(list(str(w) for w in windows.values()))
    if action == '':
        return
    window_id_hex = action.split()[0]
    if window_id_hex not in windows.keys():
        return
    xorg.focus_window(windows.get(window_id_hex))


if __name__ == "__main__":
    main()
