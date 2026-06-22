{
  config,
  pkgs,
  lib,
  options,
  ...
}:

let
  # `programs.git.settings` was added in home-manager ~24.11; older releases
  # use userName/userEmail/aliases/extraConfig.
  hasGitSettings = lib.hasAttrByPath [ "programs" "git" "settings" ] options;

  # `programs.delta` was added in home-manager ~24.11; guard it for old HM.
  # Use hasAttrByPath so the attribute is ABSENT in old HM, avoiding
  # "option does not exist" even when the condition would be false.
  hasDelta = lib.hasAttrByPath [ "programs" "delta" ] options;

  # Shared: conditional include block for ikazuk repositories
  ikazukInclude = [
    {
      condition = "gitdir:~/ikazuk/";
      contents = {
        user = {
          email = "ikazuk@proton.me";
          name = "ikazuk";
        };
      };
    }
  ];

  gitConfig =
    if hasGitSettings then
      {
        # New HM: flat settings attrset (home-manager >= 24.11)
        enable = true;
        settings = {
          alias = {
            ci = "commit";
            cm = "commit -m";
            cam = "commit -am";
            co = "checkout";
            br = "branch";
            pl = "pull";
            ps = "push";
            st = "status";
            df = "diff";
            lg = "log";
          };
          user = {
            email = "mail@ichinose-kazuki.jp";
            name = "Ichinose-Kazuki";
          };
          init = {
            defaultBranch = "main";
          };
        };
        includes = ikazukInclude;
      }
    else
      {
        # Old HM: separate top-level options (home-manager 24.05)
        enable = true;
        userName = "Ichinose-Kazuki";
        userEmail = "mail@ichinose-kazuki.jp";
        aliases = {
          ci = "commit";
          cm = "commit -m";
          cam = "commit -am";
          co = "checkout";
          br = "branch";
          pl = "pull";
          ps = "push";
          st = "status";
          df = "diff";
          lg = "log";
        };
        extraConfig = {
          init.defaultBranch = "main";
        };
        includes = ikazukInclude;
      };

  # Syntax-highlighting diff viewer — only available in newer home-manager.
  # Use optionalAttrs (not mkIf) so the attribute is ABSENT in old HM, avoiding
  # "option does not exist" even when hasDelta is false.
  deltaConfig = lib.optionalAttrs hasDelta {
    delta = {
      enable = true;
      enableGitIntegration = true;
    };
  };
in
{
  programs = { git = gitConfig; } // deltaConfig;
}
