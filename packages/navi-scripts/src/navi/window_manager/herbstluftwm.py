import os
import re
import subprocess
from pathlib import Path
from typing import Dict, Optional

from loguru import logger

from navi.window_manager.abstract import WindowManager
from navi.window_manager.types import Window, Workspace


USER_TMP_PATH = Path.home() / "tmp"
WINDOW_ID_ENV_DIR = USER_TMP_PATH / ".wid"
LAST_SAVED_ACTIVE_WINDOW_ID_FILE = USER_TMP_PATH / ".last_active_wid"
WINDOW_PWD_REGEX = re.compile("^WINDOW_PWD='(.+)'$")


class HerbstluftWM(WindowManager):
    """Window manager implementation for Herbstluftwm (X11)."""

    # Clipboard
    def copy_to_clipboard(self, file_path: Path) -> None:
        self._nohup(["xclip", "-selection", "clipboard", str(file_path)])

    # Screen lock
    def lock_screen(self, blur: bool) -> None:
        wallpaper = self._get_wallpaper()
        if wallpaper is not None and wallpaper.exists():
            lock_image = self._blur_image(wallpaper) if blur else wallpaper
            self._execute(["i3lock", "-tnefi", str(lock_image)])
        else:
            self._execute(["i3lock", "-nef", "--color=000000"])

    # Session management
    def kill(self) -> None:
        self._sudo_execute(["herbstclient", "quit"])

    # Workspace operations
    def list_workspaces(self) -> Dict[str, Workspace]:
        result = subprocess.run(["wmctrl", "-d"], capture_output=True)
        result.check_returncode()
        workspaces = {}
        for line in str(result.stdout, encoding="utf-8").strip().split('\n'):
            split_line = line.split(maxsplit=8)
            workspace_name = split_line[8]
            workspaces[workspace_name] = Workspace(
                id=int(split_line[0]),
                active=split_line[1] == '*',
                geometry=split_line[3],
                viewport=split_line[5],
                workarea=split_line[7],
                name=workspace_name
            )
        return workspaces

    def get_workspace(self, name: str) -> Workspace:
        try:
            return self.list_workspaces()[name]
        except KeyError:
            raise ValueError(f"{name} not found in active workspaces")

    def create_workspace(self, name: str) -> Workspace:
        result = subprocess.run(["herbstclient", "add", name])
        result.check_returncode()
        return self.list_workspaces()[name]

    def delete_workspace(self, name: str) -> None:
        result = subprocess.run(["herbstclient", "merge_tag", name])
        result.check_returncode()

    def jump_to_workspace(self, workspace: Workspace) -> None:
        result = subprocess.run([
            "xdotool",
            "set_desktop",
            str(workspace.id)
        ])
        result.check_returncode()

    def move_window_to_workspace(self, window_id: int, workspace: Workspace) -> None:
        result = subprocess.run([
            "xdotool",
            "set_desktop_for_window",
            str(window_id),
            str(workspace.id)
        ])
        result.check_returncode()

    # Window operations
    def list_windows(self, filter_id: Optional[int] = None) -> Dict[int, Window]:
        active_windows = {}
        last_active_window_id = self.get_last_active_window_id()
        workspaces = {w.id: w for w in self.list_workspaces().values()}
        result = subprocess.run(["wmctrl", "-lxp"], capture_output=True)
        result.check_returncode()
        for line in str(result.stdout, encoding="utf-8").strip().split("\n"):
            wmctrl_val = line.strip().split(maxsplit=5)
            window_id = int(wmctrl_val[0], 0)
            if filter_id is not None and filter_id != window_id:
                continue
            active_windows[window_id] = Window(
                id_hex=wmctrl_val[0],
                id=window_id,
                workspace=workspaces[int(wmctrl_val[1])],
                process_id=int(wmctrl_val[2]),
                wm_class=wmctrl_val[3],
                hostname=wmctrl_val[4],
                title=wmctrl_val[5],
                active=last_active_window_id == window_id,
                pwd=self.get_window_pwd(window_id)
            )
        return active_windows

    def get_window(self, window_id: int) -> Window:
        filtered_windows = self.list_windows(filter_id=window_id)
        if len(filtered_windows) == 0:
            raise ValueError(f"{window_id} not found among active windows")
        return list(filtered_windows.values())[0]

    def focus_window(self, window_id: int) -> None:
        # Why both commands? wmctrl handles workspace switching but struggles
        # with herbstluftwm's frames. xdotool handles frames but not workspaces.
        subprocess.run(["wmctrl", "-i", "-a", hex(window_id)])
        subprocess.run(["xdotool", "windowfocus", hex(window_id)])

    def get_last_active_window_id(self) -> Optional[int]:
        if not LAST_SAVED_ACTIVE_WINDOW_ID_FILE.exists():
            return None
        with open(LAST_SAVED_ACTIVE_WINDOW_ID_FILE, 'r') as f:
            if (data := f.read().strip()) == '':
                return None
            return int(data)

    def save_active_window_id(self) -> None:
        with open(LAST_SAVED_ACTIVE_WINDOW_ID_FILE, 'w') as f:
            result = subprocess.run(["xdotool", "getactivewindow"], stdout=f)
            result.check_returncode()

    def get_window_pwd(self, window_id: int) -> Optional[Path]:
        window_id_file = WINDOW_ID_ENV_DIR / f"{window_id}"
        if not window_id_file.exists():
            logger.debug('no window id file found')
            return None
        with open(window_id_file, 'r') as f:
            for line in f.readlines():
                match = re.match(WINDOW_PWD_REGEX, line)
                if match is not None:
                    return Path(match.group(1))
        raise ValueError(
            f"Found window id file for {window_id} but no pwd was found!"
        )

    def get_focused_window_id(self) -> Optional[int]:
        # In X11, terminal emulators set WINDOWID env var
        window_id = os.environ.get("WINDOWID")
        if window_id is not None:
            return int(window_id)
        # Fallback to xdotool
        result = subprocess.run(
            ["xdotool", "getactivewindow"],
            capture_output=True
        )
        if result.returncode != 0:
            return None
        return int(result.stdout.decode().strip())

    def save_window_pwd(self, window_id: int, pwd: Path) -> None:
        WINDOW_ID_ENV_DIR.mkdir(parents=True, exist_ok=True)
        window_id_file = WINDOW_ID_ENV_DIR / f"{window_id}"
        with open(window_id_file, 'w') as f:
            f.write(f"WINDOW_PWD='{pwd}'\n")

    def spawn_terminal(
        self,
        command: Optional[list[str]] = None,
        working_dir: Optional[Path] = None,
        app_id: Optional[str] = None,
        lines: Optional[int] = None,
        columns: Optional[int] = None,
        font_size: Optional[float] = None,
    ) -> None:
        cmd = ["alacritty"]
        if app_id is not None:
            cmd.extend(["--class", f"{app_id},{app_id}"])
        if font_size is not None:
            cmd.extend(["--option", f"font.size={font_size}"])
        if lines is not None:
            cmd.extend(["--option", f"window.dimensions.lines={lines}"])
        if columns is not None:
            cmd.extend(["--option", f"window.dimensions.columns={columns}"])
        if working_dir is not None:
            cmd.extend(["--working-directory", str(working_dir)])
        if command is not None:
            cmd.extend(["--command", *command])
        self._nohup(cmd)

    # Private helpers
    @staticmethod
    def _get_wallpaper() -> Optional[Path]:
        fehbg_path = Path.home() / ".fehbg"
        if not fehbg_path.exists():
            return None
        with open(fehbg_path, 'r') as f:
            return Path(f.readlines()[-1].strip().split(' ')[-1].replace("'", ''))

    @staticmethod
    def _blur_image(image: Path) -> Path:
        blurred_image = Path.home() / "tmp/.blurred" / str(image).replace('/', '.')
        if not blurred_image.exists():
            blurred_image.parent.mkdir(parents=True, exist_ok=True)
            result = subprocess.run(
                ["convert", str(image), "-blur", "0x8", str(blurred_image)]
            )
            result.check_returncode()
        return blurred_image
