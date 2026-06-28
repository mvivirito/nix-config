# M1 MacBook Air — server host.
# Lives lid-closed in a rack: never sleeps, auto-restarts after power loss, and
# is reachable over LAN SSH (Remote Login) + Tailscale. Keeps the full desktop
# config (see home-darwin.nix / shared homebrew) for when it's used directly.
{
  hostname,
  pkgs,
  lib,
  ...
}: {
  networking.hostName = hostname;
  networking.computerName = hostname;

  # This machine was bootstrapped with Determinate Nix, which manages the Nix
  # installation itself. nix-darwin must NOT also manage Nix or activation
  # aborts. (Trade-off: the shared nix.gc/optimise/substituters settings in
  # darwin/configuration.nix are inert here — Determinate enables flakes by
  # default and runs its own GC.) The gc/optimise toggles assert on nix.enable,
  # so force them off here to override the shared defaults.
  nix.enable = false;
  nix.gc.automatic = lib.mkForce false;
  nix.optimise.automatic = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    claude-code
  ];

  # Extra desktop apps for direct use (shared homebrew already covers the rest)
  homebrew.casks = [
    "google-chrome"
    "firefox"
  ];

  # Tailscale via Homebrew (stable binary path at /opt/homebrew/bin that survives
  # updates) + Tailscale's OWN system-daemon installer — the officially supported,
  # robust way to run it headless on macOS. We deliberately do NOT hand-roll a
  # launchd.daemons entry (that proved flaky: no restart on SIGTERM, didn't reload
  # at boot). One-time after the first rebuild:
  #   sudo /opt/homebrew/bin/tailscaled install-system-daemon
  #   sudo tailscale up
  homebrew.brews = [
    "tailscale"
  ];

  # ── Always-on server behaviour ──────────────────────────────────────────
  # Never idle-sleep the machine. (The `pmset disablesleep` flag in the
  # activation script below is what actually keeps it awake with the lid
  # closed and no display/power — the typed option can't express that.)
  power.sleep.computer = "never";

  # Tailscale runs as a system daemon installed by `tailscaled install-system-daemon`
  # (see homebrew.brews above) — not managed here, on purpose.

  # ── SSH hardening drop-in ───────────────────────────────────────────────
  # Remote Login itself is enabled once via System Settings (or
  # `systemsetup -setremotelogin on`). macOS sshd Includes sshd_config.d/*.
  environment.etc."ssh/sshd_config.d/101-server.conf".text = ''
    PermitRootLogin no
    # Password auth stays on for LAN/Tailnet convenience; flip to `no`
    # once your public key is in ~/.ssh/authorized_keys.
    PasswordAuthentication yes
  '';

  # ── Activation: LocalHostName, power flags, tailscale state dir ──────────
  system.activationScripts.postActivation.text = ''
    echo "[m1] setting LocalHostName + power policy"
    /usr/sbin/scutil --set LocalHostName ${hostname} || true
    # Stay awake with the lid closed and no display/power. (No autorestart —
    # this MacBook doesn't support auto-power-on after an outage; its battery
    # acts as a UPS for short outages instead.)
    /usr/bin/pmset -a disablesleep 1 || true
  '';
}
