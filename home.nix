{ config, pkgs, ... }:
with import <nixpkgs> { config = { allowUnfree = true; }; };
let
    home-manager = builtins.fetchTarball {
        url = "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
        sha256 = "1gxlnjdmiw92qqmnp31hpdpw2via2xmy95fsnmlx0z177mxs669g";
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

        programs.vscode = {
            enable = true;
            extensions = with pkgs.vscode-extensions; [
                ms-python.python
                ms-python.vscode-pylance
                bbenoist.nix
            ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
                {
                    name = "tokyo-night";
                    publisher = "enkia";
                    version = "1.0.6";
                    sha256 = "sha256-VWdUAU6SC7/dNDIOJmSGuIeffbwmcfeGhuSDmUE7Dig=";
                }
                {
                    name = "line-length-checker-vscode";
                    publisher = "SUPERTSY5";
                    version = "1.0.0";
                    sha256 = "sha256-yPgWWqaoYDXxj5sQuME5g3P+YVAt4iZEx0azRoiPZBg=";
                }
                {
                    name = "copilot";
                    publisher = "GitHub";
                    version = "1.130.518";
                    sha256 = "sha256-kHUk9Ap90MAZVyp+avhrgKE8luE+5NekVGZfSwDyzXU=";
                }
                {
                    name = "remote-containers";
                    publisher = "ms-vscode-remote";
                    version = "0.320.0";
                    sha256 = "sha256-432TLuzHuXK9DmJlOpFFGlZqbWTsAWnGA8zk7/FarQw=";
                }
                {
                    name = "cpptools-extension-pack";
                    publisher = "ms-vscode";
                    version = "1.3.0";
                    sha256 = "sha256-rHST7CYCVins3fqXC+FYiS5Xgcjmi7QW7M4yFrUR04U=";
                }
            ];
            userSettings = {
                "workbench.colorTheme" = "Tokyo Night nv";
                "line-length-checker.lineLength" = 95;
                "git.ignoreMissingGitWarning" = true;
            };
        };

        programs.neovim = 
        let
            toLua = str: "lua << EOF\n${str}\nEOF\n";
            toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
        in
        {
            enable = true;
            viAlias = true;
            vimAlias = true;
            vimdiffAlias = true;
            
            plugins = with pkgs.vimPlugins; [
                {
                    plugin = (nvim-treesitter.withPlugins (p: [
                        p.tree-sitter-nix
                        p.tree-sitter-vim
                        p.tree-sitter-bash
                        p.tree-sitter-lua
                        p.tree-sitter-python
                        p.tree-sitter-json
                    ]));
                    config = toLuaFile ./nvim/plugin/treesitter.lua;
                }
            ];
            
            extraLuaConfig = ''${builtins.readFile ./nvim/options.lua}'';
        
        };
    };
}
