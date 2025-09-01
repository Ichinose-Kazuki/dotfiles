{ pkgs, ... }:
{
  # stable version
  # https://lix.systems/add-to-config/
  # (commented out due to infinite recursion error)
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     inherit (final.lixPackageSets.stable)
  #       nixpkgs-review
  #       nix-direnv
  #       nix-eval-jobs
  #       nix-fast-build
  #       colmena
  #       ;
  #   })
  # ];

  nix.package = pkgs.lixPackageSets.stable.lix;
}
