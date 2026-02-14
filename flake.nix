{
  description = "Your new nix config";

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
    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    # Dank Material Shell (desktop shell: bar, launcher, notifications, lock screen)
    dms.url = "github:AvengeMedia/DankMaterialShell/stable";
    dms.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    niri,
    dms,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      nixos-laptop = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          hostname = "nixos-laptop";
        };
        # > Our main nixos configuration file <
        modules = [
          ./nixos/configuration.nix

          # Niri compositor NixOS module
          niri.nixosModules.niri

          # Dank Material Shell (bar, launcher, notifications, lock)
          dms.nixosModules.dank-material-shell

          # Integrate home-manager as NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs outputs;};
            home-manager.users.michael = ./home-manager/home.nix;
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

          # Shared modules
          ./hosts/nixos/shared/locale.nix
          ./hosts/nixos/shared/networking.nix
          ./hosts/nixos/shared/audio.nix
          ./hosts/nixos/shared/fonts.nix

          # Host-specific
          ./hosts/nixos/nixie-vm/hardware-configuration.nix
          ./hosts/nixos/nixie-vm/default.nix

          # Integrate home-manager as NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
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

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "michael@nixos-laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = {inherit inputs outputs;};
        # > Our main home-manager configuration file <
        modules = [
          niri.homeModules.niri
          ./home-manager/home.nix
        ];
      };
      # Future hosts prepared:
      # "michael@desktop" = home-manager.lib.homeManagerConfiguration { ... };
    };
  };
}
