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

  # Use the grub EFI boot loader.
  # TODO: Enable lanzaboote, set systemd-boot as default, set timeout to 0, and chainload grub...?
  # TODO: https://wiki.archlinux.org/title/Systemd-boot#GRUB
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev"; # EFI related things are installed in a partition, not a device.
    configurationLimit = 3;
    configurationName = "grub";
    useOSProber = true;
    # I simply dislike the idea of depending on NVRAM state to make my drive bootable.
    # Grub is installed as /boot/EFI/BOOT/BOOTX64.EFI. Motherboard firmware looks for this file before reading NVRAM.
    # In NVRAM, /boot/EFI/BOOT/BOOTX64.EFI is represented as device name "SKHynix ***". Move this entry to the top.
    efiInstallAsRemovable = true;
    extraEntries = ''
      menuentry "Reboot" {
        reboot
      }
      menuentry "Poweroff" {
        halt
      }
    '';
  };
  # boot.loader.efi.canTouchEfiVariables = true; # Required to write boot entry to NVRAM.

  networking.hostName = "programming"; # Define your hostname.
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
        plasma6Support = true;
        waylandFrontend = true;
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kazuki = {
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
      microsoft-edge
      todoist-electron
    ];
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  services.desktopManager.plasma6.enable = true;

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
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-vfs0090;
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
  systemd.services.avahi.wantedBy = lib.mkForce [ ];

  # VMWare
  # virtualisation.vmware.guest.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    home-manager
    kdePackages.sddm-kcm
    kdePackages.kwallet-pam
    kdePackages.kwallet
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
      (nerdfonts.override {
        fonts = [
          "Hack"
          "RobotoMono"
          "IntelOneMono"
        ];
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
