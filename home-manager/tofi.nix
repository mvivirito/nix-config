{ config, ... }:

{
  xdg.configFile."tofi/config".text = ''
    font = Mononoki Nerd Font 12
    prompt-text = ""
    width = 1100
    height = 420
    corner-radius = 10
    border-width = 2
    border-color = #313244
    background-color = #1e1e2e
    text-color = #cdd6f4
    prompt-color = #a6adc8
    selection-color = #cdd6f4
    selection-background = #45475a
    input-background = #181825
    input-color = #cdd6f4
    padding-top = 16
    padding-bottom = 16
    padding-left = 16
    padding-right = 16
    outline-width = 0
    result-spacing = 6
  '';

  xdg.configFile."tofi/clipboard".text = ''
    include = ${config.xdg.configHome}/tofi/config
    prompt-text = ""
    prompt-padding = 0
    prompt-background = #00000000
    prompt-background-padding = 0
    prompt-background-corner-radius = 0
    input-background = #181825
    input-background-padding = 10,12
    input-background-corner-radius = 8
    text-cursor = true
    padding-top = 12
    padding-bottom = 12
    padding-left = 12
    padding-right = 12
    result-spacing = 4
  '';
}
