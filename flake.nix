{
  description = "My NixOS Flake Configuration using the remote sicos module";

  inputs = {
    # 1. NixOS Unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # 2. Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # 3. SicOS Module from GitHub
    sicos-config = {
      url = "github:egara/nixos-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sicos-config, ... }@inputs:
  let
    # Set the username for the system configuration
    username = "pinano";
  in
  {
    nixosConfigurations = {
      # Change 'my-nixos-pc' to your system's hostname
      "my-nixos-pc" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; # Adjust if you use ARM (aarch64-linux)
        
        # Pass inputs to modules so they can use them
        specialArgs = { inherit inputs; };

        modules = [
          # Import your existing hardware-configuration.nix and configuration.nix here
          ./hardware-configuration.nix
          ./configuration.nix

          # Import the NixOS module for SicOS and enable the desired options
          sicos-config.nixosModules.sicos-hyprland
          {
            programs.sicos.hyprland = {
              enable = true; # Enable SicOS
              theming.enable = true; # Enable default theming (recommended)
              theming.mode = "dark"; # Set theme mode to dark or light
              theming.base16Scheme = "catppuccin-mocha"; # Set theme base16 schema
              powerManagement.enable = true; # Enable power management for laptops
              insync.enable = true; # Enable Insync integration
              kanshi.enable = true; # Enable monitor profile management
              waybar.overwrite = false; #Set the default waybar configurations for SicOS
              swaync.overwrite = false; #Set the default swaync configurations for SicOS
            };
          }

          # Import the Home Manager module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            
            # Configure Home Manager for the specified user
            home-manager.users.${username} = { pkgs, ... }: {
              # Import the Home Manager module for SicOS
              imports = [ sicos-config.homeManagerModules.sicos-hyprland ];
              home.stateVersion = "23.11"; # Or your corresponding version
            };
          }
        ];
      };
    };
  };
}