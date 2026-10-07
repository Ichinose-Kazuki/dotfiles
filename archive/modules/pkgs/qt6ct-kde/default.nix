# A patched version of qt6ct with support for KDE apps theming.
# Merge Request not approved yet. https://www.opencode.net/trialuser/qt6ct/-/merge_requests/9

{
  cmake,
  fetchFromGitLab,
  lib,
  qtbase,
  qtsvg,
  qttools,
  qtwayland,
  stdenv,
  wrapQtAppsHook,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qt6ct-kde";
  version = "0.10";

  src = fetchFromGitLab {
    domain = "www.opencode.net";
    owner = "ilya-fedin";
    repo = "qt6ct";
    rev = "6fa66ca94f1f8fa5119ad6669d5e3547f4077c1c"; # latest commit from kde branch.
    hash = "sha256-z84z4XhAVqIJpF3m6H9FwFiDR7Nk+AY2tLpsibNEzPY=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtsvg
    qtwayland
  ];

  postPatch = ''
    substituteInPlace src/qt6ct-qtplugin/CMakeLists.txt src/qt6ct-style/CMakeLists.txt \
      --replace-fail "\''${PLUGINDIR}" "$out/${qtbase.qtPluginPrefix}"
  '';

  meta = {
    description = "Qt6 Configuration Tool";
    homepage = "https://www.opencode.net/trialuser/qt6ct";
    platforms = lib.platforms.linux;
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [
      Flakebi
      Scrumplex
    ];
    mainProgram = "qt6ct";
  };
})
