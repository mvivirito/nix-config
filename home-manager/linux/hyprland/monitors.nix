{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    # Multi-monitor layout configuration
    # Format: "OUTPUT,WIDTHxHEIGHT@REFRESH,XxY,SCALE"
    #
    # Physical setup:
    # - DP-2: 5120x1440 ultrawide (49" Samsung CHG90 or similar)
    # - eDP-1: 2160x1350 laptop display (Framework Laptop 13" or similar)
    #
    # Position calculation (extended desktop):
    # - DP-2 starts at (1661, 0)
    # - eDP-1 starts at (6781, 166)
    #
    # Why these positions?
    # 1. DP-2 X-offset (1661):
    #    - Positions external display offset from origin
    #    - Specific positioning for user preference
    #
    # 2. eDP-1 X-offset (6781):
    #    - Places laptop display to right of external
    #    - Math: 1661 (DP-2 offset) + 5120 (DP-2 width) = 6781 ✓
    #    - Confirms: laptop is right-side extension
    #
    # 3. eDP-1 Y-offset (166):
    #    - Vertically aligns displays (top edges don't match)
    #    - Centers laptop vertically relative to external
    #    - Approximate calculation: (1440 - 1350/1.25) / 2 ≈ 180
    #    - Actual: 166 (adjusted for visual preference)
    #
    # Result: [External 49" ultrawide] [gap] [Laptop 13" centered vertically]
    # Total virtual desktop: 6781 + 2160/1.25 = 8509 pixels wide
    #
    # To adjust:
    # - For different alignment, use wlr-randr interactively
    # - Run: wlr-randr (shows current config)
    # - Then update these values to match working configuration

    monitor = [
      "DP-2,5120x1440@120.0,1661x0,1.0"         # External ultrawide (primary)
      "eDP-1,2160x1350@59.743999,6781x166,1.25"  # Laptop (right extension, vertically centered)
    ];
  };
}
