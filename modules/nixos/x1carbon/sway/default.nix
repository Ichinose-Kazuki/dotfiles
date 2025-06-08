{
  config,
  pkgs,
  lib,
  ...
}:

{
  # apparently this is the right way to install swayfx (https://reddit.com/r/NixOS/comments/1cqm4ws/im_about_to_give_up/)
  # this option installs brightnessctl, foot, grim, pulseaudio, swayidle, swaylock, wmenu.
  # see description of programs.sway.extraPackages for other useful software.
  # see description of programs.sway.extraSessionCommands if there is any rendering issues.
  programs.sway = {
    enable = true;
    package = pkgs.swayfx; # sway with additional features
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaybg # background image utility for sway
      waybar # customizable status bar for Wayland compositors
      mako # notification daemon
      rofi-wayland # app launcher
      autotiling-rs # switch the tiling layout automatically
      swayrbar # bar content generator
    ];
  };
}
