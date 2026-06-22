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
  config = lib.mkIf (config.myModule.hostName == "tsuyoServer") {
    environment.systemPackages = with pkgs; [
      unzip
    ];
  };
}
