{
  pkgs,
  lib,
  config,
  osConfig,
  options,
  ...
}:

let
  # `programs.zsh.initContent` was added in home-manager ~25.05; older releases
  # (e.g. raspi3bp's HM 24.05) use `programs.zsh.initExtra`.
  hasInitContent = lib.hasAttrByPath [ "programs" "zsh" "initContent" ] options;

  # The init snippet is identical for both old and new HM — only the option
  # name differs. Build it once so the new-HM branch is byte-for-byte equal to
  # what the old module produced (no drift on x1carbon/wsl2/tsuyoServer).
  initSnippet = ''
    zstyle ':prompt:grml:*:items:user' pre '%F{${osConfig.myModule.shell.zshUserNameColor}}'

    # Source temporary zshrc if exists
    if [ -f "${osConfig.users.users.kazuki.home}/.zshrc.tmp" ]; then
      source "${osConfig.users.users.kazuki.home}/.zshrc.tmp"
    fi
  '';
in
{
  # TODO: Remove this deprecated shim once all hosts have migrated to
  # reading zshUserNameColor from osConfig.myModule.shell.zshUserNameColor.
  # Other hosts may still SET myOps.zshUserNameColor; the shim prevents
  # evaluation errors for them during the transition period.
  options.myOps.zshUserNameColor = lib.mkOption {
    # See color codes with:
    # seq 0 255 | xargs -I {} printf '\033[38;5;{}m{}\033[m '
    default = "blue";
    type = lib.types.str;
  };

  config =
    if hasInitContent then
      {
        # New HM (>= 25.05): initContent
        programs.zsh.initContent = initSnippet;
      }
    else
      {
        # Old HM (24.05): initExtra
        programs.zsh.initExtra = initSnippet;
      };
}
