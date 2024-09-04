{ config, lib, pkgs, inputs, ... }:

{
  imports = with inputs;
    [
      # Include the results of the hardware scan.

    ];

  # Nix settings
  nix.settings = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];
  };
}
