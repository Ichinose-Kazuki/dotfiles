{
  # Twilight breeze theme
  "kdedefaults/ksplashrc" = {
    KSplash = {
      Engine = "KSplashQML";
      Theme = "org.kde.breezetwilight.desktop";
    };
  };
  "kdedefaults/plasmarc" = {
    Theme = {
      name = "breeze-dark";
    };
  };
  kdeglobals = {
    KDE = {
      LookAndFeelPackage = "org.kde.breezetwilight.desktop";
    };
  };
  "kdedefaults/package" = {
    text =
      "org.kde.breezetwilight.desktop";
    # force = true;
  };
}
