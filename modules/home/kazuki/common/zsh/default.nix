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
  # use `programs.zsh.initExtra`.
  hasInitContent = lib.hasAttrByPath [ "programs" "zsh" "initContent" ] options;

  # The init snippet is identical for both old and new HM — only the option
  # name differs. Build it once so the new-HM branch is byte-for-byte equal to
  # what the old module produced (no drift on x1carbon/tsuyoServer).
  initSnippet = ''
    zstyle ':prompt:grml:*:items:user' pre '%F{${osConfig.myModule.shell.zshUserNameColor}}'

    # Source temporary zshrc if exists
    if [ -f "${osConfig.users.users.kazuki.home}/.zshrc.tmp" ]; then
      source "${osConfig.users.users.kazuki.home}/.zshrc.tmp"
    fi
  '';
in
{
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
