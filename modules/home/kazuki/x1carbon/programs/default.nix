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
    # ./obsidian
  ];

  home.packages = with pkgs; [
    todoist-electron
  ];
}
