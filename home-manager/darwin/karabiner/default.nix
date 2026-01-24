# Karabiner-Elements configuration
# Uses home.activation instead of home.file because Karabiner has bugs with symlinked config files
{ config, lib, ... }:
let
  karabinerConfig = builtins.readFile ./karabiner.json;
in {
  home.activation.karabinerConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.config/karabiner
    $DRY_RUN_CMD cat > ~/.config/karabiner/karabiner.json << 'EOF'
${karabinerConfig}
EOF
    # Restart Karabiner to pick up changes
    $DRY_RUN_CMD /bin/launchctl kickstart -k gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server || true
  '';
}
