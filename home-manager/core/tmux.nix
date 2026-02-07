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

      # Vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Vim-style pane resizing (5 cells at a time)
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Gruvbox Dark status bar theme
      set -g status-style "bg=#282828,fg=#ebdbb2"
      set -g status-left-style "bg=#458588,fg=#282828,bold"
      set -g status-right-style "bg=#3c3836,fg=#ebdbb2"
      set -g window-status-current-style "bg=#458588,fg=#282828,bold"
      set -g window-status-style "bg=#3c3836,fg=#a89984"
      set -g pane-border-style "fg=#3c3836"
      set -g pane-active-border-style "fg=#83a598"
      set -g message-style "bg=#458588,fg=#282828"
    '';
  };
}
