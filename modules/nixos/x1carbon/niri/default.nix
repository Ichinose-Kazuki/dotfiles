{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # Imported unconditionally so the niri-flake options (programs.niri,
  # niri-flake.*) are always declared under whole-tree import. Activation is
  # gated by the mkIf below.
  imports = [
    inputs.niri.nixosModules.niri
  ];

  config = lib.mkMerge [
    # Disable niri-flake's binary cache on ALL hosts (it doesn't work with
    # nixos-unstable). Unconditional so importing the niri module on a non-niri
    # host doesn't leak niri.cachix.org into nix.settings.substituters.
    { niri-flake.cache.enable = false; }

    (lib.mkIf (config.myModule.desktop.compositor == "niri") {
      # nixpkgs.overlays = [ inputs.niri.overlays.niri ];

      programs.niri = {
        enable = true;
        package = pkgs.niri;
      };

      environment.variables = {
        NIXOS_OZONE_WL = "1";
        SDL_VIDEODRIVER = "wayland";
        _JAVA_AWT_WM_NONREPARENTING = "1";
        QT_QPA_PLATFORM = "wayland";
        QT_SCREEN_SCALE_FACTORS = "1;1;1"; # For flameshot?
      };
      environment.systemPackages = with pkgs; [
        wl-clipboard
        wayland-utils
        libsecret
        xwayland-satellite
      ];

      security.soteria.enable = true;
    })
  ];
}
