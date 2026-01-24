# nix-config

Multi-platform Nix configuration for NixOS (laptop) and macOS (MacBook via nix-darwin).

## Quick Start

```bash
# macOS rebuild
darwin-rebuild switch --flake ~/repos/nix-config#macbook

# NixOS rebuild
sudo nixos-rebuild switch --flake ~/repos/nix-config#nixos-laptop

# Update all flake inputs
nix flake update

# Garbage collect old generations
nix-collect-garbage -d
```

## Structure

```
nix-config/
├── flake.nix              # Entry point (nixpkgs-unstable)
├── darwin/                # macOS system config
├── nixos/                 # NixOS system config
├── hosts/
│   ├── darwin/            # macOS hosts + shared modules
│   └── nixos/             # NixOS hosts + shared modules
└── home-manager/
    ├── home.nix           # Linux entry
    ├── home-darwin.nix    # macOS entry
    ├── core/              # Cross-platform (zsh, neovim, kitty)
    ├── darwin/            # macOS-specific
    └── linux/             # Linux-specific (hyprland, waybar)
```

## Hosts

| Host | System | Description |
|------|--------|-------------|
| `macbook` | aarch64-darwin | MacBook (Apple Silicon) |
| `nixos-laptop` | x86_64-linux | NixOS laptop |

## What's Managed

### macOS (nix-darwin)
- **System**: Dock, Finder, keyboard, trackpad, screenshots
- **Homebrew**: GUI apps (see `hosts/darwin/shared/homebrew.nix`)
- **Fonts**: Nerd Fonts, Noto, Font Awesome
- **Window Management**: Aerospace tiling WM + Karabiner key remapping

### Cross-Platform (home-manager)
- **Shell**: zsh + oh-my-zsh + zoxide
- **Editor**: Neovim (LSP, Treesitter, Telescope, etc.)
- **Terminal**: Kitty (Catppuccin theme)
- **CLI**: bat, ripgrep, fzf, lazygit, htop, tmux, ffmpeg, yt-dlp

### Linux-Only
- Hyprland (Wayland compositor)
- Waybar, Rofi, Swaylock
- GTK/Qt theming

## Key Files

| File | Purpose |
|------|---------|
| `flake.nix` | Flake inputs and system definitions |
| `darwin/configuration.nix` | macOS system settings |
| `hosts/darwin/shared/homebrew.nix` | Managed Homebrew casks |
| `hosts/darwin/shared/system-preferences.nix` | macOS defaults |
| `home-manager/core/zsh.nix` | Shell config + aliases |
| `home-manager/core/neovim/` | Neovim plugins + config |
| `home-manager/core/kitty.nix` | Terminal settings |
| `home-manager/darwin/aerospace.nix` | Aerospace tiling WM bindings |
| `home-manager/darwin/karabiner/karabiner.json` | Karabiner key remapping |

## Common Tasks

### Add a Homebrew cask
Edit `hosts/darwin/shared/homebrew.nix`, add to `casks` list, rebuild.

### Add a CLI tool
Edit `home-manager/core/cli-tools.nix`, add to `home.packages`, rebuild.

### Add a zsh alias
Edit `home-manager/core/zsh.nix`, add to `shellAliases`, rebuild.

### Add a Neovim plugin
Edit `home-manager/core/neovim/default.nix`, add to plugins list, rebuild.

## Aliases Cheatsheet

```bash
# Navigation
v, vi          → nvim
cat            → bat
cd             → zoxide
ll, la         → ls variants

# Git
ga, gaa        → git add
gst            → git status
gc "msg"       → git commit -m
gpush, gpop    → git push/pull
glog           → git log --oneline
gd, gds        → git diff (staged)

# Nix
ns             → nix-shell
nr             → nix run
nb             → nix build
nd             → nix develop

# macOS only
flush-dns      → Flush DNS cache
showfiles      → Show hidden files in Finder
hidefiles      → Hide hidden files in Finder
brewup         → Update Homebrew

# Linux only
nm             → nmtui-connect
sx             → sudo systemctl
jctl           → journalctl -e
```

## Aerospace Keybindings (macOS)

Caps Lock and Left Command both trigger Aerospace via Karabiner (Right Command remains normal for macOS shortcuts).

```bash
# Window Focus
Caps + H/J/K/L     → Focus left/down/up/right

# Move Windows
Caps + Shift + H/J/K/L → Move window left/down/up/right

# Workspaces
Caps + 1-9         → Switch to workspace
Caps + Shift + 1-9 → Move window to workspace

# Window Operations
Caps + F           → Toggle fullscreen
Caps + Space       → Toggle floating/tiling
Caps + \           → Toggle tiles/accordion layout
Caps + R           → Resize mode (then hjkl)

# App Launchers
Caps + Enter       → Open Ghostty (new window)
Caps + B           → Open Chrome (new window)
Caps + O           → Focus 1Password
Caps + Y           → Open Neovim in Ghostty

# Karabiner-only
Caps tap           → Escape
Caps + A           → Toggle actual Caps Lock
; + H/J/K/L        → Arrow keys
; + U              → ~ (tilde)
; + I              → | (pipe)
Right Option       → Control
```

## Troubleshooting

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

### Reload Aerospace config
```bash
aerospace reload-config
```

### Restart Aerospace
```bash
killall AeroSpace && open -a AeroSpace
```
