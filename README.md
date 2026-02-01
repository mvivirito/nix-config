# nix-config

Multi-platform Nix configuration for NixOS (laptop) and macOS (personal + work MacBooks via nix-darwin).

## Quick Start

```bash
# NixOS - full system rebuild (boot, kernel, services, system packages)
sudo nixos-rebuild switch --flake .#nixos-laptop

# NixOS - user config only (dotfiles, user packages, themes — no sudo, faster)
home-manager switch --flake .#michael@nixos-laptop

# macOS - personal machine
darwin-rebuild switch --flake ~/repos/nix-config#macbook

# macOS - work machine
darwin-rebuild switch --flake ~/repos/nix-config#michaelvivirito-mbp

# Update all flake inputs
nix flake update

# Garbage collect old generations
nix-collect-garbage -d
```

> **Note:** On NixOS, use `home-manager switch` for user-level changes (no sudo, faster).
> The system-level home-manager integration only activates on boot, not on `nixos-rebuild`.

## Hosts

| Host | System | Arch | Description |
|------|--------|------|-------------|
| `nixos-laptop` | NixOS | x86_64-linux | Personal dev laptop (Intel, LUKS encrypted, NVMe) |
| `macbook` | macOS | aarch64-darwin | Personal MacBook (Apple Silicon) |
| `michaelvivirito-mbp` | macOS | aarch64-darwin | Work MacBook (Apple Silicon) |

## Flake Inputs

| Input | Source | Purpose |
|-------|--------|---------|
| `nixpkgs` | `nixos/nixpkgs/nixpkgs-unstable` | Package repository |
| `home-manager` | `nix-community/home-manager/master` | User dotfile management |
| `nix-darwin` | `LnL7/nix-darwin/master` | macOS system configuration |
| `niri` | `sodiboo/niri-flake` | Wayland scrollable compositor |
| `dms` | `AvengeMedia/DankMaterialShell/stable` | Desktop shell (bar, launcher, lock, notifications) |

## Structure

```
nix-config/
├── flake.nix                    # Entry point — inputs and system definitions
├── darwin/                      # macOS system config (nix-darwin module)
├── nixos/                       # NixOS system config
│   ├── configuration.nix        # Main NixOS settings
│   ├── greetd.nix               # TUI login manager
│   ├── niri.nix                 # Niri compositor system module
│   ├── theme.nix                # Console colors (Catppuccin Mocha)
│   └── keyd/                    # System-level keyboard remapping
├── hosts/
│   ├── darwin/
│   │   ├── macbook/             # Personal Mac host
│   │   ├── michaelvivirito-mbp/ # Work Mac host
│   │   └── shared/              # Homebrew casks, system prefs, fonts
│   └── nixos/
│       ├── laptop/              # Laptop hardware, host overrides
│       └── shared/              # Boot, users, networking, audio, power, fonts
└── home-manager/
    ├── home.nix                 # Linux entry point
    ├── home-darwin.nix          # macOS entry point
    ├── appearance.nix           # GTK/Qt theming (Linux)
    ├── core/                    # Cross-platform: zsh, neovim, alacritty, kitty, tmux, cli-tools
    ├── linux/                   # Niri WM config, DMS shell, GUI apps
    └── darwin/                  # Aerospace WM, Karabiner remapping, GUI apps
```

## What's Managed

### NixOS (System-Level)
- **Compositor:** Niri (Wayland scrollable tiling)
- **Desktop Shell:** DMS — bar, launcher, lock screen, notifications, clipboard, screenshots, power menu
- **Login:** greetd + tuigreet (remembers last session)
- **Audio:** PipeWire (with PulseAudio + ALSA compat)
- **Networking:** NetworkManager + Tailscale VPN (`--operator=michael`)
- **Auth:** Fingerprint (fprintd), 1Password, polkit
- **Keyboard:** keyd (system-level key remapping)
- **Power:** Suspend on lid close, auto-hibernate after 15 min on battery
- **Theme:** Catppuccin Mocha (console, GTK, Qt, icons)
- **Boot:** systemd-boot, LUKS encryption, 10 generations max

### macOS (nix-darwin)
- **System Prefs:** Dock, Finder, keyboard, trackpad, screenshots
- **Homebrew Casks:** GUI apps managed declaratively (see `hosts/darwin/shared/homebrew.nix`)
- **Window Management:** Aerospace tiling WM + Karabiner key remapping
- **Fonts:** Nerd Fonts, Noto, Font Awesome

### Cross-Platform (home-manager)
- **Shell:** zsh + oh-my-zsh (fishy theme) + zoxide + vi-mode
- **Editor:** Neovim (40+ plugins, 10 LSP servers, Tokyonight theme)
- **Terminals:** Alacritty (primary), Kitty (secondary)
- **Multiplexer:** tmux (Catppuccin Mocha, vim-style panes)
- **CLI:** bat, ripgrep, fzf, lazygit, htop, wget, ffmpeg, yt-dlp
- **Git:** Configured with extensive aliases

## Key Files

| File | Purpose |
|------|---------|
| `flake.nix` | Flake inputs and all system/host definitions |
| `nixos/keyd/keyd.conf` | System keyboard remapping (Linux) |
| `home-manager/linux/niri/default.nix` | Niri WM keybindings and layout (Linux) |
| `home-manager/linux/dms.nix` | Desktop shell config (Linux) |
| `home-manager/darwin/aerospace.nix` | Aerospace WM keybindings (macOS) |
| `home-manager/darwin/karabiner/karabiner.json` | Key remapping rules (macOS) |
| `home-manager/core/zsh.nix` | Shell config, aliases, functions |
| `home-manager/core/neovim/` | Neovim plugins, LSP, keymaps |
| `home-manager/core/terminals.nix` | Alacritty settings |
| `home-manager/core/tmux.nix` | Tmux config |
| `hosts/darwin/shared/homebrew.nix` | Managed Homebrew casks |
| `hosts/nixos/shared/networking.nix` | NetworkManager + Tailscale |
| `hosts/nixos/shared/hibernate.nix` | Auto-hibernate on battery |

## Common Tasks

### Add a Homebrew cask (macOS)
Edit `hosts/darwin/shared/homebrew.nix`, add to `casks` list, rebuild.

### Add a CLI tool (cross-platform)
Edit `home-manager/core/cli-tools.nix`, add to `home.packages`, rebuild.

### Add a Linux GUI app
Edit `home-manager/linux/gui-apps.nix`, add package, rebuild with `home-manager switch`.

### Add a zsh alias
Edit `home-manager/core/zsh.nix`, add to `shellAliases`, rebuild.

### Add a Neovim plugin
Edit `home-manager/core/neovim/default.nix`, add to plugins list, rebuild.

### Add an LSP server
Edit `home-manager/core/neovim/config/setup/lspconfig.lua`, add server config, rebuild.

### Change Niri keybindings (Linux)
Edit `home-manager/linux/niri/default.nix`, modify `config.binds`, rebuild with `home-manager switch`.

### Change Aerospace keybindings (macOS)
Edit `home-manager/darwin/aerospace.nix`, modify binding sets, rebuild then `aerospace reload-config`.

---

## Keybindings — NixOS (Linux)

### System Keyboard Remapping (keyd)

These are always active at the system level, before any application sees the keys.

| Key | Tap | Hold |
|-----|-----|------|
| Caps Lock | Escape | Super/Meta |
| Right Alt | Escape | Super/Meta |
| Apostrophe (`'`) | `'` | Control |
| Semicolon (`;`) | `;` | Activate nav layer |
| Control | — | Oneshot control (tap-release) |
| Shift | — | Oneshot shift (tap-release) |

**Semicolon Nav Layer** (hold `;` then press):

| Key | Action |
|-----|--------|
| `;` + `H` | Left arrow |
| `;` + `J` | Down arrow |
| `;` + `K` | Up arrow |
| `;` + `L` | Right arrow |
| `;` + `U` | `~` (tilde) |
| `;` + `I` | `\|` (pipe) |

### Niri Window Manager (Mod = Super/Meta)

**Window Management:**

| Binding | Action |
|---------|--------|
| `Mod+Shift+Q` | Close focused window |
| `Mod+F` | Maximize column |
| `Mod+Shift+F` | Fullscreen window |
| `Mod+V` | Toggle floating/tiling |

**Focus (vim-style):**

| Binding | Action |
|---------|--------|
| `Mod+H/J/K/L` | Focus left/down/up/right |
| `Mod+Arrow keys` | Same with arrow keys |

**Move Windows:**

| Binding | Action |
|---------|--------|
| `Mod+Shift+H/J/K/L` | Move column left/down/up/right |
| `Mod+Shift+Arrow keys` | Same with arrow keys |

**Column Controls (Niri-specific):**

| Binding | Action |
|---------|--------|
| `Mod+C` | Center column on screen |
| `Mod+R` | Cycle preset widths (1/3 → 1/2 → 2/3 → full) |
| `Mod+Minus` | Shrink column width 10% |
| `Mod+Equal` | Grow column width 10% |
| `Mod+Comma` | Consume window into column |
| `Mod+Period` | Expel window from column |

**Workspaces:**

| Binding | Action |
|---------|--------|
| `Mod+1-9, 0` | Focus workspace 1-10 |
| `Mod+Shift+1-9, 0` | Move column to workspace 1-10 |
| `Mod+Page_Down/Up` | Focus next/prev workspace |
| `Mod+Shift+Page_Down/Up` | Move column to next/prev workspace |
| `Mod+Tab` | Toggle overview (birds-eye) |
| `Mod+Scroll Up/Down` | Scroll through workspaces |

**Application Launchers:**

| Binding | Action |
|---------|--------|
| `Mod+Return` | Alacritty terminal |
| `Mod+Space` | DMS spotlight launcher |
| `Mod+B` | Firefox |
| `Mod+D` | Discord |
| `Mod+O` | 1Password quick access |
| `Mod+Y` | Alacritty + Neovim |
| `Mod+I` | VS Code |
| `Mod+Z` | VLC |
| `Mod+Shift+R` | Alacritty + Yazi file manager |
| `Mod+Shift+D` | Open latest PDF from ~/Downloads (Zathura) |

**System:**

| Binding | Action |
|---------|--------|
| `Mod+Shift+M` | Mission Center (system monitor) |
| `Mod+Shift+Y` | Alacritty + htop |
| `Mod+Shift+E` | Exit Niri |
| `Mod+Shift+P` | DMS power menu |
| `Mod+Shift+V` | DMS clipboard history |

**Screenshots:**

| Binding | Action |
|---------|--------|
| `Mod+G` | Screenshot region → clipboard |
| `Mod+Shift+G` | Full screenshot → clipboard |
| `Mod+Print` | Screenshot region → file |
| `Mod+Shift+Print` | Full screenshot → file |

**Media/Hardware Keys:**

| Key | Action |
|-----|--------|
| Volume Up/Down | ±5% volume |
| Mute | Toggle mute |
| Play/Pause | Media play/pause |
| Next/Prev | Media next/previous |
| Brightness Up/Down | ±5% brightness |

---

## Keybindings — macOS

### Karabiner Key Remapping

Always active at the system level.

| Key | Tap | Hold |
|-----|-----|------|
| Caps Lock | Escape | Ctrl+Alt (Aerospace modifier) |
| Left Command | — | Ctrl+Alt (Aerospace modifier) |
| Right Option | — | Left Control |
| Apostrophe (`'`) | `'` | Left Control |

> Right Command remains normal for standard macOS shortcuts (Cmd+C, Cmd+V, etc.)

**Semicolon Nav Layer** (hold `;` then press):

| Key | Action |
|-----|--------|
| `;` + `H` | Left arrow |
| `;` + `J` | Down arrow |
| `;` + `K` | Up arrow |
| `;` + `L` | Right arrow |
| `;` + `U` | `~` (tilde) |
| `;` + `I` | `\|` (pipe) |

**Other:**

| Binding | Action |
|---------|--------|
| `Ctrl+Alt+Shift+Q` | Quit application (sends Cmd+Q) |

### Aerospace Tiling WM (Ctrl+Alt = Caps Lock or Left Cmd)

**Focus:**

| Binding | Action |
|---------|--------|
| `Ctrl+Alt+H/J/K/L` | Focus left/down/up/right |

**Move Windows:**

| Binding | Action |
|---------|--------|
| `Ctrl+Alt+Shift+H/J/K/L` | Move window left/down/up/right |

**Workspaces:**

| Binding | Action |
|---------|--------|
| `Ctrl+Alt+1-9` | Switch to workspace 1-9 |
| `Ctrl+Alt+Shift+1-9` | Move window to workspace 1-9 |

**Window Operations:**

| Binding | Action |
|---------|--------|
| `Ctrl+Alt+F` | Toggle fullscreen |
| `Ctrl+Alt+T` | Toggle floating/tiling |
| `Ctrl+Alt+\` | Toggle tiles/accordion layout |
| `Ctrl+Alt+=` | Cycle all layout options |
| `Ctrl+Alt+Shift+Q` | Quit focused app |
| `Ctrl+Alt+R` | Enter resize mode (then H/J/K/L, Esc to exit) |
| `Ctrl+Alt+Shift+E` | Toggle Aerospace on/off |

**Application Launchers:**

| Binding | Action |
|---------|--------|
| `Ctrl+Alt+Return` | Open Alacritty |
| `Ctrl+Alt+B` | Open Google Chrome |
| `Ctrl+Alt+O` | Focus 1Password |
| `Ctrl+Alt+Y` | Open Alacritty + Neovim |

---

## Neovim Keybindings

**Leader key: Space**

### Navigation & Search (Telescope)

| Binding | Action |
|---------|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Help tags |
| `<leader>fd` | Find diagnostics |
| `<leader>fi` | Find implementations |
| `<leader>fr` | Find references |
| `<leader>fs` | Document symbols |

### LSP

| Binding | Action |
|---------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<C-k>` | Signature help |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>fm` | Format buffer |
| `<leader>D` | Type definition |
| `<leader>e` | Open diagnostic float |
| `<leader>dn/dp` | Next/prev diagnostic |

### Trouble (Diagnostics Panel)

| Binding | Action |
|---------|--------|
| `<leader>tt` | Document diagnostics |
| `<leader>tw` | Buffer diagnostics |
| `<leader>tq` | Quickfix list |
| `<leader>td` | LSP definitions |
| `<leader>tr` | LSP references |

### Harpoon (Quick File Nav)

| Binding | Action |
|---------|--------|
| `<leader>ha` | Add file to harpoon |
| `<C-e>` | Harpoon menu |
| `<C-h/j/k/l>` | Jump to harpoon file 1-4 |

### Git

| Binding | Action |
|---------|--------|
| `<leader>lg` | Open LazyGit |

### Other

| Binding | Action |
|---------|--------|
| `<leader>oo` | Oil file explorer |
| `<leader>he` | Switch header/source (C/C++) |
| `<leader>qn/qp` | Next/prev quickfix |
| `Ctrl+\` | Toggle floating terminal |

### Treesitter Text Objects

| Binding | Action |
|---------|--------|
| `aa/ia` | Select around/inside function parameter |
| `af/if` | Select around/inside function |
| `ac/ic` | Select around/inside class |
| `]m/[m` | Jump to next/prev function start |
| `]M/[M` | Jump to next/prev function end |
| `<leader>a/A` | Swap next/prev parameter |

### Completion (nvim-cmp)

| Binding | Action |
|---------|--------|
| `<C-p>/<C-n>` | Select prev/next item |
| `<C-Space>` | Trigger completion |
| `<C-e>` | Abort completion |
| `<CR>` | Confirm selection |

---

## Tmux Keybindings

Default prefix: `Ctrl+B`

| Binding | Action |
|---------|--------|
| `Prefix+h/j/k/l` | Select pane (vim-style) |
| `Prefix+H/J/K/L` | Resize pane (5 cells) |
| Mouse | Enabled (click panes, scroll) |

---

## Shell Aliases

```bash
# Navigation
v, vi          → nvim
ls             → ls --color=auto
la             → ls -la
ll             → ls -lh
cd             → z (zoxide smart navigation)

# Git
ga, gaa        → git add / git add .
gst            → git status
gc "msg"       → git commit -m
gca            → git commit --amend
gcan           → git commit --amend --no-edit
gpush, gpop    → git push / git pull
gpom           → git push origin master
glog           → git log --oneline -n 10
gd, gds        → git diff / git diff --staged
gco, gcb       → git checkout / git checkout -b
greb           → git rebase -i
gsq            → git rebase -i HEAD~ (squash)
grh            → git reset HEAD
gbr            → git branch
glf            → git log --oneline --follow

# Nix
ns             → nix-shell
hm             → home-manager
nr             → nix run
nb             → nix build
nd             → nix develop

# General
q              → exit
cl             → clear
c              → claude

# Linux only
nm             → nmtui-connect (wifi)
sx             → sudo systemctl
jctl           → journalctl -e

# macOS only
flush-dns      → Flush DNS cache
showfiles      → Show hidden files in Finder
hidefiles      → Hide hidden files in Finder
brewup         → brew update && upgrade && cleanup
```

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

### Reload Aerospace config (macOS)
```bash
aerospace reload-config
```

### Restart Aerospace (macOS)
```bash
killall AeroSpace && open -a AeroSpace
```

### Restart DMS (Linux)
```bash
systemctl --user restart dank-material-shell
```

### Check Niri logs (Linux)
```bash
journalctl --user -u niri-session -e
```

### Fingerprint not working (NixOS)
```bash
# Re-enroll fingerprints
sudo fprintd-enroll michael
```

### Tailscale not connecting
```bash
# Check status
tailscale status
# Login again
sudo tailscale up
```
