{ pkgs, ... }:
{
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
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
      v = "vim";
      cat = "bat";
      gpom = "git push origin master";
    };
    initExtra = ''
    '';
  };
}

