#!/usr/bin/env python3

import argparse
import logging
import operator
import site
import sys
from enum import StrEnum
from functools import reduce
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import navi.system
from navi.logging import setup_logger
from navi.shell.fzf import Fzf
from navi.xorg.window import set_window_title


logger = logging.getLogger(__name__)


class Operation(StrEnum):
    ADD = "add"
    SUBTRACT = "sub"
    MULTIPLY = "mul"
    DIVIDE = "div"
    POWER = "pow"
    PERCENT = "per"
    FACTORIAL = "fac"


binary_operation_map = {
    Operation.ADD: operator.add,
    Operation.SUBTRACT: operator.sub,
    Operation.MULTIPLY: operator.mul,
    Operation.DIVIDE: operator.truediv,
    Operation.POWER: operator.pow,
}

unary_operation_map = {
    Operation.PERCENT: lambda x: x / 100,
    Operation.FACTORIAL: lambda x: reduce(operator.mul, range(1, x+1))
}


def main() -> None:
    stack = []
    error_msg = ''

    while True:
        set_window_title(f"FZF: Calculator")
        fzf = Fzf(
            prompt=f"[#+-*/]: ",
            header=error_msg,
            binds=[
                f"+:become(echo {Operation.ADD})",
                f"-:become(echo {Operation.SUBTRACT})",
                f"*:become(echo {Operation.MULTIPLY})",
                f"/:become(echo {Operation.DIVIDE})",
                f"^:become(echo {Operation.POWER})",
                f"%:become(echo {Operation.PERCENT})",
                f"!:become(echo {Operation.FACTORIAL})",
            ],
            print_query=True
        )
        selection = fzf.prompt(stack[::-1])[0]

        if selection == '':
            return

        elif selection in binary_operation_map.keys():
            if len(stack) < 2:
                error_msg = "ERROR: Not enough values in the stack!"
                continue
            op = binary_operation_map[selection]
            x1 = stack.pop()
            x2 = stack.pop()
            stack.append(op(x2, x1))

        elif selection in unary_operation_map.keys():
            if len(stack) < 1:
                error_msg = "ERROR: Stack is empty!"
                continue
            op = unary_operation_map[selection]
            stack.append(op(stack.pop()))

        else:
            try:
                stack.append(int(selection))
            except ValueError as e:
                error_msg = "ERROR: " + str(e)
                continue

        error_msg = ""


if __name__ == "__main__":
    setup_logger()
    main()
