{ pkgs, lib, config, ... }:

{
  options.local.zshUserNameColor = lib.mkOption {
    # Show numbers of colors:
    # seq 0 255 | xargs -I {} printf '\033[38;5;{}m{}\033[m '
    default = "blue";
    type = lib.types.string;
  };

  programs.zsh.initExtra = ''
    zstyle ':prompt:grml:*:items:user' pre '%F{${config.local.zshUserNameColor}}'
  '';
}
