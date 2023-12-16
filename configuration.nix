{ config, pkgs, ... }:

let
    unstableTarball =
        fetchTarball
            https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in
{
    imports =
        [
            # Include the results of the hardware scan.
            ./hardware-configuration.nix
            ./home.nix
        ];

    home-manager.useGlobalPkgs = true;

    # Bootloader.
    boot = {
        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
        };
        supportedFilesystems = [ "ntfs" ];
    };

    # Allow unfree packages
    nixpkgs.config = {
        allowUnfree = true;
    };

    # Enable OpenGL
    hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; [ intel-media-driver ];
    };

    # Configure X11.
    services.xserver = {
        enable = true;
        layout = "us";
        xkbVariant = "";
        videoDrivers = ["nvidia"];
        # Enable the KDE Plasma Desktop Environment.
        displayManager.sddm.enable = true;
        desktopManager.plasma5.enable = true;
    };

    hardware.nvidia = {
        # Modesetting is required.
        modesetting.enable = true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        powerManagement.enable = false;
        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = false;

        # Use the NVidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of
        # supported GPUs is at:
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
        # Only available from driver 515.43.04+
        # Do not disable this unless your GPU is unsupported or if you have a good reason to.
        open = true;

        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;

        # Optionally, you may need to select the appropriate driver version for your specific GPU.
        package = config.boot.kernelPackages.nvidiaPackages.stable;

        prime = {
            sync.enable = true;
            # Make sure to use the correct Bus ID values for your system!
            intelBusId = "PCI:0:2:0";
		    nvidiaBusId = "PCI:1:0:0";
        };
    };

    networking.hostName = "nixos"; # Define your hostname.

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "America/Toronto";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_CA.UTF-8";

    # Enable virtualisation for Docker.
    virtualisation.docker = {
        enable = true;
        enableNvidia = true;
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
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

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.hayden = {
        isNormalUser = true;
        description = "Hayden";
        extraGroups = [ "networkmanager" "wheel" "docker" ];
        packages = with pkgs; [
            (python310.withPackages (ps: with ps; [
                numpy
                pandas
            ]))
            firefox
            google-chrome
            kate
            git
            vim
            neovim
            vlc
            blender
            docker-compose
            flameshot
            inkscape
            gimp
            obs-studio
        ];
    };

    environment.systemPackages = with pkgs; [
        vim
    ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?
}
