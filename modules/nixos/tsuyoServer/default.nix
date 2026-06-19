{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  # gopro / files / docker are auto-imported via import-tree and guarded by
  # myModule (gopro, "files" component, hardware.docker) — all set in host.nix.
  environment.systemPackages = with pkgs; [
    unzip
  ];
}
