import os
import subprocess
from enum import StrEnum
from pathlib import Path
from typing import List, Mapping, Optional

from loguru import logger

from navi.data import get_data_script_path
from navi.window_manager import get_window_manager


# Let the `xdg-open` command handle opening of the following file types.
XDG_OPEN_EXTENSIONS = [
    "gif",
    "mp3",
    "mp4",
    "jpeg",
    "jpg",
    "pdf",
    "png",
    "webm",
]


def execute(command: List[str], environ: Mapping[str, str] = os.environ) -> None:
    os.execlpe(command[0], *command, dict(environ))


def sudo_execute(command: List[str]) -> None:
    execute(["sudo", *command])


def nohup(command: List[str]) -> None:
    nohup_script = get_data_script_path("nohup.sh")
    subprocess.run(
        [nohup_script, *command],
    ).check_returncode()


def reload_gpg_agent() -> None:
    subprocess.run(
        ["gpg-connect-agent", "--no-autostart", "RELOADAGENT", "/bye"],
        capture_output=True
    ).check_returncode()


def get_man_pages() -> List[str]:
    result = subprocess.run(["man", "-k", "."], capture_output=True)
    result.check_returncode()
    return str(result.stdout, encoding="utf-8").strip().split("\n")


def open_man_page(man_page: str) -> None:
    man_page_name, man_page_index, _ = man_page.split(maxsplit=2)
    logger.debug(f"opening man page: {man_page_name}({man_page_index})")
    get_window_manager().spawn_terminal(command=["man", man_page_index, man_page_name])


def reboot() -> None:
    sudo_execute(["reboot"])


def power_off() -> None:
    sudo_execute(["poweroff"])


#FIXME: where to put these below?


# the filesystem pointer is a special construct for keeping track of
# working directories in active windows
def get_filesystem_pointer(
        global_search_mode: bool,
        find_git_root: bool = True
) -> Path:
    if global_search_mode:
        return Path.home()
    wm = get_window_manager()
    last_focused_window_id = wm.get_last_active_window_id()
    if last_focused_window_id is None:
        return Path.home()
    window_pwd = wm.get_window_pwd(last_focused_window_id)
    if window_pwd is None:
        return Path.home()
    if not find_git_root:
        return window_pwd
    try:
        result = subprocess.run(
            ["git", "-C", str(window_pwd), "rev-parse", "--show-toplevel"],
            capture_output=True
        )
        result.check_returncode()
        return Path(str(result.stdout, encoding="utf-8").strip())
    except subprocess.CalledProcessError:
        return window_pwd


class SearchMode(StrEnum):
    FILE = 'f'
    DIRECTORY = 'd'


def get_dir_items(
        root_dir: Path,
        mode: SearchMode,
        show_hidden: bool = False,
        show_unrestricted: bool = False,
        pattern: str = "",
        extension: Optional[str] = None,
        color: bool = True
) -> List[str]:
    fd_cmd = [
        "fd", pattern,
        "--base-directory", str(root_dir),
        "--color", ("always" if color else "never")
    ]
    if show_hidden:
        fd_cmd.append("--hidden")
    if show_unrestricted:
        fd_cmd.append("--unrestricted")
    if extension is not None:
        fd_cmd.extend(["--extension", extension])
    match mode:
        case SearchMode.FILE:
            fd_cmd.extend(["--type", "file"])
        case SearchMode.DIRECTORY:
            fd_cmd.extend(["--type", "dir"])
        case _:
            raise ValueError(f'Invalid Search mode provided ({mode})')
    result = subprocess.run(fd_cmd, capture_output=True)
    result.check_returncode()
    return str(result.stdout, encoding="utf-8").strip().split("\n")


def open_file(file_path: Path, line_num: int = 0, column_num: int = 0) -> None:
    logger.debug(f"opening files: {file_path}")
    if not file_path.is_file():
        logger.warning(f"{file_path} is not a file!")
        return
    escaped_file_path = str(file_path).replace(' ', '\\ ')
    # TODO: Study xdg-open to see if there is a better way of doing this
    # FIXME: Is there something better than xdg-open for wayland?
    if any([str(file_path).endswith(ext) for ext in XDG_OPEN_EXTENSIONS]):
        nohup(["xdg-open", str(file_path)])
    else:
        # Start zsh so shell hooks run (saving window details)
        get_window_manager().spawn_terminal(
            command=["zsh", "-c", f"{os.getenv('EDITOR')} {escaped_file_path} +{line_num}"],
            working_dir=file_path.parent
        )


def open_directory(dir_path: Path) -> None:
    logger.debug(f"opening directory: {dir_path}")
    if not dir_path.is_dir():
        logger.warning(f"{dir_path} is not a directory!")
        return
    get_window_manager().spawn_terminal(
        command=["zsh"],
        working_dir=dir_path
    )


def open_items(items: List[Path]) -> None:
    for item in items:
        if item.is_file():
            open_file(item)
        elif item.is_dir():
            open_directory(item)
        else:
            logger.warning(f"{item} is not a file or a directory")


def git_status(directory: Path) -> str:
    result = subprocess.run(
        ["git", "-C", str(directory), "status", "--porcelain"],
        capture_output=True
    )
    result.check_returncode()
    return str(result.stdout, encoding="utf-8").strip()


def git_ahead_count(directory: Path) -> int:
    result = subprocess.run(
        ["git", "-C", str(directory), "rev-list", "--count", "@{u}..HEAD"],
        capture_output=True
    )
    result.check_returncode()
    return int(str(result.stdout, encoding="utf-8").strip())
