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
            ".config/Code/User/settings.json".source = ./sources/vscode-settings.txt;
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
                nvim-remote-container
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
