{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./alacritty
    ./chromium
    ./flameshot
  ];

  home.packages = with pkgs; [
    todoist-electron
  ];
}
