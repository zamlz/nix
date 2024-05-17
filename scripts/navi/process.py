import os
from typing import List


def exec(command: List[str]) -> None:
    os.execlp(command[0], *command)
