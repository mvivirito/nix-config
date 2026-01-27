# Work MacBook (michaelvivirito-mbp) configuration
# Hostname managed by Chef/IT, not Nix
{ ... }: {
  # Do NOT set networking.hostName or computerName - let Chef manage it
  # Homebrew uses same zap cleanup as personal machine
}
