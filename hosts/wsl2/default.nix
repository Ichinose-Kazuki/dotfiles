# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config
, lib
, pkgs
, inputs
, ...
}:

{
  imports = with inputs; [
    # include NixOS-WSL modules
    # ./hardware-configuration.nix
    nix-index-database.nixosModules.nix-index
    self.nixosModules.common
    self.nixosModules.wsl2
  ];

  wsl.enable = true;
  wsl.defaultUser = "kazuki";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  # Copied from hardware-configuration.nix.
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
