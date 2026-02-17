#!/usr/bin/env python3

"""Spawn a terminal using the appropriate emulator for the current window manager."""

import argparse
from pathlib import Path

from navi.logging import setup_main_logging
from navi.system import get_filesystem_pointer
from navi.window_manager import get_window_manager


@setup_main_logging
def main() -> None:
    parser = argparse.ArgumentParser(
        description="Spawn a terminal using the WM-appropriate emulator"
    )
    parser.add_argument(
        "-d", "--working-directory",
        type=Path,
        help="Working directory for the terminal"
    )
    parser.add_argument(
        "--inherit-cwd",
        action="store_true",
        help="Inherit working directory from the previously focused terminal window"
    )
    parser.add_argument(
        "-e", "--command",
        nargs=argparse.REMAINDER,
        help="Command to execute in the terminal"
    )
    parser.add_argument(
        "--app-id",
        type=str,
        help="Window class/app-id for window manager rules"
    )
    parser.add_argument(
        "--lines",
        type=int,
        help="Number of lines (height) for the terminal window"
    )
    parser.add_argument(
        "--columns",
        type=int,
        help="Number of columns (width) for the terminal window"
    )
    parser.add_argument(
        "--font-size",
        type=float,
        help="Font size for the terminal (already scaled)"
    )
    args = parser.parse_args()

    if args.working_directory and args.inherit_cwd:
        parser.error("--working-directory and --inherit-cwd are mutually exclusive")

    wm = get_window_manager()

    # Save the currently focused window ID before spawning the new terminal.
    # This is needed for --inherit-cwd to know which window was focused BEFORE
    # the new terminal spawned (since the new terminal becomes focused immediately).
    # The saved ID allows us to look up the previous window's PWD.
    wm.save_active_window_id()

    # Determine working directory
    if args.inherit_cwd:
        working_dir = get_filesystem_pointer(global_search_mode=False, find_git_root=False)
    else:
        working_dir = args.working_directory

    wm.spawn_terminal(
        command=args.command if args.command else None,
        working_dir=working_dir,
        app_id=args.app_id,
        lines=args.lines,
        columns=args.columns,
        font_size=args.font_size,
    )


if __name__ == "__main__":
    main()
