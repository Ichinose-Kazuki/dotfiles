# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = with inputs; [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    nix-index-database.nixosModules.nix-index
    disko.nixosModules.disko
    ./disko.nix
    self.nixosModules.common
    self.nixosModules.x1carbon
  ];

  # TODO: Make this a module like: https://github.com/stepbrobd/dotfiles/blob/8a90166bbabe4b32769df9aea11d6ee6d042b6de/modules/common/lix.nix#L24.
  nix.settings = {
    extra-substituters = [ "https://cache.lix.systems" ];
    extra-trusted-public-keys = [ "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o=" ];
  };

  # TODO: Enable lanzaboote, set systemd-boot as default, set timeout to 0, and chainload grub...?
  # TODO: https://wiki.archlinux.org/title/Systemd-boot#GRUB
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 3;
    editor = false; # Recommended to set this to false.
    # https://github.com/Gerg-L/nixos/blob/3563e757eee5201420a8dc61a543a329f2bb08d7/hosts/gerg-desktop/boot.nix#L74
    extraFiles = {
      "shellx64.efi" = pkgs.edk2-uefi-shell.efi;
      # https://github.com/jordanisaacs/dotfiles/blob/4a779f42204c4fff743c12b26e28567eaf8cc334/overlays/default.nix#L6
      # https://github.com/jordanisaacs/dotfiles/blob/4a779f42204c4fff743c12b26e28567eaf8cc334/modules/system/boot/default.nix#L47
      "efi/efi-power/reboot.efi" = "${pkgs.efi-power}/reboot.efi";
      "efi/efi-power/poweroff.efi" = "${pkgs.efi-power}/poweroff.efi";
    };
    extraEntries = {
      # Sort-key is configured so that these come after the nixos entries (which have sort-key nixos).
      # Remove -noconsolein to be able to type any pins.
      "power.conf" = ''
        title Power Off
        sort-key z0
        efi /efi/efi-power/poweroff.efi
      '';
      "reboot.conf" = ''
        title Reboot
        sort-key z1
        efi /efi/efi-power/reboot.efi
      '';
      "windows.conf" = ''
        title Windows
        sort-key z2
        efi /shellx64.efi
        options -nointerrupt -noconsolein -noconsoleout HD0b:EFI\Microsoft\Boot\bootmgfw.efi
      '';
    };
  };
  boot.loader.efi.canTouchEfiVariables = true; # Required to write boot entry to NVRAM.

  networking.hostName = "x1carbon"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

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
        # plasma6Support = true;
        waylandFrontend = true;
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kazuki = {
    packages = with pkgs; [
      # kdePackages.kate
      #  thunderbird
      microsoft-edge
      todoist-electron
    ];
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  # services.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  # services.desktopManager.plasma6.enable = true;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
  };
  systemd.services.printing.wantedBy = lib.mkForce [ ];

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Enable fingerprint.
  # Don't forget to run `sudo fprintd-enroll` and test with `sudo fprintd-verify`.
  # Bug: pam_fprintd.so should come before pam_unix.so.
  # https://github.com/NixOS/nixpkgs/issues/239770
  # https://github.com/NixOS/nixpkgs/blob/2becde3c1913fc74dec4108a067bfb5f5b93096b/nixos/modules/security/pam.nix#L663
  # ! Build failure as of 2025/03/29
  # services.fprintd = {
  # enable = true;
  # tod = {
  # enable = true;
  # driver = pkgs.libfprint-2-tod1-vfs0090;
  # };
  # };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
  systemd.services.avahi.wantedBy = lib.mkForce [ ];

  # VMWare
  # virtualisation.vmware.guest.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages (already allowed in flake.nix)
  # nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    home-manager
    # kdePackages.sddm-kcm
    # kdePackages.kwallet-pam
    # kdePackages.kwallet
    wol # Wake-on-LAN
  ];

  # environment.etc = {
  #   "default/locale".text = ''
  #     LANG="ja_JP.UTF-8"
  #   '';
  # };

  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-sans
      nerd-fonts.hack
      nerd-fonts.roboto-mono
      nerd-fonts.intone-mono
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
