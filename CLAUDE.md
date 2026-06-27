# Claude Code Context

This is a multi-platform Nix configuration repository managing NixOS (laptop + VMs) and macOS (personal + work MacBooks).

## Repository Structure

```
nix-config/
├── flake.nix                    # Entry point - all system definitions
├── darwin/                      # macOS system config (nix-darwin)
├── nixos/                       # Shared NixOS desktop modules (Niri, greetd, kanata, theme)
├── hosts/
│   ├── darwin/                  # macOS host-specific configs
│   │   ├── macbook/
│   │   ├── michaelvivirito-mbp/
│   │   └── shared/              # Homebrew, fonts, system prefs
│   └── nixos/
│       ├── thinkpad/            # ThinkPad (thinkpad) host config: hardware + system
│       ├── nixie-vm/            # Proxmox VM (KDE Plasma)
│       ├── vm/                  # Shared VM modules
│       │   ├── base.nix         # QEMU guest, grub, virtio
│       │   ├── desktop/kde.nix  # KDE Plasma + apps + Catppuccin theming
│       │   ├── gpu-passthrough.nix  # NVIDIA passthrough (future)
│       │   └── sunshine.nix     # Sunshine streaming + Avahi
│       └── shared/              # Boot, users, networking, audio, etc.
└── home-manager/
    ├── home.nix                 # Linux entry (Niri/DMS desktop)
    ├── home-darwin.nix          # macOS entry
    ├── core/                    # Cross-platform: zsh, neovim, terminals
    ├── linux/                   # Niri WM, DMS shell, GUI apps
    │   └── kde-gui-apps.nix     # KDE-friendly GUI apps (browsers, media, productivity)
    └── darwin/                  # Aerospace WM, Karabiner
```

## Hosts

| Host | Type | Desktop | Purpose |
|------|------|---------|---------|
| `thinkpad` | NixOS | Niri + DMS | Personal dev laptop |
| `nixie-vm` | NixOS | KDE Plasma | Proxmox VM (RTX 4080 GPU passthrough, Sunshine/NVENC streaming) |
| `macbook` | macOS | Aerospace | Personal MacBook |
| `michaelvivirito-mbp` | macOS | Aerospace | Work MacBook |

## Key Commands

```bash
# NixOS laptop (ThinkPad)
sudo nixos-rebuild switch --flake .#thinkpad

# NixOS VM (Proxmox)
sudo nixos-rebuild switch --flake .#nixie-vm

# macOS
darwin-rebuild switch --flake .#macbook

# Update flake inputs
nix flake update
```

## Adding a New NixOS VM

1. Clone from Proxmox template (after templating nixie-vm)
2. Create `hosts/nixos/<hostname>/` with:
   - `default.nix` - hostname, host-specific config
   - `hardware-configuration.nix` - use `/dev/disk/by-label/root`
   - `home.nix` - import from `home-manager/core/`
3. Add to `flake.nix` nixosConfigurations
4. Run `sudo nixos-rebuild switch --flake .#<hostname>`

## VM Architecture

VMs use composable modules in `hosts/nixos/vm/`:
- `base.nix` - QEMU guest, GRUB, virtio drivers, kernel tuning (zswap, sysctl), disables laptop services
- `desktop/kde.nix` - KDE Plasma 6 + SDDM + auto-login + KDE apps + Catppuccin theming + KDE Connect firewall
- `gpu-passthrough.nix` - NVIDIA GPU passthrough with headless X11 (virtual display for streaming without monitor)
- `sunshine.nix` - Sunshine game streaming with NVENC hardware encoding (Moonlight-compatible) + Avahi mDNS

## Username Convention

- NixOS systems: `michael`
- macOS personal: `mvivirito`
- macOS work: `michaelvivirito`

## Important Patterns

1. **Shared modules** in `hosts/nixos/shared/` - locale, networking, audio, fonts
2. **VM modules** in `hosts/nixos/vm/` - composable VM-specific configs
3. **Home-manager** imports from `home-manager/core/` for CLI tools, skip Niri/DMS for KDE VMs
4. **Filesystem labels** - VMs use `/dev/disk/by-label/root` for portability

## Future VM Variants (Planned)

- `nixie-ai` - GPU + CUDA tools for AI/ML workloads
- `nixie-dev` - Lightweight development VM (no GPU)
