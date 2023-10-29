{ config, pkgs, ... }:
let
    home-manager = builtins.fetchTarball {
        url = "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
        sha256 = "0rwzab51hnr6cmm1w5zmfh29gbkg6byv8jnr7frcv5kd6m8kna41";
    };
in
{
    imports = [
        (import "${home-manager}/nixos")
    ];

    home-manager.users.hayden = {
        # This should be the same value as `system.stateVersion` in
        # your `configuration.nix` file.
        home.stateVersion = "23.05";
        home.file = {
            ".config/git/config".source = ./sources/gitconfig.txt;
        };
    };
}
