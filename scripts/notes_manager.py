#!/usr/bin/env python3

import argparse
import logging
import site
import sys
from datetime import datetime
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import navi.system
from navi.logging import setup_logger
from navi.notes import NOTES_DIR, create_new_note, get_notes_files
from navi.shell.fzf import Fzf
from navi.xorg.window import set_window_title


logger = logging.getLogger(__name__)


TOGGLE_HIDDEN_ACTION = "__TOGGLE_HIDDEN_ACTION__"


def main() -> None:
    set_window_title("FZF: Open notes")
    fzf = Fzf(
        prompt="Open notes: ",
        preview=(
            str(Path(__file__).parent / "file_preview.sh") \
            + f" {NOTES_DIR}/{{}}.md"
        ),
        binds=[
          'enter:become(echo __OPEN__ {})',
          'alt-enter:become(echo __CREATE__ {q})',
        ]
    )

    selection = fzf.prompt(get_notes_files())[0]
    if selection == "":
        return
    command, note_name = selection.split(maxsplit=1)
    if note_name == "":
        return

    if command == '__OPEN__':
        selected_note_file = NOTES_DIR / f'{note_name}.md'
        navi.system.open_file(selected_note_file)
    elif command == '__CREATE__':
        new_note_file = create_new_note(note_name)
        navi.system.open_file(new_note_file.path)
    return


if __name__ == "__main__":
    setup_logger()
    main()
