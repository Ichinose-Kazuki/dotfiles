{
  pkgs,
  lib,
  config,
  osConfig,
  inputs,
  ...
}:

let
  cfg = config.my-waybar;
  powerMenuXml = pkgs.writeTextFile {
    name = "power_menu.xml";
    text = builtins.readFile ./power_menu.xml;
  };
in

{
  options.my-waybar = with lib.types; {
    enable = lib.options.mkEnableOption "my-waybar";
  };

  config = lib.modules.mkIf cfg.enable {

    home.packages = with pkgs; [
      font-awesome
      nerd-fonts.symbols-only # solves off-centered icons problem: https://github.com/Alexays/Waybar/issues/3556#issuecomment-2558272497
      roboto
      # gobject dependencies
      playerctl
      gobject-introspection
      # pipewire controller on status bar
      pavucontrol
    ];

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      # enable inspect to debug style
      # systemd.enableInspect = true;
      style = ./coffeebar.css;
      # enable debug logging to debug config
      settings = import ./waybar-config.json.nix { inherit lib powerMenuXml; };
    };
  };
}
