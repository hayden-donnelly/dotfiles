{ config, pkgs, ... }:

let
    unstableTarball =
        fetchTarball
            https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in
{
    imports =
        [
            ./hardware-configuration.nix
            ./home.nix
            ./cachix.nix
        ];

    home-manager.useGlobalPkgs = true;

    boot = {
        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
        };
        supportedFilesystems = [ "ntfs" ];
        extraModulePackages = [ 
            pkgs.linuxKernel.packages.linux_6_1.nvidia_x11
        ];
        blacklistedKernelModules = [ "nouveau" "nvidia_drm" "nvidia_modeset" "nvidia" ];
        kernelParams = [ "i915.force_probe=4680" ];
    };

    nixpkgs.config = {
        allowUnfree = true;
    };
    
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; [ intel-media-driver ];
    };

    services.xserver = {
        enable = true;
        layout = "us";
        xkbVariant = "";
        videoDrivers = ["nvidia"];
        displayManager.sddm.enable = true;
        desktopManager.plasma5.enable = true;
    };

    programs.steam = {
        enable = true;
    };
    
    programs.bash.shellAliases = {
        nd = "nix develop";
        # Rebuild system.
        rebuild = "(cd /home/hayden/repos/dotfiles && bash rebuild.sh)";
        # Open configuration directory in neovim.
        conf = "nvim /home/hayden/repos/dotfiles/";
        # Print the name of the shell. Useful for seeing if you're in a devshell.
        sname = "echo $name"; 
    };

    hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    networking.hostName = "nixos";
    networking.networkmanager.enable = true;
    time.timeZone = "America/Toronto";
    i18n.defaultLocale = "en_CA.UTF-8";

    virtualisation.docker = {
        enable = true;
        enableNvidia = true;
    };

    services.printing.enable = true;

    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;
    };

    users.users.hayden = {
        isNormalUser = true;
        description = "Hayden";
        extraGroups = [ "networkmanager" "wheel" "docker" ];
        packages = with pkgs; [
            (python310.withPackages (ps: with ps; [
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
            git
            git-lfs
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
        ];
    };

    environment.systemPackages = with pkgs; [
        vim
        linuxKernel.packages.linux_6_1.nvidia_x11
    ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?
}
