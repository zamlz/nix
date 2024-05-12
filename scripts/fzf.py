import os
from pathlib import Path
from tempfile import NamedTemporaryFile
from typing import List, Optional


class Fzf:
    def __init__(
            self,
            prompt: Optional[str] = None,
            reverse: bool = False
    ) -> None:
        args = []
        if reverse:
            args.append("--reverse")
        if prompt is not None:
            args.append(f"--prompt '{prompt}'")
        self.args = ' '.join(args)

    def prompt(self, options: List[str]) -> str:
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
