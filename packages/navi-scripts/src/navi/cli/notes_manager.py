#!/usr/bin/env python3

import subprocess
from pathlib import Path
from typing import List


import navi.system
from navi.data import get_data_script_path
from navi.logging import setup_main_logging
from navi.shell.fzf import Fzf
from navi.xorg.window import set_window_title


NOTES_DIR = Path.home() / 'usr/notes'


def get_notes_files() -> List[str]:
    result = subprocess.run(
        [f"{NOTES_DIR}/bin/notes_manager.py"],
        capture_output=True
    )
    result.check_returncode()
    return str(result.stdout, encoding="utf-8").strip().split('\n')


def create_new_note(note_name: str) -> Path:
    result = subprocess.run(
        [f"{NOTES_DIR}/bin/notes_manager.py", "create", note_name],
        capture_output=True
    )
    result.check_returncode()
    return Path(str(result.stdout, encoding="utf-8").strip())


@setup_main_logging
def main() -> None:
    set_window_title("FZF: Open notes")
    file_preview_script = get_data_script_path("file_preview.sh")
    fzf = Fzf(
        prompt="Open notes: ",
        preview=f"{file_preview_script} {NOTES_DIR}/{{}}.md",
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
        navi.system.open_file(new_note_file)
    return


if __name__ == "__main__":
    main()
