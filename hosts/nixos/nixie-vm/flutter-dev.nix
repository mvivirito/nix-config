{ pkgs, ... }:

let
  # Android SDK configuration
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    # Build tools and platform tools - include 36 for AndroidX compatibility
    buildToolsVersions = [ "34.0.0" "35.0.0" ];
    platformVersions = [ "34" "35" "36" ];
    
    # Additional SDK components
    includeEmulator = false;  # Skip emulator (we use real devices)
    includeNDK = true;
    ndkVersions = [ "26.1.10909125" "27.0.12077973" "28.2.13676358" ];
    
    # System images - skip for now (using real devices)
    includeSystemImages = false;
    
    # Extra packages
    extraLicenses = [
      "android-sdk-license"
      "android-sdk-preview-license"
      "android-googletv-license"
      "android-sdk-arm-dbt-license"
      "google-gdk-license"
      "intel-android-extra-license"
      "intel-android-sysimage-license"
      "mips-android-sysimage-license"
    ];
  };

  androidSdk = androidComposition.androidsdk;

  # FHS environment for running Gradle-downloaded binaries (aapt2, etc.)
  fhsEnv = pkgs.buildFHSEnv {
    name = "android-fhs-env";
    targetPkgs = pkgs: with pkgs; [
      # Core build dependencies
      glibc
      zlib
      libcxx
      
      # Android SDK
      androidSdk
      
      # Java
      jdk21
      
      # Flutter
      flutter
      
      # Build tools
      cmake
      ninja
      pkg-config
      git
      curl
      unzip
      
      # For native compilation
      gcc
      binutils
      
      # X11/graphics libs (for Flutter desktop/web tools)
      xorg.libX11
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXi
      libGL
      
      # GTK for Linux desktop builds
      gtk3
      glib
      pango
      cairo
      atk
      gdk-pixbuf
      
      # For secure storage and other plugins
      libsecret
      jsoncpp
    ];
    
    runScript = "bash";
    
    profile = ''
      export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
      export ANDROID_SDK_ROOT="${androidSdk}/libexec/android-sdk"
      export JAVA_HOME="${pkgs.jdk21}"
      export CHROME_EXECUTABLE="${pkgs.chromium}/bin/chromium"
      export PATH="${androidSdk}/libexec/android-sdk/platform-tools:$PATH"
    '';
  };

in {
  # Note: ADB udev rules are automatic in systemd 258+ (NixOS 26.05)
  # Just need android-tools in system packages

  # System packages for Flutter/Android development
  environment.systemPackages = with pkgs; [
    # Flutter SDK
    flutter

    # Android SDK (composed above)
    androidSdk

    # FHS environment for Gradle builds
    fhsEnv

    # Android tools
    android-tools  # adb, fastboot

    # Java (required by Android toolchain)
    jdk17

    # Build tools
    cmake
    ninja
    pkg-config
    unzip
    
    # Chrome for web development (Flutter web)
    chromium
  ];

  # Set up environment variables for Android SDK
  environment.sessionVariables = {
    ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
    ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
    CHROME_EXECUTABLE = "${pkgs.chromium}/bin/chromium";
    
    # Java home for Gradle
    JAVA_HOME = "${pkgs.jdk17}";
  };

  # Accept Android SDK licenses (required for Gradle builds)
  # The licenses are accepted via extraLicenses above
}
