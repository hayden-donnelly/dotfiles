{ config, pkgs, ... }:

{
    imports = [
        ./hardware-configuration.nix
    ];
    
    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    i18n.defaultLocale = "en_CA.UTF-8";
    time.timeZone = "America/Toronto";
    sound.enable = true;
    security.rtkit.enable = true;
    
    boot = {
        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
        };
        supportedFilesystems = [ "ntfs" ];
        extraModulePackages = [ 
            config.boot.kernelPackages.nvidia_x11
        ];
        blacklistedKernelModules = [ "nouveau" "nvidia_drm" "nvidia_modeset" "nvidia" ];
        kernelParams = [ "i915.force_probe=4680" ];
    };
    
    hardware = {
        opengl = {
            enable = true;
            driSupport = true;
            driSupport32Bit = true;
            extraPackages = with pkgs; [ intel-media-driver ];
        };
        nvidia = {
            modesetting.enable = true;
            powerManagement.enable = false;
            powerManagement.finegrained = false;
            open = true;
            nvidiaSettings = true;
            package = config.boot.kernelPackages.nvidiaPackages.stable;
        };
        pulseaudio.enable = false;
    };
    
    programs = {
        steam.enable = true; 
        bash.shellAliases = {
            nd = "nix develop";
            ndi = "nix develop --impure";
            # Rebuild system.
            rebuild = "(cd /home/hayden/repos/dotfiles && bash rebuild.sh)";
            # Open configuration directory in neovim.
            conf = "nvim /home/hayden/repos/dotfiles/";
            # Print the name of the shell. Useful for seeing if you're in a devshell.
            sname = "echo $name";
            # Start script for displaying dwm status bar.
            stathack = "(cd /home/hayden/repos/dotfiles && bash status.sh & disown)";
        };
        thunar.enable = true;
    };

    services = {
        # Image thumbnails for Thunar.
        tumbler.enable = true;
        # Other functionality for Thunar.
        gvfs.enable = true;
        gnome.gnome-keyring.enable = true;
        xserver = {
            enable = true;
            xkb = {
                layout = "us";
                variant = "";
            };
            windowManager.dwm = {
                enable = true;
                package = pkgs.dwm.overrideAttrs {
                    src = ./dwm;
                };
            };
            # Re-enable this for Docker GPU containers. Flakes with nixGL do not need it.
            # videoDrivers = ["nvidia"];
        };
        displayManager = {
            sddm.enable = true;
            defaultSession = "none+dwm";
        };
        pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            # If you want to use JACK applications, uncomment this
            #jack.enable = true;
        };
        printing.enable = true;
    };
    
    networking = {
        hostName = "nixos";
        networkmanager.enable = true;
    };

    virtualisation.docker = {
        enable = true;
        enableNvidia = true;
    };
        
    users.users.hayden = {
        isNormalUser = true;
        description = "Hayden";
        extraGroups = [ "networkmanager" "wheel" "docker" ];
        packages = with pkgs; [
            (python311.withPackages (ps: with ps; [
                requests
                numpy
                pandas
                pillow
                pip
                pyarrow
            ]))
            cachix
            ffmpeg
            firefox
            google-chrome
            vlc
            blender
            docker-compose
            flameshot
            inkscape
            gimp
            obs-studio
            sqlitebrowser
            cudaPackages.cudatoolkit
            xclip
            clang-tools
            pyright
            ppsspp
            neofetch
            htop
            gcc
            cmake
            gnumake
            valgrind
            gdb
            pipewire
            pulseaudio
            libpulseaudio
            pkg-config
        ];
    };

    environment.systemPackages = with pkgs; [
        vim
        dmenu
        (st.overrideAttrs (oldAttrs: rec {
            configFile = writeText "config.def.h" (builtins.readFile ./st/config.h);
            postPatch = "${oldAttrs.postPatch}\n cp ${configFile} config.def.h";
        }))
        config.boot.kernelPackages.nvidia_x11
    ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?
}
