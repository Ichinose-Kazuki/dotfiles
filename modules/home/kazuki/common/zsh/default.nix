{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  options.myOps.zshUserNameColor = lib.mkOption {
    # See color codes with:
    # seq 0 255 | xargs -I {} printf '\033[38;5;{}m{}\033[m '
    default = "blue";
    type = lib.types.str;
  };

  config = {
    programs.zsh.initContent = ''
      zstyle ':prompt:grml:*:items:user' pre '%F{${config.myOps.zshUserNameColor}}'

      # Source temporary zshrc if exists
      if [ -f "${osConfig.users.users.kazuki.home}/.zshrc.tmp" ]; then
        source "${osConfig.users.users.kazuki.home}/.zshrc.tmp"
      fi
    '';
  };
}
