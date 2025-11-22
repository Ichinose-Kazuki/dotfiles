{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

let
  qt6ct-kde = pkgs.callPackage ../../../pkgs/qt6ct-kde {
    inherit (pkgs.kdePackages)
      qtbase
      qtsvg
      qttools
      qtwayland
      wrapQtAppsHook
      ;
  };
in
{
  imports = [
    ./must-have.nix
    ./hypr-ecosystem.nix
    ./other-utils.nix
    ./monitors
  ];

  home.packages = with pkgs; [
    # theme
    # qt5 variants conflict with these qt6 variants. qt5 is installed along with qt6...?
    # Other attractive themes include Layan, Qogir, and Sweet, but their appearance isn't very consistent between Qt and GTK.
    qt6ct # doesn't work like this: https://www.lorenzobettini.it/2024/08/better-kde-theming-and-styling-in-hyprland/
    kdePackages.breeze
    kdePackages.breeze-icons
    kdePackages.kcolorscheme # Breeze Dark
    kdePackages.qtstyleplugin-kvantum
    kdePackages.breeze-gtk
    dejavu_fonts # default fonts for kde apps.
    playerctl
  ];

  wayland.windowManager.hyprland =
    let
      hyprland-conf = import ./hyprland.conf.nix { inherit pkgs lib config; };
    in
    {
      enable = true;
      package = osConfig.programs.hyprland.package; # enable auto reload.
      portalPackage = null; # portal package is added forcibly in nixos module.
      settings = hyprland-conf.settings;
      extraConfig = hyprland-conf.extraConfig;
    };

  # environment variables: https://wiki.hypr.land/Configuring/Environment-variables/
  # theming, xcursor, nvidia and toolkit variables
  # uniform look for Qt and GTK apps: https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
  # note that QT_QPA_PLATFORMTHEME is applied to non-KDE apps only.
  # for KDE apps, edit their rc files in $XDG_CONFIG_HOME. e.g. konsolerc.
  # kvantum, qt6ct etc does not work rn.
  # about fcitx: https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
  xdg.configFile."uwsm/env".text = ''
    export XCURSOR_SIZE=24

    export GTK_THEME=Breeze-Dark
    export QT_QPA_PLATFORMTHEME=qt6ct
    export QT_STYLE_OVERRIDE=kvantum

    export QT_AUTO_SCREEN_SCALE_FACTOR=1
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

    export GDK_BACKEND=wayland,x11,*
    export QT_QPA_PLATFORM=wayland;xcb
    export SDL_VIDEODRIVER=wayland
    export CLUTTER_BACKEND=wayland

    export XMODIFIERS=@im=fcitx
    export QT_IM_MODULE=fcitx
    export QT_IM_MODULES="wayland;fcitx;ibus"

    export NIXOS_OZONE_WL=1
  '';
  # HYPR* and AQ_* variables
  xdg.configFile."uwsm/env-hyprland".text = ''
    export HYPRCURSOR_SIZE=32
    export HYPRCURSOR_THEME=rose-pine-hyprcursor
  '';

  xdg.portal = {
    enable = lib.mkForce true; # is set false in the hyprland module.
    xdgOpenUsePortal = true; # resolves bugs involving programs opening inside FHS etc.
    extraPortals =
      (with pkgs; [
        xdg-desktop-portal-gtk
      ]) # coverage of each portal: https://wiki.archlinux.org/title/XDG_Desktop_Portal. xdg-desktop-portal-hyprland is added in the hyprland module.
      ++ osConfig.xdg.portal.extraPortals; # https://github.com/nix-community/home-manager/issues/7124
  };

  # let xdph use kde file picker.
  xdg.configFile."xdg-desktop-portal/hyprland-portals.conf".text = lib.generators.toINI { } {
    preferred = {
      default = "hyprland;gtk";
      "org.freedesktop.impl.portal.FileChooser" = "kde";
    };
  };
}
