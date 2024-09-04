{ config, lib, pkgs, inputs, ... }:

{
  imports = with inputs;
    [
      # Include the results of the hardware scan.
      self.nixosModules.common
      self.nixosModules.raspi3bp
    ];

  # Nix settings
  nix.settings = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];
  };
}
