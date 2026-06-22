{
  pkgs,
  lib,
  osConfig,
  ...
}:

{
  config = lib.mkIf (osConfig.myModule.hostName == "x1carbon") {
    home.packages = with pkgs; [
      todoist-electron
    ];
  };
}
