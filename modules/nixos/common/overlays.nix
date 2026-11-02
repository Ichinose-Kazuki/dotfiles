{ ... }:

{
  nixpkgs.overlays = [
    (import ../../../pkgs/overlay.nix)
  ];
}
