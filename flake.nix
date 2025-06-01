{
    description = "My system config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
        nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
        home-manager = {
            url = "github:nix-community/home-manager/release-25.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        dwm-src = {
            url = "github:hayden-donnelly/hdwm/ffb4752815ee5e11be0234f91ecd9e7311c9afef";
            flake = false;
        };
    };

    outputs = {self, nixpkgs, nixpkgs-darwin, home-manager, dwm-src, ...}@inputs:
    let
        darwinSystem = "aarch64-darwin";
    in {
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit dwm-src; };
            modules = [
                ./configuration.nix
                home-manager.nixosModules.home-manager {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.users.hayden = import ./home.nix;
                }
            ];
        };

        homeConfigurations.hayden-mac = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs-darwin.legacyPackages.${darwinSystem};
            modules = [ ./home.nix ];
        };
    };
}
