#!/usr/bin/env python3

import logging
import site
from argparse import ArgumentParser
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

from navi.logging import setup_logger
from navi.tools.fzf import Fzf
from navi.xorg.window import get_last_focused_window_id, set_window_title
from navi.xorg.workspace import (
    create_workspace,
    delete_workspace,
    jump_to_workspace,
    list_workspaces,
    move_window_to_workspace
)


logger = logging.getLogger(__name__)


def main() -> None:
    parser = ArgumentParser()
    parser.add_argument("-j", "--jump",action="store_true")
    parser.add_argument("-m", "--move-window",action="store_true")
    parser.add_argument("-d", "--delete",action="store_true")
    args = parser.parse_args()

    workspaces = list_workspaces()
    prompt = ""
    window_id = None

    if args.jump:
        prompt = "Jump to"
    elif args.move_window:
        prompt = "Move Window to"
        window_id = get_last_focused_window_id()
    elif args.delete:
        prompt = "Delete"
    else:
        raise Exception("An option must be selected")

    set_window_title("FZF: Workspace Manager")
    fzf = Fzf(
        prompt=f"{prompt} workspace: ",
        preview=str(Path(__file__).parent / "display_workspace_info.py") + " {2}",
        preview_window="right,80",
        preview_label="[Window List]",
        print_query=True
    )
    workspace_names = [str(w) for w in workspaces.values()]
    # selecting the last item of this is necessary to not use queries
    workspace_name = fzf.prompt(workspace_names)[-1]

    if workspace_name == '':
        logger.warning("No workspace selected. Aborting!")
        return

    if args.jump or args.move_window:
        if workspace_name not in workspaces.keys():
            workspace = create_workspace(workspace_name)
        else:
            workspace = workspaces[workspace_name]

        if args.jump:
            jump_to_workspace(workspace)
        elif args.move_window:
            if window_id is None:
                raise ValueError("No last focused window id!")
            move_window_to_workspace(window_id, workspace)

    elif args.delete:
        if workspace_name not in workspaces.keys():
            logger.warning(f"Workspace ({workspace_name}) does not exist!")
            return
        elif workspace_name == 'λ':
            logger.warning(f"Cannot delete default workspace (λ)")
            return
        delete_workspace(workspace_name)


if __name__ == "__main__":
    setup_logger()
    main()
