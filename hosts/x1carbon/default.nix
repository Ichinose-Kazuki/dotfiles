# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.nix-index-database.nixosModules.nix-index
      inputs.disko.nixosModules.disko
      ./disko.nix
      ../../modules/nixos/x1carbon/docker
      ../../modules/nixos/x1carbon/ssh
      ../../modules/nixos/x1carbon/udev
      ../../modules/nixos/x1carbon/sddm
    ];

  # Nix settings
  nix.settings = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "ja_JP.UTF-8";
    # extraLocaleSettings = {
    #   LC_MESSAGES = "en_US.UTF-8";
    # };
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-configtool
        ];
        plasma6Support = true;
        waylandFrontend = true;
      };
    };
  };

  # make sure less supports utf-8 character
  environment.sessionVariables.LESSCHARSET = "utf-8";

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };


  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kazuki = {
    isNormalUser = true;
    description = "Kazuki Ichinose";
    hashedPassword = "$6$SJ579N5INL5GkkFX$GaNRYmajPpOXqW7dSxtV2wRX/ikTyOMVUWk1piqMKxMXvJvc2ow07ZsVWk3zatbCi1WwPRn4TDVV9vZXHQ5e8/";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "input" "docker" ];
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
      nixpkgs-fmt
    ];
    shell = pkgs.zsh;
  };
  users.mutableUsers = false;

  # VMWare
  # virtualisation.vmware.guest.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Zsh and Bash
  programs.zsh.enable = true;

  # Comma
  programs.nix-index-database.comma.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    wget
    home-manager
    perl
    lshw
    usbutils
    pciutils
    kdePackages.sddm-kcm
  ];

  # environment.etc = {
  #   "default/locale".text = ''
  #     LANG="ja_JP.UTF-8"
  #   '';
  # };

  fonts = {
    packages = with pkgs;
      [
        noto-fonts-cjk-sans
        (nerdfonts.override {
          fonts = [ "Hack" "RobotoMono" "IntelOneMono" ];
        })
      ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}

