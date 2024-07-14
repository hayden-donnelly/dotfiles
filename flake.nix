{
    description = "My system config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
        home-manager = {
            url = "github:nix-community/home-manager/release-24.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        dwm-src = {
            url = "github:hayden-donnelly/hdwm/1.0.0";
            flake = false;
        };
    };

    outputs = {self, nixpkgs, home-manager, dwm-src, ...}@inputs:
    #let
    #    overlays = [
    #        (final: prev: {
    #            dwm = prev.dwm.overrideAttrs (oldattrs: {
    #                src = fetchGit {
    #                    url = "https://github.com/hayden-donnelly/hdwm.git";
    #                    rev = "8d09aeca2e24008bb3ea55e70a6134e284a718d3";
    #                }; 
    #            });
    #        })
    #    ];
    #    system = "x86_64-linux";
    #    pkgs = import nixpkgs { inherit system overlays; };
    #in {
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
