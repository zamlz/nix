from dataclasses import dataclass
from pathlib import Path
from typing import Optional

from navi.shell.colors import AnsiColor


@dataclass(frozen=True)
class Workspace:
    id: int
    active: bool
    geometry: str
    viewport: str
    workarea: str
    name: str

    def __str__(self) -> str:
        if self.active:
            return f"{AnsiColor.BLUE}{self.name}{AnsiColor.RESET}"
        return self.name

    def display_info(self) -> None:
        active_str = " (active)" if self.active else ""
        print(
            f"{AnsiColor.BOLD}NAME{AnsiColor.RESET} = "
            f"{AnsiColor.CYAN}{self.name}{active_str}{AnsiColor.RESET}\n"
            f"{AnsiColor.BOLD}ID{AnsiColor.RESET} = "
            f"{AnsiColor.YELLOW}{self.id}{AnsiColor.RESET}\n"
            f"{AnsiColor.BOLD}GEOMETRY{AnsiColor.RESET} = "
            f"{AnsiColor.GREEN}{self.geometry}{AnsiColor.RESET}\n"
            f"{AnsiColor.BOLD}VIEWPORT{AnsiColor.RESET} = "
            f"{AnsiColor.MAGENTA}{self.viewport}{AnsiColor.RESET}\n"
            f"{AnsiColor.BOLD}WORKAREA{AnsiColor.RESET} = "
            f"{AnsiColor.BLUE}{self.workarea}{AnsiColor.RESET}"
        )


@dataclass(frozen=True)
class Window:
    id_hex: str
    id: int
    workspace: Workspace
    process_id: int
    wm_class: str
    hostname: str
    title: str
    active: bool
    pwd: Optional[Path]

    def __str__(self) -> str:
        title = f"{self.id_hex} {self.title}"
        if self.active:
            return f"{AnsiColor.BLUE}{title}{AnsiColor.RESET}"
        return title

    def display_info(self) -> None:
        active_wksp = " (active)" if self.workspace.active else ""
        wksp_name = self.workspace.name
        print(
            f"{AnsiColor.BOLD}WINDOW_ID{AnsiColor.RESET} = "
            f"{AnsiColor.CYAN}{self.id}{AnsiColor.RESET}\n"
            f"{AnsiColor.BOLD}WINDOW_ID (hex){AnsiColor.RESET} = "
            f"{AnsiColor.CYAN}{self.id_hex}{AnsiColor.RESET}\n"
            f"{AnsiColor.BOLD}WORKSPACE{AnsiColor.RESET} = "
            f"{AnsiColor.YELLOW}{wksp_name}{active_wksp}{AnsiColor.RESET}\n"
            f"{AnsiColor.BOLD}PROCESS_ID{AnsiColor.RESET} = "
            f"{AnsiColor.RED}{self.process_id}{AnsiColor.RESET}\n"
            f"{AnsiColor.BOLD}CLASS{AnsiColor.RESET} = "
            f"{AnsiColor.MAGENTA}{self.wm_class}{AnsiColor.RESET}\n"
            f"{AnsiColor.BOLD}TITLE{AnsiColor.RESET} = "
            f"{AnsiColor.GREEN}{self.title}{AnsiColor.RESET}\n"
            f"{AnsiColor.BOLD}WINDOW_PWD{AnsiColor.RESET} = "
            f"{AnsiColor.BLUE}{self.pwd}{AnsiColor.RESET}"
        )
