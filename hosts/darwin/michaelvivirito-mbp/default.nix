# Work MacBook (michaelvivirito-mbp) configuration
# Hostname managed by Chef/IT, not Nix
{ ... }: {
  # Do NOT set networking.hostName or computerName - let Chef manage it

  # Meta-specific paths (Claude launcher, pastry, etc.)
  environment.systemPath = [ "/opt/facebook/bin" "/usr/local/bin" ];
}
