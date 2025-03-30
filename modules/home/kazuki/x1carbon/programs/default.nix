{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./chromium
    ./flameshot
  ];

  home.packages = with pkgs; [
    microsoft-edge
    todoist-electron
  ];
}
