#!/usr/bin/env python3

import sys
from argparse import ArgumentParser

from loguru import logger

from navi.logging import setup_main_logging
from navi.shell.colors import AnsiColor
from navi.shell.fzf import Fzf
from navi.xorg.window import get_last_active_window_id, set_window_title
from navi.xorg.workspace import (
    create_workspace,
    delete_workspace,
    jump_to_workspace,
    list_workspaces,
    move_window_to_workspace
)


def _quit_with_warning(message: str) -> None:
    logger.warning(message)
    input(f"{AnsiColor.RED}ERROR: {AnsiColor.RESET}" + message)
    sys.exit(2)


@setup_main_logging
def main() -> None:
    parser = ArgumentParser()
    parser.add_argument("-j", "--jump",action="store_true")
    parser.add_argument("-m", "--move-window",action="store_true")
    parser.add_argument("-d", "--delete",action="store_true")
    args = parser.parse_args()

    prompt = ""
    window_id = None
    workspaces = list_workspaces()
    workspace_names = [str(w) for w in workspaces.values() if not w.active]

    if args.jump:
        prompt = "Jump to"
    elif args.move_window:
        prompt = "Move Window to"
        window_id = get_last_active_window_id()
    elif args.delete:
        prompt = "Delete"
    else:
        raise Exception("An option must be selected")

    set_window_title("FZF: Workspace Manager")
    fzf = Fzf(
        prompt=f"{prompt} workspace: ",
        preview="navi-display-workspace-info {1} 2>/dev/null",
        preview_window="right,80",
        preview_label="[Window List]",
        print_query=True
    )
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
            _quit_with_warning(f"Workspace ({workspace_name}) does not exist!")
        elif workspace_name == 'λ':
            _quit_with_warning("Cannot delete default workspace (λ)")
        delete_workspace(workspace_name)


if __name__ == "__main__":
    main()
