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
│   │   ├── m1/                  # M1 MacBook Air server (SSH, Tailscale, no-sleep)
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
| `m1` | macOS | Aerospace | M1 MacBook Air — headless server (SSH, Tailscale, Syncthing→iCloud vault bridge; lid-closed, never sleeps) |

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
- macOS personal (`macbook`): `mvivirito`
- macOS server (`m1`): `michaelvivirito`

## macOS `server` Flag

`m1` is a Mac that lives lid-closed in a rack but keeps the full desktop config
for direct use. The differences from `macbook` are:

- A host module `hosts/darwin/m1/default.nix` adds the always-on server bits:
  `power.sleep.computer = "never"` + a `pmset disablesleep 1`/`autorestart 1`
  activation script (stay awake lid-closed, auto-restart after power loss), a
  `launchd.daemons.tailscaled` system daemon, and an SSH hardening drop-in at
  `/etc/ssh/sshd_config.d/`.
- `home-manager.extraSpecialArgs.server = true` makes `home-darwin.nix` import
  `home-manager/darwin/syncthing.nix` (the only server-only home module). All
  desktop modules (Aerospace, Karabiner, Hammerspoon, GUI apps) stay enabled.

Security/recovery posture (deliberate): **auto-login is OFF** and **FileVault is
OFF**. FileVault must stay off so the box boots unattended to the login window
where SSH + Tailscale (system daemons) are reachable — with FileVault on it would
halt at the pre-boot unlock screen before any network. Auto-login is off so the
login window guards the live session if the machine is stolen. Because iCloud and
the Syncthing **user agent** only run inside a GUI (Aqua) session, after a reboot
they stay down until someone logs in — do that remotely via **Screen Sharing**
(VNC over LAN/Tailscale), which starts the session; then lock the screen (or run
`CGSession -suspend` over SSH). Plain SSH gives a shell but does NOT start a GUI
session.

One-time manual steps: Remote Login, Screen Sharing, `tailscale up`, iCloud
sign-in (+ disable "Optimize Mac Storage"), set Lock Screen to require password
immediately, and Syncthing mesh pairing. Leave auto-login and FileVault OFF.

## Important Patterns

1. **Shared modules** in `hosts/nixos/shared/` - locale, networking, audio, fonts
2. **VM modules** in `hosts/nixos/vm/` - composable VM-specific configs
3. **Home-manager** imports from `home-manager/core/` for CLI tools, skip Niri/DMS for KDE VMs
4. **Filesystem labels** - VMs use `/dev/disk/by-label/root` for portability

## Future VM Variants (Planned)

- `nixie-ai` - GPU + CUDA tools for AI/ML workloads
- `nixie-dev` - Lightweight development VM (no GPU)
