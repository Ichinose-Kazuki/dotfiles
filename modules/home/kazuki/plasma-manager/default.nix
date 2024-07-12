{ pkgs, ... }:

{
  imports = [
    <plasma-manager/modules>
  ];

  programs.plasma = {
    enable = true;

    hotkeys.commands."launch-konsole" = {
      name = "Launch Konsole";
      key = "Ctrl+Alt+T";
      command = "konsole";
    };
  };
}
