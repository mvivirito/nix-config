# nix-config

Multi-platform Nix configuration for NixOS (laptop) and macOS (MacBook via nix-darwin).

## Quick Reference

```bash
# NixOS - full system rebuild (boot, kernel, services, user config)
sudo nixos-rebuild switch --flake .#nixos-laptop

# NixOS - user-only rebuild (faster, no sudo)
home-manager switch --flake .#michael@nixos-laptop

# macOS - full system rebuild
darwin-rebuild switch --flake ~/repos/nix-config#macbook

# Update all flake inputs
nix flake update

# Garbage collect old generations
nix-collect-garbage -d
```

> **Note:** On NixOS, use `home-manager switch` for user-level changes (packages, dotfiles, apps).
> The system-level home-manager integration only activates on boot, not on `nixos-rebuild`.

## Hosts

| Host | System | User | Desktop |
|------|--------|------|---------|
| `nixos-laptop` | x86_64-linux | michael | Niri (Wayland) + DMS |
| `macbook` | aarch64-darwin | mvivirito | Aerospace (tiling WM) |

## Directory Structure

```
nix-config/
├── flake.nix                    # Entry point (nixpkgs-unstable)
├── flake.lock                   # Locked dependency versions
│
├── nixos/                       # NixOS system config
│   ├── configuration.nix        # Main entry (imports all modules)
│   ├── niri.nix                 # Niri Wayland compositor
│   ├── greetd.nix               # tuigreet login screen
│   ├── theme.nix                # Catppuccin Mocha theme
│   └── keyd/                    # System keyboard remapping
│       ├── default.nix
│       └── keyd.conf
│
├── darwin/                      # macOS system config
│   └── configuration.nix
│
├── hosts/
│   ├── nixos/
│   │   ├── laptop/              # Laptop-specific (hostname, hardware)
│   │   └── shared/              # Shared modules (boot, users, networking, etc.)
│   └── darwin/
│       ├── macbook/             # MacBook-specific
│       └── shared/              # Homebrew, system-preferences, fonts
│
└── home-manager/                # User-level config
    ├── home.nix                 # Linux entry
    ├── home-darwin.nix          # macOS entry
    ├── core/                    # Cross-platform (zsh, neovim, kitty, tmux)
    │   └── neovim/              # 40+ plugins, LSP, Treesitter
    ├── linux/                   # Linux-specific
    │   ├── niri/                # Niri keybinds, layout, outputs
    │   ├── dms.nix              # Dank Material Shell
    │   └── gui-apps.nix         # Desktop apps
    └── darwin/                  # macOS-specific
        ├── aerospace.nix        # Tiling WM bindings
        ├── karabiner/           # Key remapping
        └── gui-apps.nix
```

## Flake Inputs

| Input | Source | Purpose |
|-------|--------|---------|
| nixpkgs | nixpkgs-unstable | Latest packages |
| home-manager | master | User configuration |
| nix-darwin | master | macOS system config |
| niri | sodiboo/niri-flake | Wayland compositor |
| dms | AvengeMedia/DankMaterialShell | Bar, launcher, notifications, lock |

## What's Managed

### NixOS System
- **Desktop**: Niri (scrolling tiling Wayland compositor)
- **Shell**: DMS (Dank Material Shell - bar, launcher, lock, notifications)
- **Login**: tuigreet with fingerprint support
- **Keyboard**: keyd (system-level remapping)
- **Theme**: Catppuccin Mocha (GTK/Qt)
- **Audio**: PipeWire + ALSA
- **Networking**: NetworkManager + Tailscale
- **Power**: Auto-hibernation after 15min suspended on battery

### macOS System
- **Window Management**: Aerospace tiling WM
- **Keyboard**: Karabiner-Elements (Caps/Cmd remapping)
- **System**: Dock, Finder, keyboard, trackpad preferences
- **Apps**: Managed via Homebrew casks (see `hosts/darwin/shared/homebrew.nix`)
- **Fonts**: Nerd Fonts, Noto, Font Awesome

### Cross-Platform (home-manager)
- **Shell**: zsh + oh-my-zsh (fishy theme) + zoxide
- **Editor**: Neovim (LSP, Treesitter, Telescope, completion)
- **Terminal**: Ghostty (primary), Kitty (fallback)
- **CLI**: bat, ripgrep, fzf, lazygit, htop, tmux, ffmpeg, yt-dlp

---

## Keybindings

### Keyboard Remapping (Both Platforms)

Both NixOS (keyd) and macOS (Karabiner) share consistent low-level keyboard remapping:

| Key | Tap | Hold |
|-----|-----|------|
| Caps Lock | Escape | Super (NixOS) / Ctrl+Alt (macOS) |
| Semicolon | ; | Navigation layer |
| Right Alt (NixOS) | Escape | Super |
| Left Command (macOS) | - | Ctrl+Alt |
| Right Option (macOS) | - | Control |
| Apostrophe | ' | Control |

**Navigation Layer** (hold Semicolon):
| Key | Action |
|-----|--------|
| H | Left Arrow |
| J | Down Arrow |
| K | Up Arrow |
| L | Right Arrow |
| U | ~ (tilde) |
| I | \| (pipe) |

---

### NixOS Keybindings (Niri + keyd)

**Mod = Super (Caps Lock or Right Alt)**

#### Window Management
| Keybind | Action |
|---------|--------|
| Mod + H/J/K/L | Focus left/down/up/right |
| Mod + Shift + H/J/K/L | Move window left/down/up/right |
| Mod + Shift + Q | Close window |
| Mod + F | Maximize column |
| Mod + Shift + F | Fullscreen window |
| Mod + V | Toggle floating |
| Mod + C | Center column (great for ultrawide) |
| Mod + R | Cycle column width presets (1/3, 1/2, 2/3, full) |
| Mod + - / = | Shrink/grow column width 10% |
| Mod + , | Consume window into column |
| Mod + . | Expel window from column |

#### Workspaces
| Keybind | Action |
|---------|--------|
| Mod + 1-9, 0 | Switch to workspace 1-10 |
| Mod + Shift + 1-9, 0 | Move window to workspace 1-10 |
| Mod + Page Up/Down | Focus workspace up/down |
| Mod + Shift + Page Up/Down | Move to workspace up/down |
| Mod + Tab | Toggle overview mode |
| Mod + Scroll | Scroll through workspaces |

#### App Launchers
| Keybind | Action |
|---------|--------|
| Mod + Enter | Ghostty terminal |
| Mod + Space | DMS spotlight (app launcher) |
| Mod + B | Firefox |
| Mod + D | Discord |
| Mod + O | 1Password quick access |
| Mod + Y | Neovim in Ghostty |
| Mod + I | VS Code |
| Mod + Z | VLC |
| Mod + Shift + R | Thunar file manager |

#### System Tools
| Keybind | Action |
|---------|--------|
| Mod + Shift + B | PulseAudio volume control |
| Mod + Shift + M | Mission Center (system monitor) |
| Mod + Shift + Y | htop in Ghostty |
| Mod + Shift + E | Exit Niri |

#### Screenshots
| Keybind | Action |
|---------|--------|
| Mod + G | Selection screenshot → clipboard |
| Mod + Shift + G | Full screenshot → clipboard |
| Mod + Print | Selection screenshot → file |
| Mod + Shift + Print | Full screenshot → file |

#### Media Keys
Standard XF86 media keys for volume, brightness, and playback control.

---

### macOS Keybindings (Aerospace + Karabiner)

**Modifier = Ctrl+Alt (triggered by Caps Lock or Left Command)**

#### Window Management
| Keybind | Action |
|---------|--------|
| Caps + H/J/K/L | Focus left/down/up/right |
| Caps + Shift + H/J/K/L | Move window left/down/up/right |
| Caps + Shift + Q | Quit application (Cmd+Q) |
| Caps + F | Toggle fullscreen |
| Caps + T | Toggle floating/tiling |
| Caps + \\ | Toggle tiles/accordion layout |
| Caps + = | Cycle layout modes |
| Caps + R | Enter resize mode |
| Caps + Shift + T | Enter service mode |

**Resize Mode** (after Caps + R):
| Key | Action |
|-----|--------|
| H/L | Width -/+ 50 |
| J/K | Height +/- 50 |
| Esc/Enter | Exit resize mode |

**Service Mode** (after Caps + Shift + T):
| Key | Action |
|-----|--------|
| R | Flatten workspace tree |
| F | Toggle floating/tiling |
| Caps + Shift + T | Exit service mode |

#### Workspaces
| Keybind | Action |
|---------|--------|
| Caps + 1-9 | Switch to workspace 1-9 |
| Caps + Shift + 1-9 | Move window to workspace 1-9 |

#### App Launchers
| Keybind | Action |
|---------|--------|
| Caps + Enter | Ghostty (new window) |
| Caps + B | Google Chrome (new window) |
| Caps + O | Focus 1Password |
| Caps + Y | Neovim in Ghostty |

---

## Shell Aliases

### Navigation & Editing
| Alias | Command |
|-------|---------|
| v, vi | nvim |
| cat | bat |
| cd | zoxide (z) |
| ls, ll, la | List variants |
| mkdir | mkdir -p |

### Git
| Alias | Command |
|-------|---------|
| ga, gaa | git add / git add . |
| gst | git status |
| gco, gcb | git checkout / checkout -b |
| gc "msg" | git commit -m |
| gca, gcan | git commit --amend (with/without edit) |
| gpush, gpop | git push / pull |
| gbr | git branch |
| glog | git log --oneline -n 10 |
| gd, gds | git diff / diff --staged |
| greb | git rebase -i |
| grh | git reset HEAD |

### Nix
| Alias | Command |
|-------|---------|
| ns | nix-shell |
| nr | nix run |
| nb | nix build |
| nd | nix develop |
| hm | home-manager |

### Claude Code
| Alias | Command |
|-------|---------|
| c | claude |

### Linux Only
| Alias | Command |
|-------|---------|
| nm | nmtui-connect |
| sx | sudo systemctl |
| jctl | journalctl -e |

### macOS Only
| Alias | Command |
|-------|---------|
| flush-dns | Flush DNS cache |
| showfiles | Show hidden files in Finder |
| hidefiles | Hide hidden files in Finder |
| brewup | Update, upgrade, cleanup Homebrew |

---

## Common Tasks

### Add a Homebrew cask (macOS)
Edit `hosts/darwin/shared/homebrew.nix`, add to `casks` list, rebuild.

### Add a CLI tool
Edit `home-manager/core/cli-tools.nix`, add to `home.packages`, rebuild.

### Add a zsh alias
Edit `home-manager/core/zsh.nix`, add to `shellAliases`, rebuild.

### Add a Neovim plugin
Edit `home-manager/core/neovim/default.nix`, add to plugins list, rebuild.

### Add a Niri keybind
Edit `home-manager/linux/niri/default.nix`, add to `binds` section, rebuild.

### Add an Aerospace keybind
Edit `home-manager/darwin/aerospace.nix`, add to `mode.main.binding`, rebuild.

### Modify keyboard remapping
- **NixOS**: Edit `nixos/keyd/keyd.conf`
- **macOS**: Edit `home-manager/darwin/karabiner/karabiner.json`

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `flake.nix` | Flake inputs and system definitions |
| `nixos/configuration.nix` | NixOS system settings |
| `darwin/configuration.nix` | macOS system settings |
| `nixos/keyd/keyd.conf` | NixOS keyboard remapping |
| `hosts/darwin/shared/homebrew.nix` | Managed Homebrew casks |
| `hosts/darwin/shared/system-preferences.nix` | macOS defaults |
| `home-manager/core/zsh.nix` | Shell config + aliases |
| `home-manager/core/neovim/` | Neovim plugins + config |
| `home-manager/linux/niri/default.nix` | Niri keybinds + layout |
| `home-manager/darwin/aerospace.nix` | Aerospace tiling WM bindings |
| `home-manager/darwin/karabiner/karabiner.json` | macOS key remapping |

---

## Troubleshooting

### Home-manager changes not applying (NixOS)
```bash
# Run home-manager directly instead of relying on nixos-rebuild
home-manager switch --flake .#michael@nixos-laptop
```

### Homebrew won't remove a package
```bash
brew uninstall --ignore-dependencies <package>
```

### Nix store corruption
```bash
nix-store --verify --check-contents --repair
```

### Reset to clean state
```bash
darwin-rebuild switch --flake .#macbook --recreate-lock-file
```

### Reload Aerospace config (macOS)
```bash
aerospace reload-config
```

### Restart Aerospace (macOS)
```bash
killall AeroSpace && open -a AeroSpace
```

### Check keyd status (NixOS)
```bash
sudo systemctl status keyd
journalctl -u keyd -e
```

### Verify Niri is running
```bash
pgrep niri
journalctl --user -u niri -e
```

### DMS not starting
```bash
systemctl --user status dms
systemctl --user restart dms
```
