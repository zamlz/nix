import os
from pathlib import Path
from tempfile import NamedTemporaryFile
from typing import List, Optional


class Fzf:
    def __init__(
            self,
            ansi: bool = True,
            reverse: bool = True,
            disabled: bool = False,
            binds: List[str] = [],
            prompt: Optional[str] = None,
            preview: Optional[str] = None,
            preview_window: Optional[str] = None,
    ) -> None:
        args = []
        if ansi:
            args.append("--ansi")
        if reverse:
            args.append("--reverse")
        if disabled:
            args.append("--disabled")
        if prompt is not None:
            args.append(f"--prompt '{prompt}'")
        if preview is not None:
            args.append(f"--preview '{preview}'")
        if preview_window is not None:
            args.append(f"--preview-window={preview_window}")
        for bind in binds:
            args.append(f"--bind '{bind}'")
        self.args = ' '.join(args)

    def prompt(self, options: List[str] = []) -> str:
        with NamedTemporaryFile() as ifp:
            with NamedTemporaryFile() as ofp:
                with open(ifp.name, 'w') as f:
                    f.writelines([f"{opt}\n" for opt in options])
                os.system(f"fzf {self.args} < {ifp.name} > {ofp.name}")
                with open(ofp.name, 'r') as f:
                    return f.read().strip()


if __name__ == "__main__":
    fzf = Fzf()
    result = fzf.prompt(["a", "b", "c"])
    print(repr(result))
