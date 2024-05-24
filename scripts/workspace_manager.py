#!/usr/bin/env python3

import logging
import site
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

from navi.logging import setup_logger
from navi.tools.fzf import Fzf
from navi.xorg.window import set_window_title
from navi.xorg.workspace import list_workspaces


logger = logging.getLogger(__name__)


def main() -> None:
    set_window_title("FZF: Workspace Manager")
    fzf = Fzf(
        prompt="Jump to workspace: ",
        preview=str(Path(__file__).parent / "display_workspace_info.py") + " {2}",
        preview_window="right,80",
        preview_label="[Window List]",
        delimiter=':',
        nth=2,
        binds=["enter:become(echo {1})"]
    )
    workspaces = list_workspaces()
    action = fzf.prompt(workspaces)[0]

    if action == '':
        logger.warning("No workspace selected. Aborting!")
        return

    desktop_num = int(action.strip())
    workspaces[desktop_num].focus()


if __name__ == "__main__":
    setup_logger()
    main()
