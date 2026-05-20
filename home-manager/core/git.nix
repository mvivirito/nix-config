{ config, lib, pkgs, ... }:
{
  programs.git = {
    enable = true;

    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };

  # Generate ~/.netrc from openclaw secrets.env so non-interactive git
  # (systemd timers, scripts) can push to git.k8s.home without a tty.
  # Idempotent: re-runs each home-manager activation.
  home.activation.writeNetrc = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    secretsFile="${config.home.homeDirectory}/.config/openclaw/secrets.env"
    netrcFile="${config.home.homeDirectory}/.netrc"

    if [ -f "$secretsFile" ]; then
      token=$(${pkgs.gnugrep}/bin/grep -E '^GITEA_TOKEN=' "$secretsFile" | cut -d= -f2-)
      if [ -n "$token" ]; then
        cat > "$netrcFile" <<EOF
machine git.k8s.home
  login michael
  password $token
EOF
        chmod 600 "$netrcFile"
      fi
    fi
  '';

  # Delta for beautiful diffs (moved to top-level per home-manager deprecation)
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = true;
      syntax-theme = "gruvbox-dark";
    };
  };
}
