{ config, pkgs, ... }:
with import <nixpkgs> { config = { allowUnfree = true; }; };
let
    home-manager = builtins.fetchTarball {
        url = "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
        sha256 = "sha256:069a5hhvqig1xs8y63nv9cmi2w7ixq4g1ihyv890sy5xbw3qf84d";
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

        fonts.fontconfig.enable = true;        
        home.packages = with pkgs; [
            (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];
        
        programs.kitty = {
            enable = true;
            font = {
                name = "JetBrainsMono";
                size = 10;
            };
            theme = "Gruvbox Dark";
            extraConfig = ''
                font_family JetBrainsMono Nerd Font Mono
                disable_ligatures always
            '';
        };

        programs.git = {
            enable = true;
            lfs.enable = true;
            userName = "hayden-donnelly";
            userEmail = "donnellyhd@outlook.com";
            extraConfig = {
                github.user = "hayden-donnelly";
                core.editor = "vim";
            };
        };

        programs.tmux = {
            enable = true;
            plugins = with pkgs.tmuxPlugins; [
                sensible
                vim-tmux-navigator
                yank
            ];
            terminal = "screen-256color";
            mouse = true;
            baseIndex = 1;
            keyMode = "vi";
            extraConfig = ''
                # Vi keybindings.
                set-window-option -g mode-keys vi
                bind-key -T copy-mode-vi v send-keys -X begin-selection
                bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
                bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
                # Open panes in current directory.
                bind '"' split-window -v -c "#{pane_current_path}"
                bind % split-window -h -c "#{pane_current_path}"
                # Enable copying to system clipboard.
                set -g set-clipboard on
                bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
            '';
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
                        p.tree-sitter-cpp
                        p.tree-sitter-glsl
                    ]));
                    config = toLuaFile ./nvim/plugins/treesitter.lua;
                }
                {
                    plugin = gruvbox-nvim;
                    config = "colorscheme gruvbox";
                }
                {
                    plugin = nvim-tree-lua;
                    config = toLuaFile ./nvim/plugins/nvim_tree.lua;
                }
                {
                    plugin = telescope-nvim;
                    config = toLuaFile ./nvim/plugins/telescope.lua;
                }
                vim-tmux-navigator
                nvim-web-devicons
                vim-glsl
            ];
            
            extraLuaConfig = ''
                ${builtins.readFile ./nvim/options.lua}
            '';
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
    };
}
