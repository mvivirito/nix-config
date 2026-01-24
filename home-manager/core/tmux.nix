{ pkgs, ... }:

{
  # Cross-platform tmux configuration
  # Minimal setup that stays close to defaults for muscle memory portability

  programs.tmux = {
    enable = true;

    # Mouse support for scrolling and pane selection
    mouse = true;

    # 50,000 lines scrollback buffer
    historyLimit = 50000;

    # True color support for modern terminals
    terminal = "tmux-256color";

    extraConfig = ''
      # Enable RGB color support
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Catppuccin Mocha status bar theme
      set -g status-style "bg=#1e1e2e,fg=#cdd6f4"
      set -g status-left-style "bg=#89b4fa,fg=#1e1e2e,bold"
      set -g status-right-style "bg=#313244,fg=#cdd6f4"
      set -g window-status-current-style "bg=#89b4fa,fg=#1e1e2e,bold"
      set -g window-status-style "bg=#313244,fg=#cdd6f4"
      set -g pane-border-style "fg=#313244"
      set -g pane-active-border-style "fg=#89b4fa"
      set -g message-style "bg=#89b4fa,fg=#1e1e2e"
    '';
  };
}
