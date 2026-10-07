{
  pkgs,
  lib,
  config,
  ...
}:

{
  # needed for screensharing
  services.pipewire = {
    enable = true;
    # wireplumber is enabled automatically
  };

  # qt wayland support
  # not sure if all of these are necessary.
  # see services.desktopManager.plasma6 source code as well.
  environment.systemPackages =
    (with pkgs.kdePackages; [
      qtimageformats
      qtsvg
      (lib.getBin qttools)
      qtwayland
    ])
    ++ (with pkgs.libsForQt5.qt5; [
      qtimageformats
      qtsvg
      (lib.getBin qttools)
      qtwayland
    ]);
}
