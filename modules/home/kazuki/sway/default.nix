{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

{
  # apparently this is the right way to install swayfx (https://reddit.com/r/NixOS/comments/1cqm4ws/im_about_to_give_up/)
  # see description of nixpkgs.options.programs.sway.extraPackages for useful software for sway.
  # see description of nixpkgs.options.programs.sway.extraSessionCommands if there is any rendering issues.
  wayland.windowManager.sway = {
    enable = true;
    config = null;
    package = null; # sway with additional features, comes with swaybar and swaymsg
    # wrapperFeatures.gtk = true;
    checkConfig = false; # https://github.com/nix-community/home-manager/issue/5379
  };

  xdg.configFile."sway/config" = lib.mkForce {
    source = "${osConfig.programs.sway.package}/etc/sway/config";
  };

  programs = {
    waybar = {
      enable = false;
    };
  };

  services = {
    mako = {
      enable = false;
    };
  };

  home.packages = with pkgs; [
    # autotiling-rs
    # rofi-wayland
    # swaybg
  ];
}
