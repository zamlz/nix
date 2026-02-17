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

## Commands

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
| `navi-spawn-shell`   | Spawn terminal with current environment        |

## Runtime Dependencies

This package does **not** bundle its runtime dependencies. They are expected to be
available in your environment (installed via NixOS/home-manager configuration).

### Required
- `fzf` - fuzzy finder (core dependency, used by all commands)
- `coreutils` - basic utilities (ls, etc.)

### Used by specific commands
| Tool           | Used by                                               |
| -------------- | ----------------------------------------------------- |
| `fd`           | file-open, notes, pass                                |
| `ripgrep` (rg) | ripgrep                                               |
| `bat`          | file previews                                         |
| `tree`         | directory previews                                    |
| `mediainfo`    | binary file previews                                  |
| `wmctrl`       | window, workspace                                     |
| `xdotool`      | window                                                |
| `alacritty`    | file-open, man (terminal spawning)                    |
| `lazygit`      | git                                                   |
| `git`          | git, file-open (git root detection)                   |
| `pass`         | pass                                                  |
| `xclip`        | pass (clipboard)                                      |
| `qrencode`     | pass (QR codes)                                       |
| `imagemagick`  | pass (image inversion), system (blur for lock screen) |
| `feh`          | pass (QR display)                                     |
| `i3lock`       | system (herbstluftwm lock screen)                     |
| `swaylock`     | system (niri lock screen)                             |
| `herbstclient` | workspace, system (herbstluftwm)                      |
| `niri`         | system (niri WM)                                      |
| `man`          | man                                                   |
| `gnupg`        | pass (gpg-connect-agent)                              |

### External scripts
- `notes-tasks` - expected in PATH, used by navi-todo
- `~/usr/notes/bin/notes_manager.py` - used by navi-notes

## Architecture

```
src/navi/
├── cli/           # Entry points (one file per command)
├── shell/         # fzf wrapper, ANSI colors
├── xorg/          # X11 window/workspace management
├── data/          # Shell scripts for fzf previews
├── system.py      # System operations (open files, lock screen, etc.)
├── window_manager.py  # WM detection
└── logging.py     # Logging setup with error handling
```

## Window Manager Support

Supports two window managers with WM-specific behavior:
- **herbstluftwm** (X11) - uses wmctrl, xdotool, herbstclient, i3lock
- **niri** (Wayland) - uses niri CLI, swaylock
