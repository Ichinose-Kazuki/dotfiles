{ pkgs, ... }:

{
  programs.plasma = {
    enable = true;

    hotkeys.commands."launch-konsole" = {
      name = "Launch Konsole";
      key = "Ctrl+Alt+T";
      command = "konsole";
    };

    configFile = {
      "fcitx5/profile" = {
        "Groups/0" = {
          # Group Name
          Name = "Default";
          # Layout
          "Default Layout" = "us";
          # Default Input Method
          DefaultIM = "mozc";
        };

        "Groups/0/Items/0" = {
          # Name
          Name = "keyboard-us";
          # Layout
          Layout = null;
        };

        "Groups/0/Items/1" = {
          # Name
          Name = "mozc";
          # Layout
          Layout = null;
        };

        "GroupOrder" = {
          "0" = "Default";
        };

      };
    };
  };
}
