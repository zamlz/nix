#!/usr/bin/env python3

import os
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path


NOTES_DIR = Path.home() / 'usr/notes'


@dataclass(frozen=True)
class Note:
    path: Path
    name: str

    def __str__(self) -> str:
        return self.name


def create_new_note(note_name: str) -> Note:
    uniq_key = datetime.now().strftime('%Y%m%d')
    new_note_file = NOTES_DIR / f'{uniq_key} {note_name}.md'
    with open(new_note_file, 'w') as f:
        f.write(f'# {note_name}')
    return Note(path=new_note_file, name=note_name)


def get_notes_files():
    notes = []
    for p in NOTES_DIR.glob('./**/*.md'):
        notes.append(Note(path=p, name=p.name.removesuffix('.md')))
    return notes


def print_notes_files():
    notes = get_notes_files()
    for n in notes:
        print(n)
