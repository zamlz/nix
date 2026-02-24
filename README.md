# NixOS Configuration ❄

A (WIP) NixOS Configuration repo for all my systems.

## New Installation Guide

### NixOS

First, install a minimal installation of NixOS.

Next, once you get into the system. Create a new entry for the
system in the `nixosConfigurations`. This will require copying the
`hardware-configuration.nix` file into the config as well.  Be sure to
also go through the `configuration.nix` and set the relevant parameters
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
anymore there is a disconnect. You may need to manually configure the host
system to properly integrate with nix (e.g., disabling conflicting system
services like ssh-agent or smartcard daemons).

Use the following for the first time install (since home-manager is
not present in an environment yet). It uses home manager from github to
bootstrap the installation.

```shell
# CLI tools only (headless/server environments)
nix run github:nix-community/home-manager -- switch --flake .#generic-cli

# CLI + desktop applications
nix run github:nix-community/home-manager -- switch --flake .#generic-desktop
```

## Basic Usage

### NixOS

Install the nixos system. Note this command is hardware dependent. We use the
hostname to associate hardware.

```shell
sudo nixos-rebuild switch --flake .#${hostname}
```

If `nh` is available on the system, you can simply do

```shell
nh os switch .
```

### Other Linux Distros and Mac
All future invocations in the environment should have `home-manager` present.

```shell
home-manager switch --flake .#generic-cli      # CLI only
home-manager switch --flake .#generic-desktop  # CLI + desktop
```

## Secrets Management (sops-nix)

Secrets are encrypted in the repo using [sops-nix](https://github.com/Mic92/sops-nix) with AGE encryption. Decryption happens automatically at NixOS activation time via a systemd service, with decrypted secrets written to `/run/secrets/` (tmpfs, never hits disk).

### Initial Setup (per machine)

**1. Generate an AGE key pair (once, on your workstation):**

```shell
nix run nixpkgs#age -- -keygen -o age-key.txt
```

Save the printed public key (`age1abc...`) — it goes in `.sops.yaml`.

**2. Place the private key on each NixOS host:**

```shell
sudo mkdir -p /etc/age
sudo cp age-key.txt /etc/age/key.txt
sudo chown root /etc/age/key.txt
sudo chmod 400 /etc/age/key.txt
```

Repeat for every machine (solaris, xynthar, yggdrasil, alexandria). You can use the same key across all machines or generate one per machine.

**3. Back up the private key** in your password store or offline. If lost, you must generate a new key and re-encrypt all secrets.

### Adding / Editing Secrets

**Create or edit secrets:**

```shell
# Opens $EDITOR with decrypted values, re-encrypts on save
# Requires the AGE private key at /etc/age/key.txt (may need sudo)
sudo SOPS_AGE_KEY_FILE=/etc/age/key.txt nix run nixpkgs#sops -- secrets.yaml
```

The `.sops.yaml` file in the repo root defines which AGE public keys can decrypt secrets. Both `.sops.yaml` and the encrypted `secrets.yaml` are safe to commit — values are encrypted, only key names are plaintext.

Per-service secrets (e.g., `grafana-secret-key`) are defined in their respective service modules, while shared secrets (e.g., `user-password`) are defined in `nixos/modules/sops.nix`.

## Directory Structure

The following directory stores my `home-manager` configurations. They
are sorted into their respective tools, `cli` and `desktop`.

```
home/
  options.nix
  cli/
    default.nix
    git.nix
    kakoune/
    ...
  desktop/
    default.nix
    alacritty.nix
    x11/
    wayland/
    ...
```

Every machine has its own directory. NixOS machines have `configuration.nix`
and `hardware-configuration.nix`. All machines have a `home.nix` that imports
from `home/cli` and/or `home/desktop`.

```
hosts/
  default.nix           # Host registry (shared by nixosConfigurations and homeConfigurations)
  solaris/
    configuration.nix
    hardware-configuration.nix
  xynthar/
    configuration.nix
    hardware-configuration.nix
  yggdrasil/
    configuration.nix
    hardware-configuration.nix
  alexandria/
    configuration.nix
    hardware-configuration.nix
  generic-cli/
    home.nix
  generic-desktop/
    home.nix
```

All NixOS system level configurations
```
nixos/
  desktop.nix
  server.nix
  modules/
    audio.nix
    fail2ban.nix
    networking.nix
    nix.nix
    security.nix
    sops.nix
    ...
  services/
    alexandria-nas-nfs.nix
    blocky.nix
    glances.nix
    grafana.nix
    homepage-dashboard.nix
    jellyfin.nix
    kavita.nix
    ollama.nix
    prometheus.nix
    prometheus-node-exporter.nix
```

Flake checks and NixOS VM integration tests
```
checks/
  default.nix         # Combines all checks, handles Linux-only gating
  nixfmt.nix          # Nix code formatting
  statix.nix          # Nix linting
  deadnix.nix         # Dead code detection
  navi-scripts.nix    # Python package tests (ty, ruff, pytest)
  ssh-hardening.nix   # VM test: SSH + fail2ban
  firewall.nix        # VM test: port filtering
  nfs-mount.nix       # VM test: NFS server/client
  clamav.nix          # VM test: antivirus services
```

Shared library code used across configurations
```
lib/
  builders.nix
  colorschemes.nix
  constants.nix
  devshell.nix
  overlays.nix
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
| `navi-todo`          | Todo/task viewer                        |
| `navi-ripgrep`       | Interactive ripgrep search              |
| `navi-system`        | System actions (lock, reboot, poweroff) |
| `navi-term`          | Spawn terminal (abstracts emulators)    |

See [packages/navi-scripts/README.md](packages/navi-scripts/README.md) for detailed documentation on window manager abstraction, runtime dependencies, and architecture.

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

# NixOS VM integration tests
nix build .#checks.x86_64-linux.ssh-hardening
nix build .#checks.x86_64-linux.firewall
nix build .#checks.x86_64-linux.nfs-mount
nix build .#checks.x86_64-linux.clamav
```

### VM Tests

NixOS VM tests spin up lightweight QEMU virtual machines and run assertions against them, verifying that modules work correctly at runtime. They are defined in `checks/` and run as part of `nix flake check` on Linux.

| Test | Description |
| --- | --- |
| `ssh-hardening` | Verifies SSH rejects root login and password auth, fail2ban is active with SSH jail |
| `firewall` | Verifies only explicitly opened ports are reachable, all others are blocked |
| `nfs-mount` | Verifies NFS server exports are mountable and files are readable from a client |
| `clamav` | Verifies ClamAV daemon and fangfrisch timer are enabled, binaries are available |

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
