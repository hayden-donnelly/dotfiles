{ config, pkgs, lib, ... }:
let
    isDarwin = pkgs.stdenv.isDarwin;
in
{
    home.stateVersion = "23.05";
    home.username = "hayden";
    home.homeDirectory = if !isDarwin then "/home/hayden" else "/Users/hayden";
    fonts.fontconfig.enable = true;        
    home.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        #(nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
    
    programs.kitty = {
        enable = true;
        font = {
            name = "JetBrainsMono";
            size = if !isDarwin then 10 else 12;
        };
        themeFile = "gruvbox-dark";
        extraConfig = ''
            font_family JetBrainsMono Nerd Font Mono
            disable_ligatures always
        '';
    };
    
    programs.git = {
        enable = true;
        lfs.enable = true;
        userName = "hayden-donnelly";
        userEmail = "hayden.git@proton.me";
        extraConfig = {
            github.user = "hayden-donnelly";
            core.editor = "vim";
            credential.helper = "${
                pkgs.git.override { withLibsecret = true; }
            }/bin/git-credential-libsecret";
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
                plugin = nvim-treesitter.withPlugins (treesitter-plugins: 
                    with treesitter-plugins; [
                        bash
                        lua
                        nix
                        python
                        c
                        cpp
                        vim
                        vimdoc
                        go
                    ]
                );
                #plugin = nvim-treesitter.withAllGrammars;
                config = toLuaFile ./nvim/plugins/treesitter.lua;
            }
            {
                plugin = nvim-lspconfig;
                config = toLuaFile ./nvim/plugins/lsp.lua;
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
                plugin = nvim-cmp;
                config = toLuaFile ./nvim/plugins/cmp.lua;
            }
            vim-tmux-navigator
            nvim-web-devicons
            vim-glsl
            cmp-nvim-lsp
            luasnip
            cmp_luasnip
            cmp-nvim-lsp-signature-help
            cmp-buffer
        ];
        
        extraLuaConfig = ''
            ${builtins.readFile ./nvim/options.lua}
        '';
    };

    programs.vscode = lib.mkIf (!isDarwin) {
        enable = true;
        profiles.default.extensions = with pkgs.vscode-extensions; [
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
        profiles.default.userSettings = {
            "workbench.colorTheme" = "Tokyo Night nv";
            "line-length-checker.lineLength" = 95;
            "git.ignoreMissingGitWarning" = true;
        };
    };
}
