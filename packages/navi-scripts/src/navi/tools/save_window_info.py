#!/usr/bin/env python3

"""Save the current window's working directory for later retrieval.

This is called by zsh hooks on every prompt to track the PWD of each terminal window.
The saved info can be retrieved by navi-spawn-identical-shell to open a new terminal
in the same directory as the currently focused one.
"""

from pathlib import Path

from navi.logging import setup_main_logging
from navi.window_manager import get_window_manager


@setup_main_logging
def main() -> None:
    wm = get_window_manager()
    window_id = wm.get_focused_window_id()
    if window_id is None:
        return
    pwd = Path.cwd()
    wm.save_window_pwd(window_id, pwd)


if __name__ == "__main__":
    main()
