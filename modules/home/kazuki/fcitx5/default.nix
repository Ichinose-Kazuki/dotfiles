{ config
, pkgs
, ...
}:

{
  home.file."${config.xdg.configHome}/fcitx5/profile".source = ./profile;
}
