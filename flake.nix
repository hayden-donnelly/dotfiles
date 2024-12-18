{
    description = "My system config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
        home-manager = {
            url = "github:nix-community/home-manager/release-24.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        dwm-src = {
            url = "github:hayden-donnelly/hdwm/ffb4752815ee5e11be0234f91ecd9e7311c9afef";
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
