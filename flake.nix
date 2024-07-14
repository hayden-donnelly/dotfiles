{
    description = "My system config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
        home-manager = {
            url = "github:nix-community/home-manager/release-24.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        dwm-src = {
            url = "github:hayden-donnelly/hdwm/85cb1c6cb9bb044f756e8fc3258ce730e9f9cf48";
            flake = false;
        };
    };

    outputs = {self, nixpkgs, home-manager, dwm-src, ...}@inputs:
    {
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
    };
}
