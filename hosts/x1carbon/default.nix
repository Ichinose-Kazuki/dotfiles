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

  # avoid inputs of this flake from being garbage-collected.
  system.extraDependencies =
    let
      collectFlakeInputs =
        input:
        [ input ] ++ builtins.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or { }));
    in
    builtins.concatMap collectFlakeInputs (builtins.attrValues inputs);

  # Enable builds for rpi.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "x1carbon"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

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
  };

  # Enable touchpad support (enabled by default in most desktopManager).
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
