# navi-scripts

Personal CLI tools for system management, built around `fzf` for interactive selection.

## Why this package exists

These scripts provide a unified interface for common system tasks: launching programs,
navigating files, managing windows/workspaces, and interacting with git repositories.
They're designed around a consistent pattern: use `fzf` for fuzzy selection, then
perform an action on the selection.

The package is built as a Python application rather than shell scripts for:
- Structured logging (via loguru)
- Type safety and static analysis
- Easier testing and maintenance
- Complex logic (window tracking, workspace management)
- Window manager abstraction (same commands work on X11 and Wayland)

## Commands

### User-facing commands

| Command              | Description                                    |
| -------------------- | ---------------------------------------------- |
| `navi-launcher`      | Launch programs from PATH                      |
| `navi-file-explorer` | Interactive file system navigation             |
| `navi-file-open`     | Open files or directories                      |
| `navi-git`           | Git repository manager (opens lazygit)         |
| `navi-window`        | Switch between open windows                    |
| `navi-workspace`     | Manage workspaces (jump, move, create, delete) |
| `navi-calculator`    | RPN calculator                                 |
| `navi-pass`          | Password store interface                       |
| `navi-man`           | Browse and open man pages                      |
| `navi-notes`         | Notes manager                                  |
| `navi-todo`          | Todo/task viewer                               |
| `navi-ripgrep`       | Interactive ripgrep search                     |
| `navi-system`        | System actions (lock, reboot, poweroff)        |
| `navi-term`          | Spawn terminal (abstracts alacritty/foot)      |

### Internal tools

These are used by shell hooks and fzf previews:

| Command                       | Description                                    |
| ----------------------------- | ---------------------------------------------- |
| `navi-save-window-info`       | Save current window's PWD (called by zsh hook) |
| `navi-display-window-info`    | Display window info (fzf preview)              |
| `navi-display-workspace-info` | Display workspace info (fzf preview)           |

## Window Manager Abstraction

The package abstracts over window managers, allowing the same commands to work on both
X11 (herbstluftwm) and Wayland (niri). The `WindowManager` abstract class provides:

- **Clipboard**: Copy to clipboard (xclip vs wl-copy)
- **Screen lock**: Lock screen (i3lock vs swaylock)
- **Workspaces**: List, create, delete, jump to workspaces
- **Windows**: List, focus, track window PWD
- **Terminal spawning**: Spawn terminals with WM-appropriate emulator and options

### Terminal spawning (`navi-term`)

`navi-term` spawns a terminal using the appropriate emulator for the current WM:
- **herbstluftwm**: Uses `alacritty` with `--class`, `--option` flags
- **niri**: Uses `foot` with `--app-id`, `--window-size-chars`, `--override` flags

Options like `--app-id`, `--lines`, `--columns`, `--font-size` are translated to the
appropriate terminal-specific flags.

Before spawning, `navi-term` saves the currently focused window ID. This enables
the `--inherit-cwd` flag, which spawns the terminal in the same directory as the
previously focused window. Example: `navi-term --inherit-cwd`

### Window PWD tracking

Terminal windows track their working directory via zsh hooks:
1. On every prompt, the `precmd` hook calls `navi-save-window-info`
2. This saves the current PWD to `~/tmp/.wid/<window_id>`
3. Commands can retrieve a window's PWD using `wm.get_window_pwd(window_id)`

## Runtime Dependencies

This package does **not** bundle its runtime dependencies. They are expected to be
available in your environment (installed via NixOS/home-manager configuration).

### Required
- `fzf` - fuzzy finder (core dependency, used by all commands)
- `coreutils` - basic utilities (ls, etc.)

### Window manager specific

| Tool           | Window Manager | Used by                            |
| -------------- | -------------- | ---------------------------------- |
| `wmctrl`       | herbstluftwm   | window, workspace                  |
| `xdotool`      | herbstluftwm   | window, workspace                  |
| `herbstclient` | herbstluftwm   | workspace, system                  |
| `xclip`        | herbstluftwm   | clipboard                          |
| `alacritty`    | herbstluftwm   | terminal spawning                  |
| `i3lock`       | herbstluftwm   | screen lock                        |
| `niri`         | niri           | window, workspace, system          |
| `wl-copy`      | niri           | clipboard                          |
| `foot`         | niri           | terminal spawning                  |
| `swaylock`     | niri           | screen lock                        |

### Used by specific commands

| Tool           | Used by                                               |
| -------------- | ----------------------------------------------------- |
| `fd`           | file-open, notes, pass                                |
| `ripgrep` (rg) | ripgrep                                               |
| `bat`          | file previews                                         |
| `tree`         | directory previews                                    |
| `mediainfo`    | binary file previews                                  |
| `lazygit`      | git                                                   |
| `git`          | git, file-open (git root detection)                   |
| `pass`         | pass                                                  |
| `qrencode`     | pass (QR codes)                                       |
| `imagemagick`  | pass (image inversion), system (blur for lock screen) |
| `feh`          | pass (QR display)                                     |
| `man`          | man                                                   |
| `gnupg`        | pass (gpg-connect-agent)                              |

### External scripts
- `notes-tasks` - expected in PATH, used by navi-todo
- `~/usr/notes/bin/notes_manager.py` - used by navi-notes

## Architecture

```
src/navi/
├── cli/             # Entry points (one file per command)
├── tools/           # Internal tools (shell hooks, fzf previews)
├── shell/           # fzf wrapper, ANSI colors
├── window_manager/  # Window manager abstraction
│   ├── abstract.py      # WindowManager ABC
│   ├── herbstluftwm.py  # X11 implementation
│   ├── niri.py          # Wayland implementation
│   └── types.py         # Window, Workspace dataclasses
├── data/            # Shell scripts for fzf previews
├── system.py        # System operations (open files, etc.)
└── logging.py       # Logging setup with error handling
```
