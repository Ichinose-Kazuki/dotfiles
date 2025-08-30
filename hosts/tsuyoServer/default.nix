# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

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
    (self.nixosModules.common + /devtool)
    self.nixosModules.tsuyoServer
  ];

  nix.settings = {
    trusted-users = [ "@wheel" ];
    extra-substituters = [
      "https://raspberry-pi-nix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "raspberry-pi-nix.cachix.org-1:WmV2rdSangxW0rZjY/tBvBDSaNFQ3DyEQsVw8EvHn9o="
    ];
  };

  # qemu emulation of "aarch64-linux"
  # nix.settings.extra-platforms is set automatically by boot.binfmt.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  # Access Windows partition.
  boot.supportedFilesystems = [ "ntfs" ];

  # Fix wol problem: https://wiki.archlinux.org/title/Wake-on-LAN#Fix_by_kernel_quirks
  boot.kernelParams = [ "xhci_hcd.quirks=270336" ];

  # usePredictableInterfaceNames is true by default, so the name enp5s0 shouldn't change.
  networking.interfaces.enp5s0.wakeOnLan.enable = true;

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
      "windows.conf" = ''
        title Windows
        sort-key w
        efi /shellx64.efi
        options -nointerrupt -noconsolein -noconsoleout HD0b:EFI\Microsoft\Boot\bootmgfw.efi
      '';
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
    };
  };
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "tsuyoServer"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     tree
  #   ];
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}
