# NixOS Configuration ❄

A (WIP) NixOS Configuration repo for all my systems.

## New Installation Guide

### NixOS

First, install a minimal installation of NixOS.

Next, once you get into the system. Create a new entry for the
system in the `nixosConfigurations`. This will require copying the
`hardware-configuration.nix` file into the config as well.  Be sure to
also go through the `configuration.nix` and set the relevent parameters
to build the same system.

Enable flakes on the original system. Add the following to the
`/etc/nixos/configuration.nix` file.

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
environment.systemPackages = with pkgs; [ git ];
```

Make sure to update the channels to unstable as well.

```shell
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nixos-rebuild switch --upgrade
```

### Other Linux Distros and Mac

Since the external linux system is managing the system software, we use
nix to manage the user software. Once the software has been installed,
things may not work as expected. This is because some user-level software
needs to talk to system software and with nix not managing that software
anymore there is a disconnect. You have to manually configure the host
system to properly integrate with nix. Look at the subsections for
further details on what worked on.

Use the following for the first time install (since home-manager is
not present in an environment yet). It uses home manager from github to
bootstrap the installation.

```shell
nix run github:nix-community/home-manager -- switch --flake .#generic-linux
```

#### Fedora

I had to disable the following services/sockets and reboot my system.

```shell
sudo systemctl stop pcscd.service
sudo systemctl stop pcscd.socket
sudo systemctl disable pcscd.service
sudo systemctl disable pcscd.socket

systemctl --user stop gcr-ssh-agent.service
systemctl --user stop gcr-ssh-agent.socket
systemctl --user disable gcr-ssh-agent.service
systemctl --user disable gcr-ssh-agent.socket
systemctl --user mask gcr-ssh-agent.service
systemctl --user mask gcr-ssh-agent.socket
```

This will break any other programs that want to use smartcards through
Fedora. I don't have any other uses I think. It also disables support
for the gnome keyring for ssh but that is also fine for me.

## Basic Usage

### NixOS

Install the nixos system. Note this command is hardware dependent. We use the
hostname to associate hardware.

```shell
sudo nixos-rebuild switch --flake .#${hostname}
```

If `nh` is availabe on the system, you can simply do

```shell
nh os switch .
```

### Other Linux Distros and Mac
All future invocations in the environment should have `home-manager` present.

```shell
home-manager switch --flake .#generic-linux
```

## Directory Structure

The following directory stores my `home-manager` configurations. They
are sorted into their respective tools, `cli` and `desktop`.

```
home/
  amlesh.nix
  cli/
    default.nix
    git.nix
    kakoune.nix
    ...
  desktop/
    default.nix
    alacritty.nix
    herbstluftwm.nix
    ...
```

Every machine has its own directory. NixOS machines have `configuration.nix`
and `hardware-configuration.nix`. Non-NixOS machines only have `home.nix`.

Most hosts use the default home-manager configuration from `home/amlesh.nix`.

```
hosts/
  solaris/
    configuration.nix
    hardware-configuration.nix
  xynthar/
    configuration.nix
    hardware-configuration.nix
  yggdrasil/
    configuration.nix
    hardware-configuration.nix
    services/
      kavita.nix
  alexandria/
    configuration.nix
    hardware-configuration.nix
  generic-linux/
    home.nix
```

All NixOS system level configurations
```
nixos/
  audio.nix
  security.nix
  nix.nix
  ...
```

Shared library code used across configurations
```
lib/
  constants.nix
  colorschemes.nix
```

Development environment templates
```
templates/
  python312.nix
  rust.nix
```

Custom packages
```
packages/
  navi-scripts/     # Python CLI tools for system management
    src/navi/       # Source code
    tests/          # Test suite
    package.nix     # Nix package definition
    pyproject.toml  # Python project config
```

## navi-scripts

`navi-scripts` is a custom Python package containing CLI tools for system management, window switching, file navigation, and more. These tools integrate with fzf for interactive selection and support both X11 (herbstluftwm) and Wayland (niri) window managers.

### Available Commands

| Command              | Description                             |
| -------------------- | --------------------------------------- |
| `navi-launcher`      | Program launcher using fzf              |
| `navi-file-explorer` | Interactive file system explorer        |
| `navi-file-open`     | Open files or directories with fzf      |
| `navi-git`           | Git repository manager with lazygit     |
| `navi-window`        | Window switcher                         |
| `navi-workspace`     | Workspace manager (jump, move, delete)  |
| `navi-calculator`    | RPN calculator                          |
| `navi-pass`          | Password store interface                |
| `navi-man`           | Man page browser                        |
| `navi-notes`         | Notes manager                           |
| `navi-ripgrep`       | Interactive ripgrep search              |
| `navi-system`        | System actions (lock, reboot, poweroff) |

### Developing navi-scripts

The package is tested as part of the flake checks. To run the full test suite including type checking (ty), linting (ruff), and pytest with 100% coverage requirement:

```shell
nix build .#checks.x86_64-linux.navi-scripts
```

To enter a development shell with all dependencies:

```shell
cd packages/navi-scripts
nix develop ../../#
```

The package uses:
- **ty** for type checking
- **ruff** for linting
- **pytest** with pytest-cov for testing (100% coverage required)

### How It's Integrated

The package is added to nixpkgs via an overlay in `lib/overlays.nix`, making it available as `pkgs.navi-scripts`. It's then installed in `home/desktop/default.nix` as part of the desktop environment.

## Development

For basic development testing, run the following command to test.

```shell
nix develop --command test
```

You can run the testing and linting functions directly with

```shell
# Nix code checks
nix build .#checks.x86_64-linux.nixfmt
nix build .#checks.x86_64-linux.statix
nix build .#checks.x86_64-linux.deadnix

# Python package checks (ty, ruff, pytest)
nix build .#checks.x86_64-linux.navi-scripts
```

## Troubleshooting

### Inspecting Configuration Attributes

To inspect what attributes your system configuration is resolving to:

```shell
# Inspect a specific attribute from your NixOS configuration
nix eval .#nixosConfigurations.solaris.config.system.stateVersion

# Inspect custom options like fontScale
nix eval .#nixosConfigurations.solaris.config.home-manager.users.amlesh.my.fontScale

# See all available options for a configuration
nix eval .#nixosConfigurations.solaris.options --apply builtins.attrNames

# Inspect a home-manager attribute
nix eval .#homeConfigurations.generic-linux.config.home.stateVersion
```

### Checking What Will Change

Before applying changes, see what will be rebuilt:

```shell
# For NixOS systems - dry run to see what changes
nixos-rebuild dry-build --flake .#solaris

# Show differences between current and new configuration
nixos-rebuild build --flake .#solaris
nix store diff-closures /run/current-system ./result

# For home-manager
home-manager build --flake .#generic-linux
nix store diff-closures ~/.local/state/home-manager/gcroots/current-home ./result
```

### Common Issues

**Flake evaluation errors:**
```shell
# Show detailed trace for debugging
nix flake check --show-trace

# Validate flake structure
nix flake metadata
```

## Misc

Refer to this for neovim configuration reference
- <https://github.com/zamlz/nix/blob/007d7ffa9c244af4d539fa7b32e8cb2a76ae4d91/shell/neovim.nix>

Useful configs to take a look at:
- <https://github.com/kaleocheng/nix-dots/tree/master>
