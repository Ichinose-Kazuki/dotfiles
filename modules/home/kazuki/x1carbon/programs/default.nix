{ inputs, pkgs, ... }:

{
  home.packages =
    with pkgs;
    [
      microsoft-edge
      todoist-electron
    ]
    ++ (
      # Kde packages
      if services.desktopManager.plasma6.enable then
        [
          kdePackages.kate
        ]
      else
        [ ]
    );
}
