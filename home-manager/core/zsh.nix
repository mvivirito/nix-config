{ pkgs, lib, ... }:
{
  # `claude-max` wrapper backing the `cy` alias below (Linux-only, like the alias).
  imports = [ ./claude-max.nix ];

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    # Replace `cd` itself with zoxide (smart cd; handles real paths too).
    # Avoids the old `cd = "z"` alias that tripped zoxide's "configuration issue" doctor warning.
    options = [ "--cmd" "cd" ];
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;  # Ctrl-R history, Ctrl-T files, Alt-C cd — reliably wired
  };
  # Working command-not-found + comma (`, foo` runs foo without installing),
  # backed by a prebuilt, auto-updated nix-index database (see flake input).
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;  # Better nix integration
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      theme = "fishy";
      plugins = [
                  "git"
                  "sudo"
                  "vi-mode"
                ];
    };
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
    ];
    shellAliases = {
      # Quick navigation
      v = "nvim";
      vi = "nvim";
      ls = "eza";
      la = "eza -la";
      ll = "eza -lh";
      lt = "eza --tree";
      mkdir = "mkdir -p";

      # Git shortcuts
      ga = "git add";
      gaa = "git add .";
      gst = "git status";
      gco = "git checkout";
      gcb = "git checkout -b";
      gc = "git commit -m";
      gca = "git commit --amend";
      gcan = "git commit --amend --no-edit";
      gpush = "git push";
      gpop = "git pull";
      gpom = "git push origin master";
      gbr = "git branch";
      glog = "git log --oneline -n 10";
      gd = "git diff";
      gds = "git diff --staged";
      glf = "git log --oneline --follow";
      greb = "git rebase -i";
      grh = "git reset HEAD";
      gsq = "git rebase -i HEAD~";

      # Development/Build shortcuts
      ns = "nix-shell";
      hm = "home-manager";
      nr = "nix run";
      nb = "nix build";
      nd = "nix develop";

      # Common typos/variants
      q = "exit";
      cl = "clear";

      # Claude Code
      c = "claude";
    } // lib.optionalAttrs pkgs.stdenv.isLinux {
      # Linux-specific aliases
      # Claude YOLO: skip permissions + max effort, auto-trusting the cwd
      # (same wrapper as the Mod+A niri launcher)
      cy = "claude-max";
      nm = "nmtui-connect";
      sx = "sudo systemctl";
      jctl = "journalctl -e";
    } // lib.optionalAttrs pkgs.stdenv.isDarwin {
      # macOS-specific aliases
      flush-dns = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
      showfiles = "defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder";
      hidefiles = "defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder";
      brewup = "brew update && brew upgrade && brew cleanup";
    };
    initContent = ''
      # fix for alacritty term not recognized on remote servers
      if [[ "$TERM" == "alacritty" ]]; then
        ssh() { TERM=xterm-256color command ssh "$@"; }
      fi
      # command-not-found is provided by programs.nix-index (above), which
      # suggests the package(s) providing a missing command from its database.

      # Enhanced prompt with git info
      setopt PROMPT_SUBST
      
      # History options
      setopt HIST_FIND_NO_DUPS
      setopt HIST_SAVE_NO_DUPS
      setopt INC_APPEND_HISTORY

      # Warn before exiting with background jobs (works when typing 'exit')
      setopt CHECK_JOBS
      
      # Keybindings
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward
      bindkey '^[^?' backward-kill-word

      # Ctrl+V to paste from clipboard (cross-platform)
      paste-from-clipboard() {
        if [[ "$(uname)" == "Darwin" ]]; then
          LBUFFER+=$(pbpaste 2>/dev/null)
        else
          LBUFFER+=$(wl-paste -n 2>/dev/null)
        fi
      }
      zle -N paste-from-clipboard
      bindkey '^V' paste-from-clipboard

      # Source OpenClaw secrets (if present)
      [[ -f ~/.config/openclaw/secrets.env ]] && source ~/.config/openclaw/secrets.env

      # Vault: code snippet capture function
      [[ -f ~/vault/.scripts/vault-clip.zsh ]] && source ~/vault/.scripts/vault-clip.zsh
    '';
  };
}

