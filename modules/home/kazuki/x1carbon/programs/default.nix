{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./alacritty
    ./chromium
    ./obsidian
  ];

  home.packages = with pkgs; [
    todoist-electron
  ];
}
