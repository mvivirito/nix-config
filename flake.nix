{
  description = "Multi-host NixOS + nix-darwin config (nixos-laptop, zephyrus, nixie-vm, 2x macOS)";

  inputs = {
    # Nixpkgs - unstable for latest packages
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # nix-darwin (macOS system configuration)
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Niri scrolling tiling Wayland compositor
    # Don't follow nixpkgs - let niri use its own tested nixpkgs to avoid build failures
    niri.url = "github:sodiboo/niri-flake";

    # Dank Material Shell (desktop shell: bar, launcher, notifications, lock screen)
    dms.url = "github:AvengeMedia/DankMaterialShell/stable";
    dms.inputs.nixpkgs.follows = "nixpkgs";

    # Google Workspace CLI (gws)
    gws.url = "github:googleworkspace/cli";
    gws.inputs.nixpkgs.follows = "nixpkgs";

    # Prebuilt, weekly-updated nix-index database (powers command-not-found + comma)
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    niri,
    dms,
    gws,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    # `nix fmt` — format all .nix files with the RFC-style formatter
    formatter = {
      x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    };

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      nixos-laptop = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          hostname = "nixos-laptop";
        };
        modules = [
          # Shared modules
          ./hosts/nixos/shared/nix.nix
          ./hosts/nixos/shared/boot.nix
          ./hosts/nixos/shared/locale.nix
          ./hosts/nixos/shared/networking.nix
          ./hosts/nixos/shared/audio.nix
          ./hosts/nixos/shared/fonts.nix
          ./hosts/nixos/shared/users.nix
          ./hosts/nixos/shared/power.nix
          ./hosts/nixos/shared/hibernate.nix

          # Desktop (Niri + DMS)
          niri.nixosModules.niri
          dms.nixosModules.dank-material-shell
          ./nixos/niri.nix
          ./nixos/greetd.nix
          ./nixos/kanata
          ./nixos/theme.nix

          # Host-specific
          ./hosts/nixos/laptop/hardware.nix
          ./hosts/nixos/laptop/default.nix

          # Integrate home-manager as NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {inherit inputs outputs;};
            home-manager.users.michael = ./home-manager/home.nix;
          }
        ];
      };

      # Asus ROG Zephyrus G16 (Intel Core Ultra 9 + NVIDIA RTX 4090)
      zephyrus = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          hostname = "zephyrus";
        };
        modules = [
          # Overlays
          {
            nixpkgs.overlays = [
              # Workaround: openldap test017-syncreplication flaky in nixpkgs
              (final: prev: {
                openldap = prev.openldap.overrideAttrs { doCheck = false; };
              })
              # Workaround: khal is broken in nixpkgs (build fails)
              (final: prev: {
                khal = final.writeShellScriptBin "khal" "echo 'khal disabled - broken in nixpkgs'";
              })
              # rpcs3 is flagged `unfree` in nixpkgs so Hydra never caches it —
              # every dep change is a ~30 min from-source compile, and current
              # nixpkgs breaks that build outright (glew now defaults to EGL,
              # dropping the GLX symbols rpcs3 needs:
              # https://github.com/RPCS3/rpcs3/issues/16819).
              # Use the official prebuilt AppImage instead: no compile, immune to
              # nixpkgs packaging churn. Its dwarfs-based runtime can't be unpacked
              # by appimageTools.wrapType2 (squashfs only), so extract the AppDir
              # with dwarfsextract and wrap it in the FHS env ourselves.
              # To update: bump url + hash to a newer build from
              # https://github.com/RPCS3/rpcs3-binaries-linux/releases
              (
                final: prev:
                let
                  pname = "rpcs3";
                  version = "0.0.41-19454";
                  src = final.fetchurl {
                    url = "https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-0b535328c85b4ebea1a0781ba50670dbe5d41897/rpcs3-v0.0.41-19454-0b535328_linux64.AppImage";
                    hash = "sha256-9QH2T2HcyPVhCRQQKq2/j3S/4v43ACLUnAKj9kuUf7c=";
                  };
                  appdir =
                    final.runCommand "${pname}-${version}-extracted"
                      { nativeBuildInputs = [ final.dwarfs ]; }
                      ''
                        mkdir -p $out
                        dwarfsextract --image-offset=auto -i ${src} -o $out
                      '';
                in
                {
                  rpcs3 = final.appimageTools.wrapAppImage {
                    inherit pname version;
                    src = appdir;
                    extraInstallCommands = ''
                      install -Dm444 ${appdir}/rpcs3.desktop -t $out/share/applications
                      install -Dm444 ${appdir}/rpcs3.svg $out/share/icons/hicolor/scalable/apps/rpcs3.svg
                    '';
                    meta = {
                      description = "PS3 emulator/debugger (official prebuilt AppImage)";
                      homepage = "https://rpcs3.net/";
                      license = final.lib.licenses.gpl2Plus;
                      platforms = [ "x86_64-linux" ];
                      mainProgram = "rpcs3";
                    };
                  };
                }
              )
            ];
          }

          # Shared modules
          ./hosts/nixos/shared/nix.nix
          ./hosts/nixos/shared/boot.nix
          ./hosts/nixos/shared/locale.nix
          ./hosts/nixos/shared/networking.nix
          ./hosts/nixos/shared/audio.nix
          ./hosts/nixos/shared/fonts.nix
          ./hosts/nixos/shared/power.nix
          ./hosts/nixos/shared/hibernate.nix

          # Desktop (Niri + DMS)
          niri.nixosModules.niri
          dms.nixosModules.dank-material-shell
          ./nixos/niri.nix
          ./nixos/greetd.nix
          ./nixos/kanata
          ./nixos/theme.nix

          # Host-specific
          ./hosts/nixos/zephyrus-g16/hardware.nix
          ./hosts/nixos/zephyrus-g16/default.nix
          ./hosts/nixos/zephyrus-g16/nvidia.nix
          ./hosts/nixos/zephyrus-g16/gaming.nix
          ./hosts/nixos/zephyrus-g16/ollama.nix
          ./hosts/nixos/zephyrus-g16/power.nix

          # Integrate home-manager as NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs outputs; };
            home-manager.users.michael = ./hosts/nixos/zephyrus-g16/home.nix;
          }
        ];
      };

      # NixOS VM on Proxmox (KDE Plasma)
      nixie-vm = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          hostname = "nixie-vm";
        };
        modules = [
          # VM-specific modules
          ./hosts/nixos/vm/base.nix
          ./hosts/nixos/vm/desktop/kde.nix
          ./hosts/nixos/vm/sunshine.nix
          ./hosts/nixos/vm/gpu-passthrough.nix

          # Shared modules
          ./hosts/nixos/shared/nix.nix
          ./hosts/nixos/shared/locale.nix
          ./hosts/nixos/shared/networking.nix
          ./hosts/nixos/shared/audio.nix
          ./hosts/nixos/shared/fonts.nix

          # Host-specific
          ./hosts/nixos/nixie-vm/hardware-configuration.nix
          ./hosts/nixos/nixie-vm/default.nix
          ./hosts/nixos/nixie-vm/ollama.nix

          # Integrate home-manager as NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {inherit inputs outputs;};
            home-manager.users.michael = ./hosts/nixos/nixie-vm/home.nix;
          }
        ];
      };
    };

    # nix-darwin configuration entrypoint
    # Available through 'darwin-rebuild switch --flake .#macbook'
    darwinConfigurations = {
      macbook = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs outputs;
          hostname = "macbook";
          username = "mvivirito";
        };
        modules = [
          ./darwin/configuration.nix

          # Integrate home-manager as darwin module
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {
              inherit inputs outputs;
              username = "mvivirito";
            };
            home-manager.users.mvivirito = ./home-manager/home-darwin.nix;
          }
        ];
      };

      michaelvivirito-mbp = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs outputs;
          hostname = "michaelvivirito-mbp";
          username = "michaelvivirito";
        };
        modules = [
          ./darwin/configuration.nix

          # Integrate home-manager as darwin module
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {
              inherit inputs outputs;
              username = "michaelvivirito";
            };
            home-manager.users.michaelvivirito = ./home-manager/home-darwin.nix;
          }
        ];
      };
    };

    # NOTE: no standalone `homeConfigurations` entry. Home-manager runs as a
    # NixOS module (activated by `nixos-rebuild switch`). A separate
    # `home-manager switch` profile would manage the same dotfiles via a second
    # generation and cause .backup collisions / config that reverts on rebuild.
  };
}
