#!/usr/bin/env python3

# TODO: Eventually integrate this with a symbolic math library

import argparse
import logging
import operator
import site
import sys
from dataclasses import dataclass
from enum import StrEnum
from functools import reduce
from pathlib import Path
from typing import Optional

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import navi.system
from navi.logging import setup_logger
from navi.shell.colors import AnsiColor
from navi.shell.fzf import Fzf
from navi.xorg.window import set_window_title


logger = logging.getLogger(__name__)


class Operation(StrEnum):
    NOP = "no-operation"
    ADD = "addition"
    SUBTRACT = "subtract"
    MULTIPLY = "multiply"
    DIVIDE = "divide"
    POWER = "power"
    PERCENT = "percent"
    FACTORIAL = "factorial"


operation_symbol_map = {
    Operation.ADD: '+',
    Operation.SUBTRACT: '-',
    Operation.MULTIPLY: '*',
    Operation.DIVIDE: '/',
    Operation.POWER: '^',
    Operation.PERCENT: '%',
    Operation.FACTORIAL: '!'
}


binary_operation_map = {
    Operation.ADD: operator.add,
    Operation.SUBTRACT: operator.sub,
    Operation.MULTIPLY: operator.mul,
    Operation.DIVIDE: operator.truediv,
    Operation.POWER: operator.pow,
}

unary_operation_map = {
    Operation.PERCENT: lambda x: x / 100,
    Operation.FACTORIAL: lambda x: reduce(operator.mul, range(1, int(x)+1))
}


@dataclass(frozen=True)
class NumericalValue:
    value: float
    history: Optional[str] = None

    def __str__(self) -> str:
        if self.history is None:
            return str(self.value)
        history = (
            f"{AnsiColor.ITALIC}{AnsiColor.LIGHT_BLUE}"
            f" = {self.history}{AnsiColor.RESET}"
        )
        return f"{self.value}{history}"

    def get_history(self) -> str:
        if self.history is None:
            return str(self.value)
        return self.history


def main() -> None:
    stack = []
    error_msg = ''
    set_window_title(f"FZF: Calculator")

    while True:
        fzf = Fzf(
            prompt=f"[#+-*/]: ",
            header=error_msg,
            binds=[
                f"enter:become(echo {Operation.NOP} {{q}})",
                f"+:become(echo {Operation.ADD} {{q}})",
                f"-:become(echo {Operation.SUBTRACT} {{q}})",
                f"*:become(echo {Operation.MULTIPLY} {{q}})",
                f"/:become(echo {Operation.DIVIDE} {{q}})",
                f"^:become(echo {Operation.POWER} {{q}})",
                f"%:become(echo {Operation.PERCENT} {{q}})",
                f"!:become(echo {Operation.FACTORIAL} {{q}})",
            ],
            print_query=True,
            disabled=True
        )
        selection = fzf.prompt(stack[::-1])[0]
        print(selection)
        if selection == '':
            return

        selection_split = selection.split(maxsplit=1)
        operation = selection_split[0]

        try:
            stack.append(NumericalValue(value=float(selection_split[1])))
        except IndexError:
            pass  # the index error can be silently ignored
        except ValueError as e:
            error_msg = "ERROR: " + str(e)
            continue

        if operation in binary_operation_map.keys():
            if len(stack) < 2:
                error_msg = "ERROR: Not enough values in the stack!"
                continue
            op = binary_operation_map[operation]
            symbol = operation_symbol_map[operation]
            x1 = stack.pop()
            x2 = stack.pop()
            result = NumericalValue(
                value=op(x2.value, x1.value),
                history=f"({x2.get_history()} {symbol} {x1.get_history()})"
            )
            stack.append(result)

        elif operation in unary_operation_map.keys():
            if len(stack) < 1:
                error_msg = "ERROR: Stack is empty!"
                continue
            op = unary_operation_map[operation]
            symbol = operation_symbol_map[operation]
            x1 = stack.pop()
            result = NumericalValue(
                value=op(x1.value),
                history=f"({x1.get_history()} {symbol})"
            )
            stack.append(result)

        error_msg = ""


if __name__ == "__main__":
    setup_logger()
    main()
