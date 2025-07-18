{ config, pkgs, dwm-src, ... }:

{
    imports = [
        ./hardware-configuration.nix
    ];
    
    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    i18n.defaultLocale = "en_CA.UTF-8";
    time.timeZone = "America/Toronto";
    security.rtkit.enable = true;
    
    boot = {
        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
        };
        supportedFilesystems = [ "ntfs" ];
        initrd.kernelModules = [ "nvidia" ];
        extraModulePackages = [ 
            config.boot.kernelPackages.nvidia_x11
        ];
        #blacklistedKernelModules = [ "nouveau" "nvidia_drm" "nvidia_modeset" "nvidia" ];
        #kernelParams = [ "i915.force_probe=4680" ];
    };
    
    hardware = {
        graphics = {
            enable = true;
            enable32Bit = true;
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
        nvidia-container-toolkit.enable = true;
    };
    
    programs = {
        steam.enable = true; 
        bash.shellAliases = {
            nd = "nix develop";
            ndi = "nix develop --impure";
            # Rebuild system.
            rebuild = "(cd ~/repos/dotfiles && bash rebuild.sh)";
            # Open configuration directory in neovim.
            conf = "nvim /home/hayden/repos/dotfiles/";
            # Print the name of the shell. Useful for seeing if you're in a devshell.
            sname = "echo $name";
            # Start script for displaying dwm status bar.
            stathack = "(cd ~/repos/dotfiles && bash status.sh & disown)";
            # Set wallpaper.
            wallhack = "feh --bg-fill ~/.wallpaper.png";
        };
        thunar.enable = true;
        gnupg.agent = {
           enable = true;
           enableSSHSupport = true;
        };
    };

    services = {
        pcscd.enable = true;
        pulseaudio.enable = false;
        # Image thumbnails for Thunar.
        tumbler.enable = true;
        # Other functionality for Thunar.
        gvfs.enable = true;
        gnome.gnome-keyring.enable = true;
        xserver = {
            enable = true;
            autoRepeatDelay = 190;
            autoRepeatInterval = 30;
            xkb = {
                layout = "us";
                variant = "";
            };

            windowManager.dwm = {
                enable = true;
                package = pkgs.dwm.overrideAttrs {
                    src = dwm-src;
                };
            };
            videoDrivers = ["nvidia"];
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
    
    virtualisation = {
        docker = {
            enable = true;
        };
        virtualbox.host.enable = true;
    };

    programs.chromium = {
        enable = true;
        extraOpts = {
            "AutoplayAllowed" = true;
        };
    };
        
    users.users.hayden = {
        isNormalUser = true;
        description = "Hayden";
        extraGroups = [ "networkmanager" "wheel" "docker" "vboxusers" ];
        packages = with pkgs; [
            # General.
            pinentry-curses
            firefox
            google-chrome
            xclip
            neofetch
            ledger
            htop
            feh
            zip
            unzip
            ncdu
            lsof
            # Media and content creation.
            vlc
            ffmpeg
            blender
            flameshot
            inkscape
            gimp
            audacity
            obs-studio
            kdePackages.gwenview
            qbittorrent
            # Gaming.
            ppsspp
            # Development.
            chromium
            chromedriver
            (python311.withPackages (ps: with ps; [
                requests
                numpy
                pandas
                pillow
                pip
                pyarrow
                selenium
            ]))
            ghc
            nasm
            rustc
            cargo
            pyright
            docker-compose
            sqlitebrowser
            cachix
            cudaPackages.cudatoolkit
            clang-tools
            cppcheck
            gcc
            cmake
            gnumake
            valgrind
            gdb
            zig
            go
            pipewire
            pulseaudio
            libpulseaudio
            pkg-config
        ];
    };

    environment.systemPackages = with pkgs; [
        vim
        dmenu
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
