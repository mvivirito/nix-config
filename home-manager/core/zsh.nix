{ pkgs, lib, ... }:
{
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
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
                  "fzf"
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
      ls = "eza --icons";
      la = "eza -la --icons";
      ll = "eza -lh --icons";
      lt = "eza --tree --icons";
      mkdir = "mkdir -p";
      cd = "z";

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
      # Command not found handler - suggests packages to install
      command_not_found_handler() {
        echo "zsh: command not found: $1"
        echo "Did you mean one of these?"
        ${pkgs.nix-index}/bin/nix-index -c "nix-shell -p $1 --run $1" 2>/dev/null || echo "Run 'nix search $1' to find packages"
      }

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
    '';
  };
}

