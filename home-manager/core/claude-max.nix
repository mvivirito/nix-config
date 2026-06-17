# `claude-max` — Claude Code in YOLO mode (skip permissions + max effort),
# auto-trusting the launch dir so the interactive workspace-trust dialog is
# skipped (`--dangerously-skip-permissions` does NOT skip that dialog in
# interactive mode; trust is persisted per-dir in ~/.claude.json instead).
#
# Lives here (core) rather than in the niri module so it installs on EVERY
# Linux host — matching the `cy` alias in core/zsh.nix, which is also Linux-only.
# Previously it shipped only with niri, so on the KDE VM (nixie-vm, no niri)
# the `cy` alias pointed at a missing binary. Backs both `cy` and the Mod+A
# niri launcher.
{ pkgs, lib, ... }:

{
  home.packages = lib.optionals pkgs.stdenv.isLinux [
    (pkgs.writeShellScriptBin "claude-max" ''
      set -u
      cfg="$HOME/.claude.json"
      dir="$(${pkgs.coreutils}/bin/pwd)"
      jq="${pkgs.jq}/bin/jq"

      if [ -f "$cfg" ]; then
        tmp="$(${pkgs.coreutils}/bin/mktemp "$cfg.XXXXXX")"
        if "$jq" --arg d "$dir" \
            '.projects[$d] = ((.projects[$d] // {}) + { hasTrustDialogAccepted: true })' \
            "$cfg" > "$tmp" 2>/dev/null; then
          ${pkgs.coreutils}/bin/mv "$tmp" "$cfg"
        else
          ${pkgs.coreutils}/bin/rm -f "$tmp"
        fi
      else
        "$jq" -n --arg d "$dir" \
          '{ projects: { ($d): { hasTrustDialogAccepted: true } } }' > "$cfg"
      fi

      exec ${pkgs.claude-code}/bin/claude --dangerously-skip-permissions --effort max "$@"
    '')
  ];
}
