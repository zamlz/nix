import os
import re
import subprocess
from dataclasses import dataclass
from enum import StrEnum
from pathlib import Path
from typing import Dict, List, Optional

from loguru import logger

from navi.window_manager import WindowManager, get_running_wm
from navi.xorg.window import get_last_active_window_id, get_pwd_of_window


# FIXME: I really don't like this sort of path referencing...
NOHUP_SCRIPT = Path(__file__).parent.parent / "nohup.sh"


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


def execute(command: List[str], environ: dict[str, str] = os.environ) -> None:
    os.execlpe(command[0], *command, environ)


def sudo_execute(command: List[str]) -> None:
    execute(["sudo", *command])


def nohup(command: List[str]) -> None:
    subprocess.run(
        [NOHUP_SCRIPT, *command],
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
    nohup(["alacritty", "--command", "man", man_page_index, man_page_name])


def get_wallpaper() -> Path:
    with open(Path.home() / ".fehbg", 'r') as f:
        return Path(f.readlines()[-1].strip().split(' ')[-1].replace("'", ''))


def blur_image(image: Path) -> Path:
    blurred_image = Path.home() / "tmp/.blurred" / str(image).replace('/', '.')
    if not blurred_image.exists():
        blurred_image.parent.mkdir(parents=True, exist_ok=True)
        # FIXME: Use a native blurring algorithm?
        result = subprocess.run(
            ["convert", str(image), "-blur", "0x8", str(blurred_image)]
        )
        result.check_returncode()
    return blurred_image


def lock_screen(blur_screen: bool) -> None:
    match get_running_wm():
        case WindowManager.HERBSTLUFTWM:
            wallpaper = get_wallpaper()
            if wallpaper.exists():
                lock_screen_image = blur_image(wallpaper) if blur_screen else wallpaper
                execute(["i3lock", "-tnefi", str(lock_screen_image)])
            else:
                execute(["i3lock", "-nef", "--color=000000"])
        case WindowManager.NIRI:
            execute(["swaylock"])


# NOTE: I'm not totally convinced this should be here
def kill_window_manager() -> None:
    match get_running_wm():
        case WindowManager.HERBSTLUFTWM:
            sudo_execute(["herbstclient", "quit"])
        case WindowManager.NIRI:
            sudo_execute(["-v"])
            exeute(["niri" "msg" "action" "quit"])


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
    last_focused_window_id = get_last_active_window_id()
    if last_focused_window_id is None:
        return Path.home()
    window_pwd = get_pwd_of_window(last_focused_window_id)
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
        extension: Optional[str] = None
) -> List[str]:
    fd_cmd = [
        "fd", pattern,
        "--base-directory", str(root_dir),
        "--color", "always"
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
    if any([str(file_path).endswith(ext) for ext in XDG_OPEN_EXTENSIONS]):
        nohup(["xdg-open", str(file_path)])
    else:
        nohup([
            "alacritty",
            "--working-directory", str(file_path.parent),
            # So why do we not run the editor command directly?
            # Well it would work in starting the editor, but zsh startup
            # runs all the hooks for saving the window details.
            # In other words, in order for every terminal window to have
            # a window_id file generated, we must start zsh
            "--command", "zsh", "-c",
            f"{os.getenv('EDITOR')} {escaped_file_path} +{line_num}"
        ])


def open_directory(dir_path: Path) -> None:
    logger.debug(f"opening directory: {dir_path}")
    if not dir_path.is_dir():
        logger.warning(f"{dir_path} is not a directory!")
        return
    nohup(["alacritty", "--working-directory", str(dir_path)])


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
