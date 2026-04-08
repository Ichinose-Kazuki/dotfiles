{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  home.packages = with pkgs; [
    # installs folder-color-switcher, nemo-emblems, nemo-fileroller, nemo-python by default.
    (nemo-with-extensions.override { extensions = [ nemo-preview ]; })
  ];
}
