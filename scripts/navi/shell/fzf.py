import os
from pathlib import Path
from tempfile import NamedTemporaryFile
from typing import List, Optional

from loguru import logger


class Fzf:
    def __init__(
            self,
            ansi: bool = True,
            reverse: bool = True,
            disabled: bool = False,
            multi: bool = True,
            print_query: bool = False,
            binds: List[str] = [],
            nth: Optional[int] = None,
            prompt: Optional[str] = None,
            header: Optional[str] = None,
            header_lines: Optional[int] = None,
            delimiter: Optional[str] = None,
            preview: Optional[str] = None,
            preview_window: Optional[str] = None,
            preview_label: Optional[str] = None
    ) -> None:
        args = []
        if ansi:
            args.append("--ansi")
        if reverse:
            args.append("--reverse")
        if multi:
            args.append("--multi")
        if disabled:
            args.append("--disabled")
        if print_query:
            args.append("--print-query")
        if prompt is not None:
            args.append(f"--prompt '{prompt}'")
        if header is not None:
            args.append(f"--header '{header}'")
        if header_lines is not None:
            args.append(f"--header-lines '{header_lines}'")
        if delimiter is not None:
            args.append(f"--delimiter '{delimiter}'")
        if preview is not None:
            args.append(f"--preview '{preview}'")
        if preview_window is not None:
            args.append(f"--preview-window={preview_window}")
        if preview_label is not None:
            args.append(f"--preview-label='{preview_label}'")
        if nth is not None:
            args.append(f"--nth {nth}")
        for bind in binds:
            args.append(f"--bind '{bind}'")
        self.args = ' '.join(args)

    def prompt(self, options: List[str] = []) -> List[str]:
        with NamedTemporaryFile() as ifp:
            with NamedTemporaryFile() as ofp:
                with open(ifp.name, 'w') as f:
                    f.writelines([f"{opt}\n" for opt in options])
                os.system(f"fzf {self.args} < {ifp.name} > {ofp.name}")
                with open(ofp.name, 'r') as f:
                    selection = f.read().strip().split('\n')
                    logger.debug(f"Fzf selection: {selection}")
                    return selection


if __name__ == "__main__":
    fzf = Fzf(multi=True)
    result = fzf.prompt(["a", "b", "c"])
    print(repr(result))
